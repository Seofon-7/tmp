下面各給一個最小可跑的範例，分別對應 方案 A（運算全在後端）和 方案 B（Eval 結果走前端顯示，事件裡補 e.NewValues）。

方案 A：後端運算

1. ASPX（只綁 frequency，其餘只讀）

<dx:ASPxGridView ID="grid" runat="server"
    KeyFieldName="ID" DataSourceID="ds"
    AutoGenerateColumns="False" SettingsEditing-Mode="Inline"
    OnRowInserting="grid_RowInserting" OnRowUpdating="grid_RowUpdating">
  <Columns>
    <dx:GridViewDataTextColumn FieldName="ID" Visible="False" />
    <!-- 只綁原始頻率 -->
    <dx:GridViewDataColumn FieldName="frequency" Caption="頻率">
      <EditItemTemplate>
        <dx:ASPxTextBox ID="txtFreq" runat="server"
          Text='<%# Bind("frequency") %>' />
      </EditItemTemplate>
      <DataItemTemplate>
        <%# Eval("frequency") %>
      </DataItemTemplate>
    </dx:GridViewDataColumn>
    <!-- 只讀欄位顯示運算結果 -->
    <dx:GridViewDataTextColumn FieldName="unitValue" Caption="拆分後值" ReadOnly="True" />
    <dx:GridViewDataTextColumn FieldName="unitCount" Caption="單位數"  ReadOnly="True" />
    <dx:GridViewDataTextColumn FieldName="unitText"  Caption="單位文字" ReadOnly="True" />
    <dx:GridViewCommandColumn ShowEditButton="True" />
  </Columns>
</dx:ASPxGridView>

<asp:SqlDataSource ID="ds" runat="server"
    ConnectionString="/* conn */"
    SelectCommand="SELECT * FROM MyTable"
    InsertCommand="INSERT INTO MyTable(frequency,unitValue,unitCount,unitText) VALUES(@frequency,@unitValue,@unitCount,@unitText)"
    UpdateCommand="UPDATE MyTable SET frequency=@frequency,unitValue=@unitValue,unitCount=@unitCount,unitText=@unitText WHERE ID=@ID">
  <InsertParameters>
    <asp:Parameter Name="frequency" Type="String" />
    <asp:Parameter Name="unitValue" Type="Int32" />
    <asp:Parameter Name="unitCount" Type="Int32" />
    <asp:Parameter Name="unitText"  Type="String" />
  </InsertParameters>
  <UpdateParameters>
    <asp:Parameter Name="frequency" Type="String" />
    <asp:Parameter Name="unitValue" Type="Int32" />
    <asp:Parameter Name="unitCount" Type="Int32" />
    <asp:Parameter Name="unitText"  Type="String" />
    <asp:Parameter Name="ID"        Type="Int32" />
  </UpdateParameters>
</asp:SqlDataSource>

2. Code-behind

protected void grid_RowInserting(object sender, ASPxDataInsertingEventArgs e) {
    ComputeAll(e.NewValues);
}

protected void grid_RowUpdating(object sender, ASPxDataUpdatingEventArgs e) {
    ComputeAll(e.NewValues);
}

void ComputeAll(System.Collections.IDictionary vals) {
    string freq = vals["frequency"] as string ?? "";
    int   v    = getFrequencyValue(freq);
    int   cnt  = getFrequencyUnitCount(freq);
    string ut  = getFrequencyUnit(freq);
    vals["unitValue"] = v;
    vals["unitCount"] = cnt;
    vals["unitText"]  = ut;
}

// 你的計算函式 stub
int getFrequencyValue(string f){ return int.TryParse(f.Replace("Hz",""),out var x)?x:0; }
int getFrequencyUnitCount(string f){ return 1; }
string getFrequencyUnit(string f){ return f.EndsWith("Hz")?"Hz":""; }

方案 B：Eval 前端顯示 + 事件補值

1. ASPX（Eval 計算初值）

<dx:ASPxGridView ID="gridB" runat="server"
    KeyFieldName="ID" DataSourceID="dsB"
    AutoGenerateColumns="False" SettingsEditing-Mode="Inline"
    OnRowInserting="gridB_RowInserting" OnRowUpdating="gridB_RowUpdating">
  <Columns>
    <dx:GridViewDataTextColumn FieldName="ID" Visible="False" />
    <!-- 三個 control 都在同一欄位裡 Eval 初值 -->
    <dx:GridViewDataColumn FieldName="Dummy" Caption="三項">
      <EditItemTemplate>
        <dx:ASPxSpinEdit   ID="spinValue" runat="server"
          Value='<%# getFrequencyValue(Eval("frequency")) %>' />
        <dx:ASPxSpinEdit   ID="spinCount" runat="server"
          Value='<%# getFrequencyUnitCount(Eval("frequency")) %>' />
        <dx:ASPxComboBox   ID="cmbUnit" runat="server"
          Value='<%# getFrequencyUnit(Eval("frequency")) %>' />
      </EditItemTemplate>
      <DataItemTemplate>
        值：<%# Eval("unitValue") %>,
        數：<%# Eval("unitCount") %>,
        單位：<%# Eval("unitText") %>
      </DataItemTemplate>
    </dx:GridViewDataColumn>
    <!-- 別忘了真實頻率欄位也要綁 -->
    <dx:GridViewDataColumn FieldName="frequency" Visible="False" />
    <dx:GridViewCommandColumn ShowEditButton="True" />
  </Columns>
</dx:ASPxGridView>

<asp:SqlDataSource ID="dsB" runat="server" /*同上*/ />

2. Code-behind（補回 e.NewValues）

protected void gridB_RowInserting(object sender, ASPxDataInsertingEventArgs e) {
    FillFromControls(e.NewValues);
}

protected void gridB_RowUpdating(object sender, ASPxDataUpdatingEventArgs e) {
    FillFromControls(e.NewValues);
}

void FillFromControls(System.Collections.IDictionary vals) {
    // 隨便取一個有 FieldName 的 col 來找 template
    var col = gridB.Columns["Dummy"] as GridViewDataColumn;
    var sv  = gridB.FindEditRowCellTemplateControl(col, "spinValue") as ASPxSpinEdit;
    var sc  = gridB.FindEditRowCellTemplateControl(col, "spinCount") as ASPxSpinEdit;
    var cb  = gridB.FindEditRowCellTemplateControl(col, "cmbUnit") as ASPxComboBox;

    if (sv != null) vals["unitValue"] = sv.Value;
    if (sc != null) vals["unitCount"] = sc.Value;
    if (cb != null) vals["unitText"]  = cb.Value;
}

兩套範例分別對應「後端集中運算」與「前端 Eval 顯示＋事件補值」策略，請依需求選擇、並把欄位名稱／DataSource SQL 換成你專案裡的即可。