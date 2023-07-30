import postcss from 'postcss'
import autoprefixer from 'autoprefixer'
import cssnano from 'cssnano'
import { readFile, writeFile } from 'fs/promises'

const plugins = [autoprefixer]

if (process.env.NODE_ENV === 'production') {
  plugins.push(cssnano)
}

const processor = postcss(plugins)

const entryPoints = [
  {
    inputFilePath: './app/assets/builds/application.css',
    outputFilePath: './app/assets/builds/application.css',
  },
  {
    inputFilePath: './app/assets/builds/admin.css',
    outputFilePath: './app/assets/builds/admin.css',
  },
]

for (const entryPoint of entryPoints) {
  try {
    const data = await readFile(entryPoint.inputFilePath)
    const result = await processor.process(data, { from: undefined })
    await writeFile(entryPoint.outputFilePath, result.css)

    console.log('postcss build successful')
  } catch (err) {
    console.log(err)
    console.log('postcss build error')
  }
}
