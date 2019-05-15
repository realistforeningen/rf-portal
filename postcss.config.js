const purgecss = require('@fullhuman/postcss-purgecss')({
  content: [
    './app/**/*.rb',
  ],

  // We need to include : and / which Tailwind uses
  defaultExtractor: content => content.match(/[A-Za-z0-9-_:/]+/g) || []
});

module.exports = ({env,}) => {
  return {
    plugins: [
      require("tailwindcss"),
      env === 'production' && purgecss,
      env === 'production' && require("cssnano"),
    ]
  };
};
