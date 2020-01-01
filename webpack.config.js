const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const ManifestPlugin = require("webpack-manifest-plugin");
const SpriteLoaderPlugin = require('svg-sprite-loader/plugin');

module.exports = (env, argv) => {
  let isProd = argv.mode === "production";
  let extra = isProd ? ".cache.[chunkhash]" : "";
  process.env.NODE_ENV = argv.mode;

  return {
    entry: {
      main: "./client",
    },
    output: {
      filename: `[name]${extra}.js`,
    },
    module: {
      rules: [
        {
          test: /\.css$/,
          use: [
            {loader: MiniCssExtractPlugin.loader},
            "css-loader",
            {
              loader: "postcss-loader",
              options: {
                config: {
                  path: __dirname,
                },
              },
            },
          ],
        },
        {
          test: /\.svg$/,
          loader: 'svg-sprite-loader',
          options: {
            extract: true,
            spriteFilename: 'zondicons.svg',
          },
        },
      ],
    },

    plugins: [
      new MiniCssExtractPlugin({
        filename: `[name]${extra}.css`,
      }),
      new SpriteLoaderPlugin(),
      new ManifestPlugin(),
    ],
  };
};
