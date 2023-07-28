module.exports = (ctx) => {
  return {
    map: ctx.options.map,
    plugins: {
      'postcss-import': {},
      'postcss-nesting': {},
      autoprefixer: {},
      cssnano: ctx.env === 'production' ? {} : false,
    },
  }
}
