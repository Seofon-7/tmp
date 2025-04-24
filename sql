以下是一個完整範例，示範如何在 ASPxGridView（Inline 模式）中，只綁定「原始頻率」一個欄位，並在新增／更新時，後端一次做三種運算，然後把結果寫回對應欄位。

1. 資料庫欄位假設

欄位名稱	型別	用途
ID	int	主鍵
frequency	nvarchar	使用者輸入的頻率字串
unitValue	int	由 getFrequencyValue 計算出的值
unitCount	int	由 getFrequencyUnitCount 計算出的值
unitText	nvarchar	由 getFrequencyUnit 計算出的文字

2. ASPX（.aspx）GridView 定義

<dx:ASPxGridView ID="ASPxGridView1" runat="server"
    KeyFieldName="ID"
    DataSourceID="SqlDataSource1"
    AutoGenerateColumns="False"
    SettingsEditing-Mode="Inline"
    OnRowInserting="ASPxGridView1_RowInserting"
    OnRowUpdating="ASPxGridView1_RowUpdating"
    OnRowDeleting="ASPxGridView1_RowDeleting">
    <Columns>
        <dx:GridViewDataTextColumn FieldName="ID" Visible="False" />
        <!-- 只綁原始欄位 frequency -->
        <dx:GridViewDataColumn FieldName="frequency" Caption="頻率">
            <EditItemTemplate>
                <dx:ASPxTextBox ID="txtFreq" runat="server" 
                    Text='<%# Bind("frequency") %>' />
            </EditItemTemplate>
            <DataItemTemplate>
                <%# Eval("frequency") %>
            </DataItemTemplate>
        </dx:GridViewDataColumn>
        <!-- 顯示計算結果，不綁資料 -->
        <dx:GridViewDataTextColumn FieldName="unitValue" Caption="拆分後值" ReadOnly="True" />
        <dx:GridViewDataTextColumn FieldName="unitCount" Caption="單位數" ReadOnly="True" />
        <dx:GridViewDataTextColumn FieldName="unitText" Caption="單位文字" ReadOnly="True" />
        <!-- 編輯工具 -->
        <dx:GridViewCommandColumn ShowEditButton="True" ShowDeleteButton="True" />
    </Columns>
</dx:ASPxGridView>

<asp:SqlDataSource ID="SqlDataSource1" runat="server"
    ConnectionString="/* your connection string */"
    SelectCommand="SELECT ID, frequency, unitValue, unitCount, unitText FROM MyTable"
    InsertCommand="INSERT INTO MyTable(frequency, unitValue, unitCount, unitText) VALUES (@frequency, @unitValue, @unitCount, @unitText)"
    UpdateCommand="UPDATE MyTable SET frequency=@frequency, unitValue=@unitValue, unitCount=@unitCount, unitText=@unitText WHERE ID=@ID"
    DeleteCommand="DELETE FROM MyTable WHERE ID=@ID">
    <InsertParameters>
        <asp:Parameter Name="frequency" Type="String" />
        <asp:Parameter Name="unitValue" Type="Int32" />
        <asp:Parameter Name="unitCount" Type="Int32" />
        <asp:Parameter Name="unitText" Type="String" />
    </InsertParameters>
    <UpdateParameters>
        <asp:Parameter Name="frequency" Type="String" />
        <asp:Parameter Name="unitValue" Type="Int32" />
        <asp:Parameter Name="unitCount" Type="Int32" />
        <asp:Parameter Name="unitText" Type="String" />
        <asp:Parameter Name="ID" Type="Int32" />
    </UpdateParameters>
    <DeleteParameters>
        <asp:Parameter Name="ID" Type="Int32" />
    </DeleteParameters>
</asp:SqlDataSource>

3. Code-behind (C#)

using System;
using DevExpress.Web;
using DevExpress.Web.Data;

public partial class _YourPage : System.Web.UI.Page {
    protected void Page_Load(object sender, EventArgs e) {
        // ...
    }

    // 新增時
    protected void ASPxGridView1_RowInserting(object sender, ASPxDataInsertingEventArgs e) {
        ProcessFrequency(e.NewValues);
    }

    // 更新時
    protected void ASPxGridView1_RowUpdating(object sender, ASPxDataUpdatingEventArgs e) {
        ProcessFrequency(e.NewValues);
    }

    // 刪除（若無需額外邏輯，可留空或取消動作）
    protected void ASPxGridView1_RowDeleting(object sender, ASPxDataDeletingEventArgs e) {
        // e.Cancel = true; ASPxGridView1.DataBind(); // 如要取消刪除
    }

    // 共用：計算並填入三個衍生欄位
    private void ProcessFrequency(System.Collections.IDictionary values) {
        // 1. 取原始字串
        string freq = values["frequency"] as string ?? string.Empty;

        // 2. 呼叫你的運算函式
        //    這三支函式需自行定義在本 class 裡
        int val   = getFrequencyValue(freq);
        int count = getFrequencyUnitCount(freq);
        string unit = getFrequencyUnit(freq);

        // 3. 把結果塞回去
        values["unitValue"] = val;
        values["unitCount"] = count;
        values["unitText"]  = unit;
    }

    // ---- 以下為示範 stub（請用你自己的邏輯實做） ----

    // 拆頻率算數值
    private int getFrequencyValue(string freq) {
        // TODO: 你的拆解邏輯
        // 範例：把 "123Hz" 去掉 "Hz" 轉成 int
        if (int.TryParse(freq.Replace("Hz", ""), out int v)) return v;
        return 0;
    }

    // 算單位個數
    private int getFrequencyUnitCount(string freq) {
        // TODO: 你的單位數邏輯
        // 範例：如果 freq = "123Hz"，回傳 1
        return 1;
    }

    // 取單位文字
    private string getFrequencyUnit(string freq) {
        // TODO: 你的單位文字邏輯
        // 範例：從 freq 抽出 "Hz"
        return freq.EndsWith("Hz") ? "Hz" : string.Empty;
    }
}

重點說明
	1.	Inline 模式 下，只有綁在 GridViewDataColumn.FieldName 的欄位才會自動填進 e.NewValues。
	2.	ProcessFrequency 藉由 e.NewValues 拿到使用者輸入的 frequency，在後端做運算，再把結果手動塞回 unitValue、unitCount、unitText。
	3.	EditItemTemplate 裡只綁了一個控制項：txtFreq 綁同一個 frequency。顯示用的三個 DataTextColumn 都是只讀，用來顯示已算好的結果。
	4.	這樣既避免了前端多個 <%# Eval %>、也能集中在後端維護運算邏輯。

你可以將這整套範例貼到專案中，將 stub 的方法換成你的實際演算法，就能直接運作。任何問題再跟我說！