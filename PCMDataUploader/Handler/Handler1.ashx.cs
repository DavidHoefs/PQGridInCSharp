using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using Newtonsoft.Json;

namespace PCMDataUploader.Handler
{
    /// <summary>
    /// Handles retrieving and uploading data to SQL server. Set the connection string for the server in web.config
    /// </summary>
    public class Handler1 : IHttpHandler
    {
        private readonly List<Employee> _employeeList = new List<Employee>();

        /// <summary>
        /// All Data in DB
        /// </summary>
        public List<Employee> EmployeeList => _employeeList;

        /// <summary>
        /// Data to be added to db from page
        /// </summary>
        public List<Employee> NewData = new List<Employee>();

        //private List<Employee> addList = new List<Employee>();
        private void updateList(List<Employee> updateList)
        {
            List<Employee> products = EmployeeList;

            for (int i = 0; i < updateList.Count; i++)
            {
                Employee product2 = updateList[i];

                Employee product = products.Find(Product => Product.EmployeeID == product2.EmployeeID);
                if (product == null)
                {
                    products.Add(product2);
                }
                else
                {
                    product.EmployeeID = product2.EmployeeID;

                    product.LastName = product2.LastName;
                    product.FirstName = product2.FirstName;

                    product.Title = product2.Title;
                    product.TitleOfCourtesy = product2.TitleOfCourtesy;
                    product.HomePhone = product2.HomePhone;
                    product.Address = product2.Address;
                    product.BirthDate = product2.BirthDate;
                    product.HireDate = product2.HireDate;
                }
            }
        }

        private void addList(List<Employee> addList)
        {
            List<Employee> products = EmployeeList;
            int max;
            NewData = addList;
            if (products.Count == 0)
            {
                max = 0;
            }
            else
            {
                max = products.OrderByDescending(x => x.EmployeeID).First().EmployeeID;
            }

            for (int i = 0; i < addList.Count; i++)
            {
                Employee product = addList[i];
                product.EmployeeID = max + 1 + i;
                products.Add(product);
            }
        }

        public void ProcessRequest(HttpContext context)
        {
            string json = GetEmployeeJson();
            string callback = context.Request.QueryString["callback"];
            if (context.Request.HttpMethod == "POST")
            {
                string list = context.Request.Form["list"];

                JavaScriptSerializer js = new JavaScriptSerializer();
                Dictionary<string, List<Employee>> dlist = js.Deserialize<Dictionary<string, List<Employee>>>(list);
                addList(dlist["addList"]);
                updateList(dlist["updateList"]);
                string d = js.Serialize(dlist);

                PostData(NewData);
                context.Response.Write(d);
                //this.PostData(result);

                return;
            }

            if (!string.IsNullOrEmpty(callback))
            {
                json = string.Format("{0}({1});", callback, json);
            }
            context.Response.ContentType = "text/json";
            context.Response.Write(json);
        }

        private string GetEmployeeJson()
        {
            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = ConfigurationManager.ConnectionStrings["DBModels"].ConnectionString;
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT EmployeeID,FirstName,LastName,Title,TitleOfCourtesy,BirthDate,HireDate,Address,City,HomePhone FROM Employees";
                    cmd.Connection = conn;
                    conn.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            EmployeeList.Add(new Employee
                            {
                                EmployeeID = (int)rdr["EmployeeID"],
                                FirstName = (string)rdr["FirstName"],
                                LastName = (string)rdr["LastName"],
                                Title = (string)rdr["Title"],
                                TitleOfCourtesy = (string)rdr["TitleOfCourtesy"],
                                BirthDate = (DateTime?)rdr["BirthDate"],
                                HireDate = (DateTime?)rdr["HireDate"],
                                Address = (string)rdr["Address"],
                                City = (string)rdr["City"],
                                HomePhone = (string)rdr["HomePhone"]
                            });
                        }
                    }
                    conn.Close();
                }
                string jsonString = JsonConvert.SerializeObject(EmployeeList);
                return jsonString;
            }
        }

        //{ title: "EmployeeID", dataType: "integer", dataIndx: "EmployeeID" },
        //            { title: "LastName",dataType: "string",dataIndx: "lastname"},
        //            { title: "FirstName", dataType: "string", dataIndx: "firstname" },
        //            { title: "Title", dataType: "string", dataIndx: "title" },
        //            { title: "TitleOfCourtesy", dataType: "string", dataIndx: "titleofcourtesy" },
        //            { title: "BirthDate", dataType: "date", dataIndx: "birthdate" },
        //            { title: "HireDate", dataType: "date", dataIndx: "hiredate" },
        //            { title: "Address", dataType: "string", dataIndx: "address" },
        //            { title: "City", dataType: "string", dataIndx: "city" },
        //            { title: "HomePhone", dataType: "string", dataIndx: "homephone" },
        private void PostData(List<Employee> employees)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["DBModels"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                SqlTransaction trans = conn.BeginTransaction();

                string sql = "INSERT INTO dbo.Employees (LastName,FirstName,Title,TitleOfCourtesy,BirthDate,HireDate,Address,City,HomePhone) VALUES (@LastName, @FirstName, @Title, @TitleOfCourtesy, @BirthDate, @HireDate, @Address, @City, @HomePhone)";

                foreach (Employee employee in employees)
                {
                    SqlCommand cmd = new SqlCommand(sql, conn, trans)
                    {
                        CommandType = CommandType.Text,
                        Connection = conn
                    };
                    cmd.Parameters.AddWithValue("@LastName", employee.LastName);
                    cmd.Parameters.AddWithValue("@FirstName", employee.FirstName);
                    cmd.Parameters.AddWithValue("@Title", employee.Title);

                    cmd.Parameters.AddWithValue("@TitleOfCourtesy", employee.TitleOfCourtesy);
                    cmd.Parameters.AddWithValue("@BirthDate", employee.BirthDate);
                    cmd.Parameters.AddWithValue("@HireDate", employee.HireDate);
                    cmd.Parameters.AddWithValue("@Address", employee.Address);
                    cmd.Parameters.AddWithValue("@City", employee.City);
                    cmd.Parameters.AddWithValue("@HomePhone", employee.HomePhone);
                    cmd.ExecuteNonQuery();
                }
                try
                {
                    trans.Commit();
                }
                catch
                {
                    trans.Rollback();
                }
                conn.Close();
                NewData = new List<Employee>();
            }
        }

        private static string DecodeUrlString(string url)
        {
            string newUrl;
            while ((newUrl = Uri.UnescapeDataString(url)) != url)
            {
                url = newUrl;
            }

            return newUrl;
        }

        public bool IsReusable => false;
    }
}