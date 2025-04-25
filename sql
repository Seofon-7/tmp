您提出了一个很好的问题。为什么 e.NewValues 可以取到其他列的值，但获取不到 frequency 这个列的值。这是因为 frequency 列的处理方式不同于其他列。我来解释一下原因：

### 问题根本原因

1. **标准列 vs 自定义模板列**：
   - 标准的 GridViewDataTextColumn 会自动将值收集到 e.NewValues 集合中
   - 而您的 frequency 列使用了 EditItemTemplate 定义了自定义的控件组合，而不是使用标准的绑定方式

2. **复合控件问题**：
   - frequency 列不是单一值，而是由三个不同的控件组合成的值(spinEditValue, spinEditUnitCount, comboBoxUnit)
   - DevExpress 框架不知道如何自动合并这三个控件的值到一个 frequency 字段

3. **内联编辑中的特殊处理**：
   - 在 RowUpdating 中，控件已经渲染并存在于DOM中，所以可以用 FindEditRowCellTemplateControl 找到
   - 在 RowInserting 中，处理逻辑不同，新行的控件处理方式与已有行的编辑不同

### 解决方案

首先，我们可以通过一个简单的方法来确认问题。在 RowInserting 事件中，让我们看看 e.NewValues 集合中到底有哪些值：

```csharp
protected void ASPxGridView1_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
{
    // 调试代码 - 查看 e.NewValues 集合中的所有键值对
    string allKeys = "";
    foreach (string key in e.NewValues.Keys)
    {
        allKeys += key + ": " + e.NewValues[key] + ", ";
    }
    // 可以记录到日志或使用其他方式查看这个值
    System.Diagnostics.Debug.WriteLine("新行插入的所有值: " + allKeys);
    
    // 继续其他处理...
}
```

针对您的问题，这里有几种可靠的解决方案：

#### 解决方案1：使用客户端脚本合并值

在 ASPX 页面中，为 GridView 添加客户端脚本，在提交前合并这些值：

```aspx
<dx:ASPxGridView ID="ASPxGridView1" runat="server" KeyFieldName="ID" 
    OnRowUpdating="ASPxGridView1_RowUpdating" 
    OnRowInserting="ASPxGridView1_RowInserting"
    Width="100%" AutoGenerateColumns="False">
    <ClientSideEvents BeforeInsert="function(s, e) {
        // 创建一个隐藏字段来存储合并后的值
        var value = spinEditValue.GetValue();
        var unitCount = spinEditUnitCount.GetValue();
        var unit = comboBoxUnit.GetValue();
        
        // 将合并后的值添加到 e.values
        e.values['frequency'] = value + '|' + unitCount + '|' + unit;
    }" />
    <!-- 其他设置 -->
</dx:ASPxGridView>
```

#### 解决方案2：使用隐藏字段合并值

在 EditItemTemplate 中添加一个隐藏字段，用于存储合并后的值：

```aspx
<EditItemTemplate>
    <div style="display: flex; align-items: center;">
        <!-- 频率值控件 -->
        <dx:ASPxSpinEdit ID="spinEditValue" runat="server" 
            Width="80px" 
            MinValue="1" 
            MaxValue="100" 
            Value='<%# GetFrequencyValue(Eval("frequency")) %>'
            ClientInstanceName="spinEditValue">
            <ClientSideEvents ValueChanged="function(s, e) { 
                UpdateFrequencyField();
            }" />
        </dx:ASPxSpinEdit>
        
        <!-- 频率单位数量控件 -->
        <dx:ASPxSpinEdit ID="spinEditUnitCount" runat="server" 
            Width="80px" 
            MinValue="1" 
            MaxValue="100" 
            Value='<%# GetFrequencyUnitCount(Eval("frequency")) %>'
            ClientInstanceName="spinEditUnitCount">
            <ClientSideEvents ValueChanged="function(s, e) { 
                UpdateFrequencyField();
            }" />
        </dx:ASPxSpinEdit>
        
        <!-- 频率单位控件 -->
        <dx:ASPxComboBox ID="comboBoxUnit" runat="server" 
            Width="100px" 
            Value='<%# GetFrequencyUnit(Eval("frequency")) %>'
            ClientInstanceName="comboBoxUnit">
            <ClientSideEvents SelectedIndexChanged="function(s, e) { 
                UpdateFrequencyField();
            }" />
            <Items>
                <dx:ListEditItem Text="秒" Value="second" />
                <dx:ListEditItem Text="分钟" Value="minute" />
                <dx:ListEditItem Text="小时" Value="hour" />
                <dx:ListEditItem Text="天" Value="day" />
                <dx:ListEditItem Text="周" Value="week" />
                <dx:ListEditItem Text="月" Value="month" />
            </Items>
        </dx:ASPxComboBox>
        
        <!-- 隐藏字段存储合并后的值 -->
        <dx:ASPxTextBox ID="hiddenFrequency" runat="server" 
            ClientInstanceName="hiddenFrequency" 
            ClientVisible="false"
            Value='<%# Eval("frequency") %>'
            Name="frequency">
        </dx:ASPxTextBox>
    </div>
    
    <script type="text/javascript">
        function UpdateFrequencyField() {
            var value = spinEditValue.GetValue();
            var unitCount = spinEditUnitCount.GetValue();
            var unit = comboBoxUnit.GetValue();
            hiddenFrequency.SetValue(value + '|' + unitCount + '|' + unit);
        }
    </script>
</EditItemTemplate>
```

然后在后台代码中，e.NewValues 应该能够获取到这个隐藏字段的值。

#### 解决方案3：使用 DataItemTemplate 而不是 EditItemTemplate

您可以使用 DataItemTemplate 而不是 EditItemTemplate，这样可以确保值正确绑定：

```aspx
<dx:GridViewDataTextColumn FieldName="frequency" Caption="频率" Width="200">
    <DataItemTemplate>
        <div style="display: flex; align-items: center;">
            <dx:ASPxSpinEdit ID="spinEditValue" runat="server" 
                Width="80px" 
                MinValue="1" 
                MaxValue="100" 
                Value='<%# GetFrequencyValue(Eval("frequency")) %>'
                ClientInstanceName="spinEditValue">
            </dx:ASPxSpinEdit>
            
            <!-- 其他控件 -->
        </div>
    </DataItemTemplate>
</dx:GridViewDataTextColumn>
```

#### 解决方案4：在页面加载时注册控件事件处理

在页面加载时为这些控件添加事件处理程序，以便在值更改时将其保存到静态变量或会话状态：

```csharp
protected void Page_Load(object sender, EventArgs e)
{
    if (!IsPostBack)
    {
        // 绑定数据源
        BindGridView();
    }
    
    // 注册新行模板控件的事件处理程序
    ASPxGridView1.InitNewRow += ASPxGridView1_InitNewRow;
}

protected void ASPxGridView1_InitNewRow(object sender, EventArgs e)
{
    // 找到新行的控件并注册事件处理程序
    ASPxGridView grid = sender as ASPxGridView;
    ASPxSpinEdit spinEditValue = FindControlRecursive(grid, "spinEditValue") as ASPxSpinEdit;
    if (spinEditValue != null)
    {
        spinEditValue.ValueChanged += (s, args) => {
            Session["TempFrequencyValue"] = ((ASPxSpinEdit)s).Value;
        };
    }
    
    // 也为其他控件注册类似的事件处理程序
}

// 在 RowInserting 事件中
protected void ASPxGridView1_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
{
    // 从会话中获取临时保存的值
    object value = Session["TempFrequencyValue"];
    object unitCount = Session["TempFrequencyUnitCount"];
    object unit = Session["TempFrequencyUnit"];
    
    if (value != null && unitCount != null && unit != null)
    {
        e.NewValues["frequency"] = string.Format("{0}|{1}|{2}", value, unitCount, unit);
    }
    else
    {
        // 使用默认值
        e.NewValues["frequency"] = "1|1|day";
    }
    
    // 其他处理...
}
```

#### 解决方案5：使用 DevExpress 的命令按钮代替自动提交

您可以禁用自动提交，改为使用自定义按钮来提交：

```aspx
<dx:ASPxGridView ID="ASPxGridView1" runat="server" KeyFieldName="ID" 
    OnRowUpdating="ASPxGridView1_RowUpdating" 
    OnRowInserting="ASPxGridView1_RowInserting"
    Width="100%" AutoGenerateColumns="False">
    <SettingsEditing Mode="Inline" NewItemRowPosition="Top" />
    <Templates>
        <NewRow>
            <!-- 自定义新行模板 -->
            <div>
                <dx:ASPxSpinEdit ID="spinEditValue" runat="server" Width="80px" MinValue="1" MaxValue="100" Value="1"></dx:ASPxSpinEdit>
                <dx:ASPxSpinEdit ID="spinEditUnitCount" runat="server" Width="80px" MinValue="1" MaxValue="100" Value="1"></dx:ASPxSpinEdit>
                <dx:ASPxComboBox ID="comboBoxUnit" runat="server" Width="100px" Value="day">
                    <Items>
                        <dx:ListEditItem Text="秒" Value="second" />
                        <!-- 其他选项 -->
                    </Items>
                </dx:ASPxComboBox>
                
                <dx:ASPxButton ID="btnInsert" runat="server" Text="插入" AutoPostBack="true" 
                    OnClick="btnInsert_Click">
                </dx:ASPxButton>
            </div>
        </NewRow>
    </Templates>
    <!-- 其他设置 -->
</dx:ASPxGridView>
```

然后在后台代码中实现按钮的点击事件：

```csharp
protected void btnInsert_Click(object sender, EventArgs e)
{
    ASPxButton btn = sender as ASPxButton;
    if (btn != null)
    {
        // 找到控件
        ASPxSpinEdit spinEditValue = FindControlRecursive(btn.Parent, "spinEditValue") as ASPxSpinEdit;
        ASPxSpinEdit spinEditUnitCount = FindControlRecursive(btn.Parent, "spinEditUnitCount") as ASPxSpinEdit;
        ASPxComboBox comboBoxUnit = FindControlRecursive(btn.Parent, "comboBoxUnit") as ASPxComboBox;
        
        if (spinEditValue != null && spinEditUnitCount != null && comboBoxUnit != null)
        {
            // 创建新行数据
            string frequencyStr = string.Format("{0}|{1}|{2}", 
                spinEditValue.Value, 
                spinEditUnitCount.Value, 
                comboBoxUnit.Value);
            
            // 添加到数据源
            DataTable dt = ViewState["GridData"] as DataTable;
            if (dt != null)
            {
                DataRow row = dt.NewRow();
                row["ID"] = dt.Rows.Count + 1;
                row["Name"] = "新任务";  // 您可能需要从其他控件获取
                row["frequency"] = frequencyStr;
                dt.Rows.Add(row);
                
                ViewState["GridData"] = dt;
                ASPxGridView1.DataSource = dt;
                ASPxGridView1.DataBind();
            }
        }
    }
}
```

这些解决方案中，最简单且最可靠的是方案2（使用隐藏字段）和方案1（使用客户端脚本）。您可以根据您的项目需求选择适合您的解决方案。​​​​​​​​​​​​​​​​