module.exports = ({env}) => {

  return {
    plugins: [
      require("tailwindcss"),
      env === 'production' && require("cssnano")
    ]
  };
};