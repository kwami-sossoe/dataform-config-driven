const rules = {
  isValidPer100g: (col) => `${col} >= 0 AND ${col} <= 105`,
  isValidNutriScore: (col) => `${col} IN ('A', 'B', 'C', 'D', 'E') OR ${col} IS NULL`,
  isValidEnergy: (col) => `${col} >= 0 AND ${col} <= 9000`, // Adjusted max energy
};
module.exports = rules;
