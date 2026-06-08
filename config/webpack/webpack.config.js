const path = require('path')
const { generateWebpackConfig } = require('shakapacker')
const { merge } = require('webpack-merge')

const stylesDir = path.resolve(__dirname, '../../app/assets/stylesheets')

const customConfig = {
  entry: {
    styles: [
      path.resolve(stylesDir, 'application.scss'),
      path.resolve(stylesDir, 'application.css'),
    ],
  },
  watchOptions: {
    ignored: /node_modules|public\/packs|app\/assets\/builds/,
  },
}

module.exports = merge(generateWebpackConfig(), customConfig)
