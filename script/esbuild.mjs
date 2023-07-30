import * as esbuild from 'esbuild'

const scriptArgs = process.argv.slice(2)

const esbuildConfig = {
  bundle: true,
  entryPoints: ['./app/javascript/application.js', './app/javascript/admin.js'],
  minify: process.env.NODE_ENV === 'production',
  outdir: './app/assets/builds',
  publicPath: '/assets',
  sourcemap: true,
}

const esbuildContext = await esbuild.context(esbuildConfig)

if (scriptArgs.includes('--watch')) {
  await esbuildContext.watch()
  console.log('watching...')
} else {
  esbuildContext.rebuild()
  esbuildContext.dispose()
}
