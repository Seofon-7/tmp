你觀察得沒錯！前面的寫法雖然加上了 HAVING SUM(...) = 0，但 Oracle 的 GROUP BY 是針對 A 表的欄位來分組，而 HAVING EXISTS (...) 子查詢是對 A 表中的每一列來判斷，並非整組 chip 是否有交集。這導致只要同一組別裡 某些 chip 沒出現在 B 表中，就會讓 SUM(...) = 0 成立，這不是我們要的行為。

⸻

你的目標重新定義：

僅列出 A 表中某些 (fab_id, dept, product_type, product_group, customer) 組合，其所有 chipbody 都不曾出現在 B 表中相同的組合內。

這邏輯其實可以分成以下步驟：
	1.	找出 A 表每組 (fab_id, dept, product_type, product_group, customer) 對應的所有 chipbody。
	2.	比對這些 chipbody 是否在 B 表中同樣組合中出現過。
	3.	若一個都沒出現，這組就要被選出來。

⸻

正確寫法：使用 NOT EXISTS 搭配整組比對

SELECT DISTINCT a.fab_id, a.dept, a.product_type, a.product_group, a.customer
FROM A a
WHERE NOT EXISTS (
    SELECT 1
    FROM B b
    WHERE b.fab_id = a.fab_id
      AND b.dept = a.dept
      AND b.product_type = a.product_type
      AND b.product_group = a.product_group
      AND b.customer = a.customer
      AND b.chipbody IN (
          SELECT a2.chipbody
          FROM A a2
          WHERE a2.fab_id = a.fab_id
            AND a2.dept = a.dept
            AND a2.product_type = a.product_type
            AND a2.product_group = a.product_group
            AND a2.customer = a.customer
      )
);


⸻

為什麼這樣才對？
	•	這個查詢會檢查：對於 A 表中的每一組 (fab_id, dept, product_type, product_group, customer)，是否存在任何一筆 chipbody 有在 B 表中出現。
	•	只要 B 表中有一筆 chipbody 和 A 相同組別、相同 chipbody，就會被排除。
	•	所以最終留下的就是「完全沒有 chipbody 重疊」的組別。

⸻

如果你還想要這些組別下的所有 A 表資料：

SELECT *
FROM A a
WHERE (a.fab_id, a.dept, a.product_type, a.product_group, a.customer) IN (
    SELECT a2.fab_id, a2.dept, a2.product_type, a2.product_group, a2.customer
    FROM A a2
    WHERE NOT EXISTS (
        SELECT 1
        FROM B b
        WHERE b.fab_id = a2.fab_id
          AND b.dept = a2.dept
          AND b.product_type = a2.product_type
          AND b.product_group = a2.product_group
          AND b.customer = a2.customer
          AND b.chipbody IN (
              SELECT a3.chipbody
              FROM A a3
              WHERE a3.fab_id = a2.fab_id
                AND a3.dept = a2.dept
                AND a3.product_type = a2.product_type
                AND a3.product_group = a2.product_group
                AND a3.customer = a2.customer
          )
    )
);


⸻

這樣寫會準確過濾掉任何 chipbody 有交集的組別。如果你有上萬筆資料，可以考慮建立複合索引在：

(fab_id, dept, product_type, product_group, customer, chipbody)

讓查詢效率大幅提升。

需要我幫你做 Explain Plan 或 Materialized View 優化也可以說一聲。