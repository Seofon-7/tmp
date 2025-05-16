要讓 GridViewCommandColumn 裡的 CustomButton 隱藏（或停用），你可以使用 Grid.CustomButtonInitialize 事件，在後端判斷條件後設置 e.Visible = false; 或 e.Enabled = false;。

⸻

解法：後端控制 GridViewCommandColumnCustomButton 顯示與否

範例：

protected void ASPxGridView1_CustomButtonInitialize(object sender, ASPxGridViewCustomButtonEventArgs e)
{
    // 假設你在 Page_Load 時有一個 flag 判斷資料是否鎖定
    if (ViewState["PageLocked"] != null && (bool)ViewState["PageLocked"])
    {
        e.Visible = DevExpress.Utils.DefaultBoolean.False;
    }
}

在 Page_Load 中加：

protected void Page_Load(object sender, EventArgs e)
{
    if (!IsPostBack)
    {
        bool isLocked = CheckIfDataExistsInOracle();
        ViewState["PageLocked"] = isLocked;

        if (isLocked)
        {
            DisableAllControls();
            ShowPopup("目前頁面資料已存在，無法進行新增或編輯操作！");
        }
    }
}


⸻

Grid 定義中：設定 CustomButtonInitialize 事件

在 ASPX 中的 ASPxGridView 加上：

<dx:ASPxGridView ID="ASPxGridView1" runat="server" ... 
    OnCustomButtonInitialize="ASPxGridView1_CustomButtonInitialize">
    <Columns>
        <dx:GridViewCommandColumn>
            <CustomButtons>
                <dx:GridViewCommandColumnCustomButton ID="btnCustomEdit" Text="自訂編輯" />
            </CustomButtons>
        </dx:GridViewCommandColumn>
    </Columns>
</dx:ASPxGridView>


⸻

結果：

只要 Oracle 有資料存在，你的：
	•	所有按鈕會停用
	•	Grid 的新增/編輯/刪除停用
	•	自訂的 GridViewCommandColumnCustomButton 也會自動隱藏

⸻

若你有多個 CustomButton 需要條件式控制，也可以加上 e.ButtonID 判斷，例如：

if (e.ButtonID == "btnCustomEdit" || e.ButtonID == "btnExport")
{
    e.Visible = DevExpress.Utils.DefaultBoolean.False;
}

需要我幫你整合到完整範例嗎？