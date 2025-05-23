SELECT a.fab, a.type, a.dept
FROM A a
GROUP BY a.fab, a.type, a.dept
HAVING COUNT(*) = (
    SELECT COUNT(*)
    FROM A a2
    WHERE a2.fab = a.fab
      AND a2.type = a.type
      AND a2.dept = a.dept
      AND NOT EXISTS (
          SELECT 1
          FROM B b
          WHERE b.fab = a2.fab
            AND b.type = a2.type
            AND b.dept = a2.dept
            AND b.chip = a2.chip
      )
);