import { compile } from 'sass'
import { writeFile } from 'fs/promises'

const sassOptions = {
  style: 'expanded',
  sourceMap: false,
  loadPaths: ['node_modules'],
}

const entryPoints = [
  {
    inputFilePath: './app/assets/stylesheets/application.scss',
    outputFilePath: './app/assets/builds/application.css',
  },
  {
    inputFilePath: './app/assets/stylesheets/admin.scss',
    outputFilePath: './app/assets/builds/admin.css',
  },
]

for (const entryPoint of entryPoints) {
  try {
    const result = compile(entryPoint.inputFilePath, sassOptions)
    await writeFile(entryPoint.outputFilePath, result.css)

    console.log('sass build successful')
  } catch (err) {
    console.log(err)
    console.log('sass build error')
  }
}
