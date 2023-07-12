module.exports = (ctx) => {
  return {
    map: ctx.options.map,
    plugins: {
      'postcss-import': {},
      'postcss-nesting': {},
      tailwindcss: {},
      autoprefixer: {},
      cssnano: ctx.env === 'production' ? {} : false,
    },
  }
}
