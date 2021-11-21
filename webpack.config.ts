const path = require('path');

module.exports = {
  entry: "./src/index.ts",
  module: {
    rules: [
        {
            test: /\.(ts|js)?$/,
            exclude: /node_modules/,
            use: {
            loader: "babel-loader",
            options: {
                presets: ["@babel/preset-env", "@babel/preset-typescript"],
            },
            },
        },
    ],
  },
  resolve: {
    extensions: [".ts", ".js"],
  },
    output: {
        filename: "wallet.js",
        path: path.resolve(__dirname, 'web'),
        library: {
            name: "wallet",
            type: "this",
        },
    }
}
