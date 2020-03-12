const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

environment.plugins.append(
  'ProvidePlugin-IntroJS',
  new webpack.ProvidePlugin({
    introJs: ['intro.js', 'introJs']
  })
)

environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery'
  })
)

module.exports = environment
