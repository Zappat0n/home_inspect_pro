const path = require('path')
const { generateWebpackConfig } = require('shakapacker')
const { merge } = require('webpack-merge')

const baseConfig = generateWebpackConfig()

const customConfig = {
  entry: {
    styles: path.resolve(__dirname, '../../app/assets/stylesheets/application.css'),
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          {
            loader: "postcss-loader",
          },
        ],
      },
    ],
  },
  stats: 'minimal',
  watchOptions: {
    ignored: /node_modules|public\/packs|app\/assets\/builds/,
  },
}

module.exports = merge(baseConfig, customConfig)
