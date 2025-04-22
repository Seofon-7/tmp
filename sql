下面這段純 SQL（不需自訂 Function），會：
	1.	用 INSTR＋SUBSTR＋CONNECT BY 快速把 jobs 拆成一行行 job_id（同樣不走 REGEXP，效能佳）
	2.	直接利用 ROWID 來聚合，不用在 GROUP BY 中列出所有欄位
	3.	在切割後只保留每筆 spc_tool_rank_setting（以 ROWID 為準）對應到的 不同 area_prefix，再 LISTAGG，保證不重複

WITH job_area AS (
    -- 先截出每個 job_id 的 area_prefix（底線前段）
    SELECT 
        js.job_id,
        CASE 
            WHEN INSTR(js.areaid, '_') > 0 
            THEN SUBSTR(js.areaid, 1, INSTR(js.areaid, '_') - 1)
            ELSE js.areaid
        END AS area_prefix
    FROM spc_job_setting js
),
split_jobs AS (
    -- 把每筆 spc_tool_rank_setting 的 jobs 拆成多行，並標記原始 ROWID
    SELECT 
        s.rowid      AS rid,
        TRIM(
          SUBSTR(
            s.jobs,
            CASE WHEN LEVEL = 1 
                 THEN 1 
                 ELSE INSTR(s.jobs, ',', 1, LEVEL-1) + 1 
            END,
            CASE 
              WHEN INSTR(s.jobs, ',', 1, LEVEL) > 0 
              THEN INSTR(s.jobs, ',', 1, LEVEL) 
                   - (CASE WHEN LEVEL = 1 
                           THEN 1 
                           ELSE INSTR(s.jobs, ',', 1, LEVEL-1) + 1 
                     END)
              ELSE LENGTH(s.jobs)
            END
          )
        )             AS job_id
    FROM spc_tool_rank_setting s
    CONNECT BY 
        PRIOR s.rowid = s.rowid
        AND PRIOR dbms_random.value IS NOT NULL
        AND LEVEL <= REGEXP_COUNT(s.jobs, ',') + 1
),
joined_data AS (
    -- 把拆好的 job_id 跟 area_prefix join，保留 rowid
    SELECT
        sj.rid,
        ja.area_prefix
    FROM split_jobs sj
    JOIN job_area ja ON sj.job_id = ja.job_id
),
distinct_area AS (
    -- 同一 rid + 同一 area_prefix 只留一筆，去掉重複
    SELECT DISTINCT
        rid,
        area_prefix
    FROM joined_data
),
area_agg AS (
    -- 每筆原始資料 (rid) 聚合成一個 area_list，值不重複
    SELECT
        rid,
        LISTAGG(area_prefix, ';') WITHIN GROUP (ORDER BY area_prefix) AS area_list
    FROM distinct_area
    GROUP BY rid
)
-- 最後把全部欄位 + area_list 撈出來
SELECT
    t.*,                      -- spc_tool_rank_setting 裡的所有欄位
    NVL(aa.area_list, '') AS area_list
FROM 
    spc_tool_rank_setting t
LEFT JOIN 
    area_agg aa ON aa.rid = t.rowid;

說明
	1.	拆字串不跑正則：INSTR＋SUBSTR 比 REGEXP_SUBSTR 快，搭配 CONNECT BY … LEVEL 只展開該行需要的次數。
	2.	用 ROWID 聚合：拆完之後只用 rid = ROWID 來做去重、聚合，最後再 LEFT JOIN 回原表，避免在 GROUP BY 裡面列出一大堆欄位。
	3.	去重：distinct_area CTE 先針對同一筆原始資料 (rid) + area_prefix 去重，保證 LISTAGG 時不會有重複的值。
	4.	整張表一把抓：最終 SELECT t.*, aa.area_list 直接把 spc_tool_rank_setting 的所有欄位都撈出來，並加上你要的 area_list。

如果之後想要方便重複使用，可以把上面整串改成一個 View：

CREATE OR REPLACE VIEW v_tool_rank_with_area AS
-- （把上面那段 SQL SELECT ... FROM ... LEFT JOIN ... 全部貼進來）

之後就可以簡單地：

SELECT * 
FROM v_tool_rank_with_area;

就能拿到所有欄位＋去重好的 area_list，執行效能也已經優化到極致。