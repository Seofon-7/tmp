你可以透過在 ASP.NET WebForms 頁面初始化 (Page_Load) 時檢查 Oracle 資料表是否有資料，然後根據結果停用所有按鈕與 DevExpress 的表格操作功能（如新增、編輯、刪除）。以下是具體的作法範例：

⸻

步驟 1：在 Page_Load 中檢查資料表是否有資料

protected void Page_Load(object sender, EventArgs e)
{
    if (!IsPostBack)
    {
        if (CheckIfDataExistsInOracle())
        {
            DisableAllControls();
        }
    }
}

private bool CheckIfDataExistsInOracle()
{
    bool hasData = false;
    string connStr = ConfigurationManager.ConnectionStrings["YourOracleConnectionString"].ConnectionString;
    using (OracleConnection conn = new OracleConnection(connStr))
    {
        conn.Open();
        using (OracleCommand cmd = new OracleCommand("SELECT COUNT(*) FROM YOUR_TABLE_NAME", conn))
        {
            int count = Convert.ToInt32(cmd.ExecuteScalar());
            hasData = count > 0;
        }
    }
    return hasData;
}


⸻

步驟 2：停用所有控制項（按鈕、Grid 的功能）

private void DisableAllControls()
{
    // 停用 Toolbar 上的按鈕
    btnAdd.Enabled = false;
    btnEdit.Enabled = false;
    btnDelete.Enabled = false;
    btnSave.Enabled = false;

    // 停用 ASPxGridView 的新增、編輯、刪除功能
    ASPxGridView1.SettingsDataSecurity.AllowEdit = false;
    ASPxGridView1.SettingsDataSecurity.AllowInsert = false;
    ASPxGridView1.SettingsDataSecurity.AllowDelete = false;

    // 如有需要也可以整個 Grid 設定為唯讀
    ASPxGridView1.ReadOnly = true;
}


⸻

注意事項：
	1.	btnAdd, btnEdit 等請換成你實際使用的按鈕 ID。
	2.	如果你是用 DevExpress 的 ASPxButton 或 Toolbar Item，也可以用 FindControl 或直接設 Enabled = false。
	3.	若有 pop-up 編輯表單，也要手動把那些欄位設成 ReadOnly 或停用。

⸻

如果你提供更多畫面元素（像是 Toolbar 使用什麼控件、GridView 名稱等），我可以幫你調整這段程式碼讓它完全符合你的專案架構。需要的話也可以提供完整範例。