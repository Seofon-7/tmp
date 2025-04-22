<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ClientFiltering.aspx.cs" Inherits="DevExpressSample.ClientFiltering" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ASPxGridView 客戶端篩選</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <dx:ASPxGridView ID="ASPxGridView1" runat="server" AutoGenerateColumns="False" 
                KeyFieldName="ID" ClientInstanceName="grid"
                OnInit="ASPxGridView1_Init">
                <SettingsSearchPanel Visible="false" />
                <Toolbars>
                    <dx:GridViewToolbar>
                        <Items>
                            <dx:GridViewToolbarItem>
                                <Template>
                                    <dx:ASPxComboBox ID="AreaFilter" runat="server" Width="200px" 
                                        Caption="選擇區域:" DropDownStyle="DropDownList" 
                                        ValueType="System.String" IncrementalFilteringMode="Contains"
                                        ClientInstanceName="areaComboBox">
                                        <CaptionSettings Position="Left" />
                                        <ClientSideEvents SelectedIndexChanged="function(s, e) { ApplyAreaFilter(); }" />
                                    </dx:ASPxComboBox>
                                </Template>
                            </dx:GridViewToolbarItem>
                            <dx:GridViewToolbarItem>
                                <Template>
                                    <dx:ASPxButton ID="ClearFilterBtn" runat="server" Text="清除篩選" 
                                        AutoPostBack="false">
                                        <ClientSideEvents Click="function(s, e) { ClearFilter(); }" />
                                    </dx:ASPxButton>
                                </Template>
                            </dx:GridViewToolbarItem>
                        </Items>
                    </dx:GridViewToolbar>
                </Toolbars>
                <Columns>
                    <dx:GridViewDataTextColumn FieldName="ID" ReadOnly="True" VisibleIndex="0" Caption="編號">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Name" VisibleIndex="1" Caption="名稱">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Area" VisibleIndex="2" Caption="區域">
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Description" VisibleIndex="3" Caption="描述">
                    </dx:GridViewDataTextColumn>
                </Columns>
                <Settings ShowFilterRow="false" />
                <ClientSideEvents Init="function(s, e) { InitializeEvents(); }" />
            </dx:ASPxGridView>
        </div>
    </form>
    
    <script type="text/javascript">
        function InitializeEvents() {
            // 初始化時沒有特別動作
        }
        
        function ApplyAreaFilter() {
            var filterValue = areaComboBox.GetValue();
            if (filterValue) {
                // 創建字符串包含過濾條件 - 使用 LIKE 篩選，相當於包含篩選
                grid.ApplyFilter("[Area] LIKE '%" + filterValue + "%'");
            } else {
                // 如果沒有選擇值，清除篩選
                grid.ClearFilter();
            }
        }
        
        function ClearFilter() {
            // 清除篩選並將下拉框重置為未選擇狀態
            grid.ClearFilter();
            areaComboBox.SetSelectedIndex(0);
        }
    </script>
</body>
</html>


using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using DevExpress.Web;
using Oracle.ManagedDataAccess.Client;
using System.Configuration;

namespace DevExpressSample
{
    public partial class ClientFiltering : Page
    {
        // 取得資料庫連線字串
        private string ConnectionString
        {
            get
            {
                return ConfigurationManager.ConnectionStrings["OracleConnection"].ConnectionString;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // 一次性從 Oracle 資料庫中載入所有資料
                BindGridView();
                
                // 初始化下拉選單
                InitializeAreaComboBox();
            }
        }
        
        protected void ASPxGridView1_Init(object sender, EventArgs e)
        {
            // 這裡不需要做什麼，因為我們使用客戶端篩選
        }
        
        private void InitializeAreaComboBox()
        {
            // 獲取下拉選單控制項
            ASPxComboBox areaComboBox = ASPxGridView1.Toolbars[0].Items[0].FindControl("AreaFilter") as ASPxComboBox;
            if (areaComboBox != null)
            {
                // 清除已有選項
                areaComboBox.Items.Clear();
                
                // 添加「全部」選項
                areaComboBox.Items.Add("全部", "");
                
                // 從已綁定的資料源中提取不重複的區域值
                DataTable dt = ASPxGridView1.DataSource as DataTable;
                if (dt != null)
                {
                    List<string> areas = new List<string>();
                    
                    foreach (DataRow row in dt.Rows)
                    {
                        string area = row["Area"].ToString();
                        if (!areas.Contains(area))
                        {
                            areas.Add(area);
                            areaComboBox.Items.Add(area, area);
                        }
                    }
                }
            }
        }
        
        private void BindGridView()
        {
            using (OracleConnection conn = new OracleConnection(ConnectionString))
            {
                try
                {
                    conn.Open();
                    // 請根據實際表名和欄位名修改以下 SQL 查詢
                    string sql = "SELECT ID, Name, Area, Description FROM YourTableName";
                    using (OracleCommand cmd = new OracleCommand(sql, conn))
                    {
                        OracleDataAdapter adapter = new OracleDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        
                        // 綁定數據到 GridView
                        ASPxGridView1.DataSource = dt;
                        ASPxGridView1.DataBind();
                    }
                }
                catch (Exception ex)
                {
                    // 記錄異常
                    System.Diagnostics.Debug.WriteLine("綁定 GridView 錯誤: " + ex.Message);
                    // 可以加入更多錯誤處理邏輯
                }
            }
        }
    }
}
