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
using System.Linq;
using System.Web.UI;
using DevExpress.Web;

namespace DevExpressSample
{
    public partial class Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // 綁定資料到 GridView
                ASPxGridView1.DataSource = CreateSampleData();
                ASPxGridView1.DataBind();
                
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
                
                // 從資料源中提取不重複的區域值
                DataTable dataTable = CreateSampleData();
                List<string> areas = new List<string>();
                
                foreach (DataRow row in dataTable.Rows)
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
        
        // 創建測試數據
        private DataTable CreateSampleData()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("ID", typeof(int));
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("Area", typeof(string));
            dt.Columns.Add("Description", typeof(string));
            
            // 添加測試數據
            dt.Rows.Add(1, "測試項目 1", "台北市", "台北市測試描述");
            dt.Rows.Add(2, "測試項目 2", "新北市", "新北市測試描述");
            dt.Rows.Add(3, "測試項目 3", "台北市", "台北市另一個測試");
            dt.Rows.Add(4, "測試項目 4", "桃園市", "桃園市測試描述");
            dt.Rows.Add(5, "測試項目 5", "新竹市", "新竹市測試描述");
            dt.Rows.Add(6, "測試項目 6", "台北市", "台北市第三個測試");
            dt.Rows.Add(7, "測試項目 7", "台中市", "台中市測試描述");
            dt.Rows.Add(8, "測試項目 8", "高雄市", "高雄市測試描述");
            
            return dt;
        }
    }
}