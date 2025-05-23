-- 方法1: 使用NOT EXISTS
SELECT DISTINCT 
    a.fab_id,
    a.dept,
    a.product_type,
    a.product_group,
    a.customer
FROM table_a a
WHERE NOT EXISTS (
    SELECT 1
    FROM table_a a2
    INNER JOIN table_b b ON a2.chipbody = b.chipbody
    WHERE a2.fab_id = a.fab_id
      AND a2.dept = a.dept
      AND a2.product_type = a.product_type
      AND a2.product_group = a.product_group
      AND a2.customer = a.customer
      AND b.fab_id = a.fab_id
      AND b.dept = a.dept
      AND b.product_type = a.product_type
      AND b.product_group = a.product_group
      AND b.customer = a.customer
);

-- 方法2: 使用MINUS (Oracle特有)
SELECT DISTINCT
    fab_id,
    dept,
    product_type,
    product_group,
    customer
FROM (
    -- A table的所有組別
    SELECT DISTINCT 
        fab_id, dept, product_type, product_group, customer
    FROM table_a
    
    MINUS
    
    -- 有chipbody重疊的組別
    SELECT DISTINCT 
        a.fab_id, a.dept, a.product_type, a.product_group, a.customer
    FROM table_a a
    INNER JOIN table_b b ON a.chipbody = b.chipbody
    WHERE a.fab_id = b.fab_id
      AND a.dept = b.dept
      AND a.product_type = b.product_type
      AND a.product_group = b.product_group
      AND a.customer = b.customer
);

-- 方法3: 使用GROUP BY和聚合函數 (如果你想看到更詳細的統計)
SELECT 
    a.fab_id,
    a.dept,
    a.product_type,
    a.product_group,
    a.customer,
    COUNT(DISTINCT a.chipbody) as a_chipbody_count,
    COUNT(DISTINCT b.chipbody) as b_chipbody_count,
    COUNT(DISTINCT CASE WHEN b.chipbody IS NOT NULL THEN a.chipbody END) as overlap_count
FROM table_a a
LEFT JOIN table_b b ON a.fab_id = b.fab_id
                   AND a.dept = b.dept
                   AND a.product_type = b.product_type
                   AND a.product_group = b.product_group
                   AND a.customer = b.customer
                   AND a.chipbody = b.chipbody
GROUP BY a.fab_id, a.dept, a.product_type, a.product_group, a.customer
HAVING COUNT(DISTINCT CASE WHEN b.chipbody IS NOT NULL THEN a.chipbody END) = 0;