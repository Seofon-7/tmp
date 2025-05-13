這個狀況很常見，發生的原因通常是 ComboBox 在頁面回傳（postback 或 callback）後資料被重新綁定了，導致選取的值消失或被重設。

⸻

問題根本原因

在 Page_Load 或 cbxFilter_Init 裡，如果你重新設定了 ComboBox 的 DataSource 並 DataBind()，但沒有還原使用者剛選取的值，ComboBox 就會變空或顯示錯誤的項目。

⸻

解法一：只在非回傳時綁定資料

你可以把 ComboBox 的初始化放在 !IsPostBack 判斷內，這樣就不會在選完之後再重設值：

protected void cbxFilter_Init(object sender, EventArgs e)
{
    if (!IsPostBack)
    {
        ASPxComboBox comboBox = sender as ASPxComboBox;
        comboBox.DataSource = GetYourData(); // 資料來源
        comboBox.TextField = "DisplayName";
        comboBox.ValueField = "ID";
        comboBox.DataBind();
    }
}


⸻

解法二：手動設定選取的值（如果值保存在 Session 裡）

如果你是在 ASPxCallback 儲存選取值進 Session，可以在 Page_Load 或 cbxFilter_Init 裡設回選取值：

protected void cbxFilter_Init(object sender, EventArgs e)
{
    ASPxComboBox comboBox = sender as ASPxComboBox;
    comboBox.DataSource = GetYourData();
    comboBox.TextField = "DisplayName";
    comboBox.ValueField = "ID";
    comboBox.DataBind();

    // 如果 Session 有儲存選擇值，就設回去
    if (Session["SelectedFilterValue"] != null)
    {
        comboBox.Value = Session["SelectedFilterValue"].ToString();
    }
}

注意：這段不要包在 !IsPostBack 裡，因為你希望每次都能設定值回去。

⸻

解法三：在 Client 端設定回選值（不推薦）

如果不想在後端處理，也可以在 Callback 成功後手動再設定 ComboBox 的值：

function OnComboBoxChanged(s, e) {
    var selectedValue = s.GetValue();
    cbComboCallback.PerformCallback(selectedValue);
    // 確保選項不會因畫面重繪被清掉
    cbxFilter.SetValue(selectedValue);
}

這是個補救方式，不過若後端還是重綁資料，這樣也會失效。

⸻

總結：建議做法
	1.	cbxFilter_Init 一律做 DataBind()，但一定要在 DataBind() 後設回 Value。
	2.	若資料只需要一次載入，可在 !IsPostBack 做 DataBind()，但要保證值可被記住。
	3.	不建議用 client-side 手動設值來解問題，除非前端完全控制選單資料。

⸻

如果你願意貼你的 cbxFilter_Init 實作，我可以幫你改成最安全的版本。