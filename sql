了解，你希望在 Oracle 11g 中，不改變原有 SQL 邏輯結構（即保留 LISTAGG 的串接方式），但又要 移除像 FR,FR;PR 這種結果中出現的重複值。由於 Oracle 11g 不支援 LISTAGG(DISTINCT ...)，這種情況可以使用一種替代方法來處理：先用 COLLECT + CAST(MULTISET) 聚合去重，再排序串接。

✅ 解法：使用 XMLAGG + DISTINCT + ORDER BY 模擬 LISTAGG(DISTINCT) 效果

這段 SQL 將會模擬 LISTAGG(DISTINCT c.class, ',') 的效果（Oracle 11g 可用）：

SELECT
    RTRIM(XMLAGG(XMLELEMENT(e, class || ',') ORDER BY class).EXTRACT('//text()'), ',') AS class_list
FROM (
    SELECT DISTINCT c.class
    FROM fmea_report c
) t;

這段 SQL 的重點：
	•	SELECT DISTINCT c.class：先從 fmea_report 表裡取出不重複的 class 值。
	•	XMLAGG + XMLELEMENT：把這些值拼接起來，模擬 LISTAGG 效果。
	•	RTRIM(..., ',')：去除最後多餘的逗號。

⸻

如果你原本 SQL 是這樣：

SELECT regexp_replace(
    listagg(c.class , ',') within group (order by c.class),
    '(([^,]+)(,\1)*(,|$)',
    '\1\3'
) AS result
FROM fmea_report c;

但你想讓 listagg(c.class, ',') 的結果是 不重複的 class 字串，那可以改寫成這樣：

SELECT regexp_replace(
    RTRIM(
        XMLAGG(XMLELEMENT(e, class || ',') ORDER BY class).EXTRACT('//text()'),
        ','
    ),
    '(([^,]+)(,\2)+)',
    '\2'
) AS result
FROM (
    SELECT DISTINCT c.class
    FROM fmea_report c
) t;


⸻

範例說明：

假設 fmea_report 中的 class 資料如下：

class
FR
PR
FR

那麼這段 SQL 的執行結果會是：

FR,PR

或如果你後續用分號 ; 做分群，也可以：

REPLACE(
    RTRIM(
        XMLAGG(XMLELEMENT(e, class || ';') ORDER BY class).EXTRACT('//text()'),
        ';'
    ),
    ',',
    ';'
)


⸻

小結
	•	✅ 適用 Oracle 11g，不支援 LISTAGG(DISTINCT) 的限制。
	•	✅ 不需要更動你太多原本的 SQL 結構。
	•	✅ 可處理像 FR,FR;PR 這種重複的情況，將其去重為 FR;PR。

如果你有更複雜的分組條件（例如還需要 GROUP BY report_id 這類），我也可以幫你調整。只要提供具體結構。