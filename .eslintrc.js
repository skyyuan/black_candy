module.exports = {
  "parser": "babel-eslint",
  "extends": "airbnb-base",
  "rules": {
    "eqeqeq": "off",
    "no-new": "off",
    "comma-dangle": "off",
    "import/first": "off",
    "import/prefer-default-export": "off",
    "import/no-extraneous-dependencies": "off",
    "arrow-body-style": "off",
    "no-useless-escape": "off",
    "no-underscore-dangle": "off",
    "no-param-reassign": "off",
    "no-unused-expressions": "off",
    "class-methods-use-this": "off",
    "consistent-return": "off",
    "default-case": "off",
    "operator-linebreak": ["error", "after"]
  },
  "globals": {
    "document": true,
    "fetch": true,
    "window": true,
    "localStorage": true,
    "Event": true,
    "App": true,
    "Turbolinks": true,
    "CustomEvent": true
  }
};
