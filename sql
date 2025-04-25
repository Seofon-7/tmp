了解了，你的需求是這樣的：
	•	只有一個資料欄位 frequency，但
	•	讓使用者用三個輸入欄位（次數、數量、單位）來輸入這個值，例如：3 次 / 2 天 → 3,2,Day。

這其實是很常見的「複合欄位編輯」情境。既然你想保留這個結構（單欄顯示多個輸入），那我們可以採取這樣的方式來處理：

⸻

最推薦解法：在 RowInserting 裡仍可取得控制項的值，關鍵是：
	1.	確認你是在 Inline Edit 模式下運作（不是 EditForm）
	2.	確認你使用的 GridViewDataColumn 的 FieldName 是正確的
	3.	使用 FindEditRowCellTemplateControl() 要指定對的欄位（就是設定了 FieldName="frequency" 的欄位）

⸻

範例：完整支援 Inline Insert 複合欄位的方式

1. GridView 標記（只貼 frequency 欄位）

<dx:GridViewDataColumn FieldName="frequency" Caption="頻率">
    <EditItemTemplate>
        <div style="display:flex;gap:5px;">
            <dx:ASPxSpinEdit ID="spnValue" runat="server" Width="50px" />
            <dx:ASPxSpinEdit ID="spnCount" runat="server" Width="50px" />
            <dx:ASPxComboBox ID="cmbUnit" runat="server" Width="80px">
                <Items>
                    <dx:ListEditItem Text="天" Value="Day" />
                    <dx:ListEditItem Text="週" Value="Week" />
                    <dx:ListEditItem Text="月" Value="Month" />
                </Items>
            </dx:ASPxComboBox>
        </div>
    </EditItemTemplate>
</dx:GridViewDataColumn>

2. 後端程式碼：RowInserting

protected void ASPxGridView1_RowInserting(object sender, ASPxDataInsertingEventArgs e)
{
    var grid = sender as ASPxGridView;

    // 必須對應欄位名稱 "frequency"
    var spnValue = grid.FindEditRowCellTemplateControl(
        (GridViewDataColumn)grid.Columns["frequency"], "spnValue") as ASPxSpinEdit;
    var spnCount = grid.FindEditRowCellTemplateControl(
        (GridViewDataColumn)grid.Columns["frequency"], "spnCount") as ASPxSpinEdit;
    var cmbUnit = grid.FindEditRowCellTemplateControl(
        (GridViewDataColumn)grid.Columns["frequency"], "cmbUnit") as ASPxComboBox;

    if (spnValue != null && spnCount != null && cmbUnit != null)
    {
        string freq = $"{spnValue.Value},{spnCount.Value},{cmbUnit.Value}";
        e.NewValues["frequency"] = freq;
    }
}



⸻

關鍵排查建議

如果這樣你還是抓不到控制項：
	•	請確認 frequency 欄位的 FieldName 真的叫 frequency，與你程式碼一致。
	•	請確認你使用的是 Inline 模式（而不是 EditForm）
	•	確保你的 ASPxGridView 沒有設定 AutoGenerateColumns="True"（會導致找不到欄位）
	•	確認你沒有在 InitNewRow 裡意外地清掉控制項或值

⸻

如果你還是抓不到，我可以幫你看更具體的問題，你只需要提供：
	•	ASPxGridView 的完整欄位定義
	•	你如何啟用 Insert 模式的（例如按鈕或 StartEditNewRow()）

這樣我就可以直接幫你定位出為什麼抓不到。你要不要貼上來？