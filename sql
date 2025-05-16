以下是 DevExpress 19.2 + ASP.NET WebForms (.NET 4.7.2) 的完整範例，展示如何在點擊 ASPxGridView 的自訂 Toolbar 按鈕後，透過 CustomCallback 在後端執行對應邏輯。

⸻

ASPX 頁面 (GridExample.aspx)

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GridExample.aspx.cs" Inherits="YourNamespace.GridExample" %>

<%@ Register Assembly="DevExpress.Web.v19.2" Namespace="DevExpress.Web" TagPrefix="dx" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>DevExpress Grid Toolbar Custom Button Callback</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <dx:ASPxGridView ID="ASPxGridView1" runat="server" ClientInstanceName="grid"
                AutoGenerateColumns="False" OnCustomCallback="ASPxGridView1_CustomCallback">
                
                <Columns>
                    <dx:GridViewDataTextColumn FieldName="ID" Caption="ID" />
                    <dx:GridViewDataTextColumn FieldName="Name" Caption="Name" />
                </Columns>

                <SettingsToolbar ShowToolbar="True" />
                <Toolbars>
                    <dx:GridViewToolbar>
                        <Items>
                            <dx:GridViewToolbarItem Name="customRefresh" Text="重新整理" />
                            <dx:GridViewToolbarItem Name="customExport" Text="匯出" />
                        </Items>
                    </dx:GridViewToolbar>
                </Toolbars>

                <ClientSideEvents ToolbarItemClick="onToolbarClick" />
            </dx:ASPxGridView>
        </div>

        <script type="text/javascript">
            function onToolbarClick(s, e) {
                if (e.item.name === "customRefresh") {
                    s.PerformCallback("customRefresh");
                } else if (e.item.name === "customExport") {
                    s.PerformCallback("customExport");
                }
            }
        </script>
    </form>
</body>
</html>


⸻

後端程式 (GridExample.aspx.cs)

using System;
using System.Data;
using System.Web.UI;

namespace YourNamespace
{
    public partial class GridExample : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && !ASPxGridView1.IsCallback)
            {
                BindGrid();
            }
        }

        private void BindGrid()
        {
            // 模擬資料來源
            DataTable dt = new DataTable();
            dt.Columns.Add("ID", typeof(int));
            dt.Columns.Add("Name", typeof(string));

            dt.Rows.Add(1, "Alice");
            dt.Rows.Add(2, "Bob");
            dt.Rows.Add(3, "Charlie");

            ASPxGridView1.DataSource = dt;
            ASPxGridView1.DataBind();
        }

        protected void ASPxGridView1_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
        {
            if (e.Parameters == "customRefresh")
            {
                BindGrid(); // 重新整理
            }
            else if (e.Parameters == "customExport")
            {
                // 這裡可以改為實際的匯出邏輯，如匯出 Excel
                Response.Clear();
                Response.ContentType = "text/plain";
                Response.Write("執行匯出邏輯！");
                Response.End();
            }
        }
    }
}


⸻

你可以依需求修改的地方：

功能	修改點
匯出	customExport 區段可改用 ASPxGridViewExporter 做 Excel 匯出
重新整理	customRefresh 現在只是重新綁定 Grid 資料
資料來源	改用你實際的 Oracle 查詢結果


⸻

是否需要我也幫你加入匯出 Excel（搭配 ASPxGridViewExporter）的實作？