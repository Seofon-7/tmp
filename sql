-- 方法1: 使用NOT EXISTS (修正版)
-- 找出A table中存在，但該組別下的chipbody與B table完全沒有交集的組別
SELECT DISTINCT 
    a.fab_id,
    a.dept,
    a.product_type,
    a.product_group,
    a.customer
FROM table_a a
WHERE EXISTS (
    -- 確保B table中也有相同的組別
    SELECT 1 
    FROM table_b b 
    WHERE b.fab_id = a.fab_id
      AND b.dept = a.dept
      AND b.product_type = a.product_type
      AND b.product_group = a.product_group
      AND b.customer = a.customer
)
AND NOT EXISTS (
    -- 但是A table的任何chipbody都不能與B table的chipbody相同
    SELECT 1
    FROM table_a a2
    INNER JOIN table_b b2 ON a2.chipbody = b2.chipbody
    WHERE a2.fab_id = a.fab_id
      AND a2.dept = a.dept
      AND a2.product_type = a.product_type
      AND a2.product_group = a.product_group
      AND a2.customer = a.customer
      AND b2.fab_id = a.fab_id
      AND b2.dept = a.dept
      AND b2.product_type = a.product_type
      AND b2.product_group = a.product_group
      AND b2.customer = a.customer
);

-- 方法2: 使用集合運算
-- 先找出兩個table都存在的組別，再排除有chipbody交集的組別
WITH common_groups AS (
    -- 兩個table都存在的組別
    SELECT DISTINCT fab_id, dept, product_type, product_group, customer
    FROM table_a
    INTERSECT
    SELECT DISTINCT fab_id, dept, product_type, product_group, customer
    FROM table_b
),
overlapping_groups AS (
    -- 有chipbody重疊的組別
    SELECT DISTINCT 
        a.fab_id, a.dept, a.product_type, a.product_group, a.customer
    FROM table_a a
    INNER JOIN table_b b ON a.chipbody = b.chipbody
                        AND a.fab_id = b.fab_id
                        AND a.dept = b.dept
                        AND a.product_type = b.product_type
                        AND a.product_group = b.product_group
                        AND a.customer = b.customer
)
SELECT * FROM common_groups
MINUS
SELECT * FROM overlapping_groups;

-- 方法3: 使用子查詢和聚合 (更清楚的邏輯)
SELECT 
    cg.fab_id,
    cg.dept,
    cg.product_type,
    cg.product_group,
    cg.customer
FROM (
    -- 兩個table都存在的組別
    SELECT DISTINCT fab_id, dept, product_type, product_group, customer
    FROM table_a
    INTERSECT
    SELECT DISTINCT fab_id, dept, product_type, product_group, customer
    FROM table_b
) cg
WHERE NOT EXISTS (
    -- 檢查是否有chipbody交集
    SELECT 1
    FROM (
        SELECT chipbody
        FROM table_a
        WHERE fab_id = cg.fab_id
          AND dept = cg.dept
          AND product_type = cg.product_type
          AND product_group = cg.product_group
          AND customer = cg.customer
        INTERSECT
        SELECT chipbody
        FROM table_b
        WHERE fab_id = cg.fab_id
          AND dept = cg.dept
          AND product_type = cg.product_type
          AND product_group = cg.product_group
          AND customer = cg.customer
    )
);