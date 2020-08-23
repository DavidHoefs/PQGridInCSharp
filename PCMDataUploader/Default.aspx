<%@ Page Title="Home Page" Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PCMDataUploader._Default" %>

<link rel="stylesheet"
    href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/themes/base/jquery-ui.css" />
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
<!--ParamQuery Grid files-->
<link href="Content/pqgrid.min.css" rel="stylesheet" />
<script src="Content/pqgrid.min.js"></script>
<script type="text/javascript">

    $(function () {
        $.ajax({

            dataType: "json",

            async: "true",

            url: '<%=ResolveUrl("~/Handler/Handler1.ashx")%>',

            success: function (result) {

                var obj = {
                    width: 700,
                    height: 400,
                    scrollModel: {
                        autoFit: true
                    },

                    resizeable: true,
                    virtualX: true,
                    selectionModel: {
                        type: 'cell'
                    },
                    editModel: {
                        onBlur: 'validate',
                        saveKey: $.ui.keyCode.ENTER
                    },
                    editor: {
                        select: true
                    },

                    trackModel: {
                        on: true
                    },
                    history: function (evt, ui) {
                        var $grid = $(this);
                        if (ui.canUndo != null) {
                            $("button.changes", $grid).button("option", {
                                disabled: !ui.canUndo
                            });
                        }
                        if (ui.canRedo != null) {
                            $("button:contains('Redo')", $grid).button("option", "disabled", !ui.canRedo);
                        }
                        $("button:contains('Undo')", $grid).button("option", {
                            label: 'Undo (' + ui.num_undo + ')'
                        });
                        $("button:contains('Redo')", $grid).button("option", {
                            label: 'Redo (' + ui.num_redo + ')'
                        });
                    },
                    refresh: function () {
                        $("#grid_editing").find("button.delete_btn").button({
                            icons: {
                                primary: 'ui-icon-scissors'
                            }
                        })
                            .unbind("click")
                            .bind("click", function (evt) {
                                var $tr = $(this).closest("tr");
                                var obj = $grid.pqGrid("getRowIndx", {
                                    $tr: $tr
                                });
                                var rowIndx = obj.rowIndx;
                                $grid.pqGrid("addClass", {
                                    rowIndx: rowIndx,
                                    cls: 'pq-row-delete'
                                });

                                var ans = window.confirm("Are you sure to delete row No " + (rowIndx + 1) + "?");
                                $grid.pqGrid("removeClass", {
                                    rowIndx: rowIndx,
                                    cls: 'pq-row-delete'
                                });
                                if (ans) {
                                    $grid.pqGrid("deleteRow", {
                                        rowIndx: rowIndx
                                    });
                                }
                            });
                    },
                    toolbar: {
                        items: [{
                            type: 'button',
                            icon: 'ui-icon-plus',
                            label: 'New Product',
                            listener: {
                                "click": function (evt, ui) {
                                    //append empty row at the end.
                                    var rowData = {}; //empty row
                                    var rowIndx = $grid.pqGrid("addRow", {
                                        rowData: rowData,
                                        checkEditable: true
                                    });
                                    $grid.pqGrid("goToPage", {
                                        rowIndx: rowIndx
                                    });
                                    $grid.pqGrid("editFirstCellInRow", {
                                        rowIndx: rowIndx
                                    });
                                }
                            }
                        },
                        {
                            type: 'button',
                            icon: 'ui-icon-disk',
                            label: 'Save Changes',
                            cls: 'changes',
                            listener: {
                                "click": function (evt, ui) {
                                    saveChanges();
                                }
                            },
                            options: {
                                disabled: true
                            }
                        },
                        {
                            type: 'button',
                            icon: 'ui-icon-cancel',
                            label: 'Reject Changes',
                            cls: 'changes',
                            listener: {
                                "click": function (evt, ui) {
                                    $grid.pqGrid("rollback");
                                    $grid.pqGrid("history", {
                                        method: 'resetUndo'
                                    });
                                }
                            },
                            options: {
                                disabled: true
                            }
                        },
                        {
                            type: 'button',
                            icon: 'ui-icon-cart',
                            label: 'Get Changes',
                            cls: 'changes',
                            listener: {
                                "click": function (evt, ui) {
                                    var changes = $grid.pqGrid("getChanges", {
                                        format: 'raw'
                                    });
                                    try {
                                        console.log(changes);
                                    } catch (ex) { }
                                    alert("Please see the log of changes in your browser console.");
                                }
                            },
                            options: {
                                disabled: true
                            }
                        },
                        {
                            type: 'separator'
                        },
                        {
                            type: 'button',
                            icon: 'ui-icon-arrowreturn-1-s',
                            label: 'Undo',
                            cls: 'changes',
                            listener: {
                                "click": function (evt, ui) {
                                    $grid.pqGrid("history", {
                                        method: 'undo'
                                    });
                                }
                            },
                            options: {
                                disabled: true
                            }
                        },
                        {
                            type: 'button',
                            icon: 'ui-icon-arrowrefresh-1-s',
                            label: 'Redo',
                            listener: {
                                "click": function (evt, ui) {
                                    $grid.pqGrid("history", {
                                        method: 'redo'
                                    });
                                }
                            },
                            options: {
                                disabled: true
                            }
                        }

                        ]
                    },

                };

                obj.colModel = [

                    {
                        title: "EmployeeID",
                        dataType: "integer",
                        dataIndx: "EmployeeID"
                    },
                    {
                        title: "LastName",
                        dataType: "string",
                        dataIndx: "LastName"
                    },
                    {
                        title: "FirstName",
                        dataType: "string",
                        dataIndx: "FirstName"
                    },
                    {
                        title: "Title",
                        dataType: "string",
                        dataIndx: "Title"
                    },
                    {
                        title: "TitleOfCourtesy",
                        dataType: "string",
                        dataIndx: "TitleOfCourtesy"
                    },
                    {
                        title: "BirthDate",
                        dataType: "date",
                        dataIndx: "BirthDate"
                    },
                    {
                        title: "HireDate",
                        dataType: "date",
                        dataIndx: "HireDate"
                    },
                    {
                        title: "Address",
                        dataType: "string",
                        dataIndx: "Address"
                    },
                    {
                        title: "City",
                        dataType: "string",
                        dataIndx: "City"
                    },
                    {
                        title: "HomePhone",
                        dataType: "string",
                        dataIndx: "HomePhone"
                    }

                ];

                obj.dataModel = {

                    data: result,

                    location: "local"

                };

                var $grid = $("#photos").pqGrid(obj);

                function saveChanges() {
                    var grid = $grid.pqGrid('getInstance').grid;

                    //attempt to save editing cell.
                    if (grid.saveEditCell() === false) {
                        return false;
                    }

                    var isDirty = grid.isDirty();
                    if (isDirty) {
                        //validate the new added rows.
                        var addList = grid.getChanges().addList;
                        //debugger;
                        for (var i = 0; i < addList.length; i++) {
                            var rowData = addList[i];
                            var isValid = grid.isValid({
                                "rowData": rowData
                            }).valid;
                            if (!isValid) {
                                return;
                            }
                        }
                        var changes = grid.getChanges({
                            format: "byVal"
                        });

                        //post changes to server
                        $.ajax({
                            dataType: "json",
                            type: "POST",
                            async: true,
                            beforeSend: function (jqXHR, settings) {
                                grid.showLoading();
                            },
                            url: '<%=ResolveUrl("~/Handler/Handler1.ashx")%>', //for ASP.NET, java
                        data: {
                            list: JSON.stringify(changes)
                        },
                        success: function (changes) {

                            grid.commit({
                                type: 'add',
                                rows: changes.addList
                            });
                            grid.commit({
                                type: 'update',
                                rows: changes.updateList
                            });
                            grid.commit({
                                type: 'delete',
                                rows: changes.deleteList
                            });

                            grid.history({
                                method: 'reset'
                            });

                        },
                        complete: function () {
                            grid.hideLoading();
                            grid.refreshDataAndView();
                        }
                    });

                    }
                }

            }

        });

        function isEditing($grid) {
            var rows = $grid.pqGrid("getRowsByClass", {
                cls: 'pq-row-edit'
            });
            if (rows.length > 0) {
                var rowIndx = rows[0].rowIndx;
                $grid.pqGrid("goToPage", {
                    rowIndx: rowIndx
                });
                //focus on editor if any
                $grid.pqGrid("editFirstCellInRow", {
                    rowIndx: rowIndx
                });
                return true;
            }
            return false;
        };

        function addRow($grid) {
            if (isEditing($grid)) {
                return false;
            }
            //append empty row in the first row.
            var rowData = {}; //empty row template
            $grid.pqGrid("addRow", {
                rowIndxPage: 0,
                rowData: rowData
            });

            var $tr = $grid.pqGrid("getRow", {
                rowIndxPage: 0
            });
            if ($tr) {
                //simulate click on edit button.
                $tr.find("button.edit_btn").click();
            }
        };

    });
</script>
<head runat="server">
    <title></title>
</head>
<body>

    <div id="photos" style="margin: auto"></div>
</body>