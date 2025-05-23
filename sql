了解，你要找的是：

在 A 表中，找出 (fab_id, dept, product_type, product_group, customer) 為一組的資料，其中所有的 chipbody 都不曾出現在 B 表中相同的組別內。

這是更新後的 SQL：

⸻

只顯示符合條件的分組：

SELECT a.fab_id, a.dept, a.product_type, a.product_group, a.customer
FROM A a
GROUP BY a.fab_id, a.dept, a.product_type, a.product_group, a.customer
HAVING SUM(
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM B b
            WHERE b.fab_id = a.fab_id
              AND b.dept = a.dept
              AND b.product_type = a.product_type
              AND b.product_group = a.product_group
              AND b.customer = a.customer
              AND b.chipbody = a.chipbody
        )
        THEN 1 ELSE 0
    END
) = 0;


⸻

如果你想列出這些組別底下的所有 A 表資料：

SELECT *
FROM A a
WHERE (a.fab_id, a.dept, a.product_type, a.product_group, a.customer) IN (
    SELECT a2.fab_id, a2.dept, a2.product_type, a2.product_group, a2.customer
    FROM A a2
    GROUP BY a2.fab_id, a2.dept, a2.product_type, a2.product_group, a2.customer
    HAVING SUM(
        CASE 
            WHEN EXISTS (
                SELECT 1
                FROM B b
                WHERE b.fab_id = a2.fab_id
                  AND b.dept = a2.dept
                  AND b.product_type = a2.product_type
                  AND b.product_group = a2.product_group
                  AND b.customer = a2.customer
                  AND b.chipbody = a2.chipbody
            )
            THEN 1 ELSE 0
        END
    ) = 0
);


⸻

如果資料量大，建議幫 A 和 B 的 (fab_id, dept, product_type, product_group, customer, chipbody) 建 composite index，可以大幅提升效能。

有需要我幫你寫成可讀 view 或做 index 設計，也可以再說。