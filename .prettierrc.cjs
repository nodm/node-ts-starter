module.exports = {
  ...require('gts/.prettierrc.json'),
  plugins: ['@trivago/prettier-plugin-sort-imports'],
  bracketSpacing: true,
  arrowParens: 'always',
  importOrder: ['^node:/(.*)$', '^[./]'],
  importOrderSeparation: true,
  importOrderSortSpecifiers: true,
};
