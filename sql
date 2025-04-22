<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="DevExpressSample.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ASPxGridView 篩選範例</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <dx:ASPxGridView ID="ASPxGridView1" runat="server" AutoGenerateColumns="False" 
                KeyFieldName="ID" OnInit="ASPxGridView1_Init">
                <SettingsSearchPanel Visible="false" />
                <Toolbars>
                    <dx:GridViewToolbar>
                        <Items>
                            <dx:GridViewToolbarItem>
                                <Template>
                                    <dx:ASPxComboBox ID="AreaFilter" runat="server" Width="200px" 
                                        Caption="選擇區域:" DropDownStyle="DropDownList" 
                                        ValueType="System.String" IncrementalFilteringMode="Contains"
                                        OnSelectedIndexChanged="AreaFilter_SelectedIndexChanged"
                                        AutoPostBack="true">
                                        <CaptionSettings Position="Left" />
                                    </dx:ASPxComboBox>
                                </Template>
                            </dx:GridViewToolbarItem>
                            <dx:GridViewToolbarItem Command="ClearFilter" Text="清除篩選" />
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
            </dx:ASPxGridView>
        </div>
    </form>
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
    public partial class Default : Page
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
                // 綁定資料到 GridView
                BindGridView();
                
                // 初始化下拉選單
                InitializeAreaComboBox();
            }
        }
        
        protected void ASPxGridView1_Init(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // 重置篩選條件
                ASPxGridView1.FilterExpression = string.Empty;
            }
        }
        
        protected void AreaFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            ASPxComboBox comboBox = sender as ASPxComboBox;
            if (comboBox != null && !string.IsNullOrEmpty(comboBox.Value.ToString()))
            {
                string selectedArea = comboBox.Value.ToString();
                // 設定篩選表達式，使用 Contains 函數來篩選包含指定區域的資料
                ASPxGridView1.FilterExpression = string.Format("[Area] LIKE '%{0}%'", selectedArea);
                ASPxGridView1.DataBind();
            }
            else
            {
                // 清除篩選條件
                ASPxGridView1.FilterExpression = string.Empty;
                ASPxGridView1.DataBind();
            }
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
                
                // 從 Oracle 資料庫中獲取不重複的區域值
                using (OracleConnection conn = new OracleConnection(ConnectionString))
                {
                    try
                    {
                        conn.Open();
                        // 請根據實際表名和欄位名修改以下 SQL 查詢
                        string sql = "SELECT DISTINCT Area FROM YourTableName ORDER BY Area";
                        using (OracleCommand cmd = new OracleCommand(sql, conn))
                        {
                            using (OracleDataReader reader = cmd.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    string area = reader["Area"].ToString();
                                    areaComboBox.Items.Add(area, area);
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        // 記錄異常
                        System.Diagnostics.Debug.WriteLine("獲取區域資料錯誤: " + ex.Message);
                        // 可以加入更多錯誤處理邏輯
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