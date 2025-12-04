const config = {
  staging: {
    stg_off_products: require("../definitions/schemas/staging/stg_off_products.json"),
  },
  marts: {
    category_benchmark: require("../definitions/schemas/marts/category_benchmark.json"),
  },
};
module.exports = config;
