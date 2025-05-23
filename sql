SELECT 
    a.fab_id,
    a.dept,
    a.product_type,
    a.product_group,
    a.customer,
    COUNT(DISTINCT a.chipbody) AS chipbody_in_A,
    (
        SELECT COUNT(DISTINCT b.chipbody)
        FROM B b
        WHERE b.fab_id = a.fab_id
          AND b.dept = a.dept
          AND b.product_type = a.product_type
          AND b.product_group = a.product_group
          AND b.customer = a.customer
    ) AS chipbody_in_B
FROM A a
GROUP BY a.fab_id, a.dept, a.product_type, a.product_group, a.customer
ORDER BY a.fab_id, a.dept, a.product_type, a.product_group, a.customer;