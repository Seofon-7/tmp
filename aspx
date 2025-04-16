// 將此代碼添加到Default.aspx頁面的<script>標籤中

// 頻率控件處理函數
function UpdateFrequency(s, e) {
    var count = txtFreqCount.GetValue();
    var unitCount = txtFreqUnitCount.GetValue();
    var unit = cmbFreqUnit.GetValue();
    
    var frequency = count + "次:" + unitCount + unit;
    return frequency;
}

// 表格行內編輯頻率處理
function OnFrequencyEdit(s, e) {
    var freqData = s.GetValue();
    if (!freqData) {
        return { count: 1, unitCount: 1, unit: "天" };
    }
    
    try {
        var parts = freqData.split(':');
        if (parts.length != 2) return { count: 1, unitCount: 1, unit: "天" };
        
        var countPart = parts[0].replace("次", "");
        var unitPart = parts[1];
        
        var count = parseInt(countPart) || 1;
        var unit = unitPart.includes("天") ? "天" : "週";
        var unitCount = parseInt(unitPart.replace("天", "").replace("週", "")) || 1;
        
        return { count: count, unitCount: unitCount, unit: unit };
    } catch (e) {
        return { count: 1, unitCount: 1, unit: "天" };
    }
}

// 表格行添加處理
function OnAfterAddRow(s, e) {
    // 設置默認值
    var keys = s.GetRowKey(s.GetFocusedRowIndex());
    if (keys) {
        s.batchEditApi.SetCellValue(keys, "Frequency", "1次:1天");
    }
}

// 創建確認刪除對話框
function ConfirmDelete(s, e) {
    if (confirm("確定要刪除這條記錄嗎?")) {
        // 繼續刪除操作
        gridToolRank.DeleteRow(gridToolRank.GetFocusedRowIndex());
    }
}

// 準備預填充數據
function PreparePrefillData() {
    // 獲取當前選中行的索引
    var focusedRowIndex = gridToolRank.GetFocusedRowIndex();
    
    // 如果有選中行，則預填充chp_grp和layer
    if (focusedRowIndex >= 0) {
        var chpGrp = gridToolRank.GetRowKey(focusedRowIndex);
        if (chpGrp) {
            cmbChpGrp.SetValue(chpGrp);
            
            // 獲取layer值
            var layer = gridToolRank.GetRowValues(focusedRowIndex, 'Layer', function(values) {
                if (values) {
                    txtLayer.SetValue(values);
                }
            });
        }
    } else {
        // 如果沒有選中行，則清空這些字段
        cmbChpGrp.SetValue(null);
        txtLayer.SetValue('');
    }
    
    // 其他字段設置為默認值
    txtOpeNo.SetValue('');
    txtPR.SetValue('');
    txtFreqCount.SetValue(1);
    txtFreqUnitCount.SetValue(1);
    cmbFreqUnit.SetValue('天');
}