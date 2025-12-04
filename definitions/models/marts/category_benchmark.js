const config = require("includes/config_loader");

publish("category_benchmark", {
    ...config.marts.category_benchmark
})
.dependencies(["stg_off_products"])
.query(ctx => `
    SELECT
      main_category,
      COUNT(code) as total_products,
      ROUND(AVG(sugars_100g), 2) as avg_sugar,
      ROUND(
        COUNTIF(nutriscore_grade = 'A') / NULLIF(COUNT(code), 0) * 100, 
      2) as pct_nutriscore_a
    FROM
      ${ctx.ref("stg_off_products")}
    GROUP BY 1
    HAVING total_products > 10
    ORDER BY avg_sugar DESC
`);
