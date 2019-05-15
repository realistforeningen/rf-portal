const {resolve} = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const ManifestPlugin = require("webpack-manifest-plugin");

module.exports = (env, argv) => {
  let isProd = argv.mode === "production";
  let extra = isProd ? "-[hash]" : "";
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
      ],
    },

    plugins: [
      new MiniCssExtractPlugin({
        filename: `[name]${extra}.css`,
      }),
      new ManifestPlugin(),
    ],
  };
};
