可以的！而且用 GridViewDataSpinEditColumn 搭配 GridViewDataComboBoxColumn 是更標準、也更好用的做法。
這樣你可以直接用 DevExpress Grid 的欄位類型來做，不用自己額外在 EditItemTemplate 放一堆控制項，取值也會更順。

⸻

✨ 你的需求整理
	•	數字：用 GridViewDataSpinEditColumn 讓使用者填「次數」
	•	數字：再一個 GridViewDataSpinEditColumn 填「每幾單位」
	•	單位（日、週）：用 GridViewDataComboBoxColumn 給使用者選

這樣就不用再自己組一個複合欄位。儲存時也很乾淨，直接從 e.NewValues["欄位名"] 拿數值。

⸻

🔥 實際作法

你的 GridView 可以這樣設：

<dx:ASPxGridView ID="ASPxGridView1" runat="server" ...>
    <Columns>
        <!-- 次數 -->
        <dx:GridViewDataSpinEditColumn FieldName="FREQ_COUNT" Caption="次數">
            <PropertiesSpinEdit MinValue="0" MaxValue="999" />
        </dx:GridViewDataSpinEditColumn>

        <!-- 單位數量 -->
        <dx:GridViewDataSpinEditColumn FieldName="FREQ_UNIT_COUNT" Caption="每幾單位">
            <PropertiesSpinEdit MinValue="1" MaxValue="999" />
        </dx:GridViewDataSpinEditColumn>

        <!-- 單位（日/週） -->
        <dx:GridViewDataComboBoxColumn FieldName="FREQ_UNIT" Caption="單位">
            <PropertiesComboBox>
                <Items>
                    <dx:ListEditItem Text="天" Value="Day" />
                    <dx:ListEditItem Text="週" Value="Week" />
                </Items>
            </PropertiesComboBox>
        </dx:GridViewDataComboBoxColumn>

        <!-- 其他欄位 -->
    </Columns>
</dx:ASPxGridView>



⸻

🎯 儲存時怎麼組 frequency？

因為你現在是三個欄位了（FREQ_COUNT, FREQ_UNIT_COUNT, FREQ_UNIT），所以在 RowInserting 或 RowUpdating 把它組成 FREQUENCY 字串存起來就可以：

protected void ASPxGridView1_RowInserting(object sender, ASPxDataInsertingEventArgs e)
{
    var freqCount = e.NewValues["FREQ_COUNT"]?.ToString();
    var freqUnitCount = e.NewValues["FREQ_UNIT_COUNT"]?.ToString();
    var freqUnit = e.NewValues["FREQ_UNIT"]?.ToString();

    e.NewValues["FREQUENCY"] = $"{freqCount}:{freqUnitCount} {freqUnit}";
}

（你也可以自己調格式，例如 3:2 Week）

然後如果資料庫只要存 FREQUENCY 一個欄位的話，可以選擇 不需要真的存 FREQ_COUNT、FREQ_UNIT_COUNT、FREQ_UNIT 三個欄位到資料庫，這三個只是 UI 輸入用的。

⸻

🧠 延伸小技巧

如果你一開始資料庫只有 FREQUENCY 欄位（組好的字串），那讀出來的時候可以在 RowEditing 時解析回去三個欄位，例如：

protected void ASPxGridView1_StartRowEditing(object sender, ASPxStartRowEditingEventArgs e)
{
    var grid = sender as ASPxGridView;
    var frequency = grid.GetRowValuesByKeyValue(e.EditingKeyValue, "FREQUENCY")?.ToString();

    if (!string.IsNullOrEmpty(frequency))
    {
        // 解析頻率字串，例如 "3:2 Week"
        var parts = frequency.Split(':', ' ');
        grid.JSProperties["cpFreqCount"] = parts[0];  // 3
        grid.JSProperties["cpFreqUnitCount"] = parts[1];  // 2
        grid.JSProperties["cpFreqUnit"] = parts[2];  // Week
    }
}

配合 ClientSideEvents 或重新指派控制項的值。

⸻

✨ 簡單總結

項目	原本做法	新做法
控制項	EditItemTemplate + 手動找 SpinEdit、ComboBox	GridViewDataSpinEditColumn + GridViewDataComboBoxColumn
取值方式	手動 FindEditRowCellTemplateControl	直接用 e.NewValues
儲存邏輯	自己組一個 FREQUENCY 字串	自己組一個 FREQUENCY 字串（簡單）
優點	使用者體驗普通，程式碼複雜	使用者體驗好，程式碼乾淨



⸻

要不要我順便幫你列一個完整小範例（包含新增、編輯、組字串、解析字串）？
如果要，我可以直接寫好一版你可以馬上貼去測試的！要不要？🎯