#!/bin/bash

# ----------------------
# Color Variables
# ----------------------
RED="\033[0;31m"
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
LCYAN='\033[1;36m'
NC='\033[0m' # No Color

# --------------------------------------
# Prompts for configuration preferences
# --------------------------------------

# Package Manager Prompt
echo
echo "Which package manager are you using?"
select package_command_choices in "Yarn" "npm" "Cancel"; do
  case $package_command_choices in
    Yarn ) pkg_cmd='yarn add'; break;;
    npm ) pkg_cmd='npm install'; break;;
    Cancel ) exit;;
  esac
done
echo

# File Format Prompt
echo "Which ESLint and Prettier configuration format do you prefer?"
select config_extension in ".js" ".json" "Cancel"; do
  case $config_extension in
    .js ) config_opening='module.exports = {'; break;;
    .json ) config_opening='{'; break;;
    Cancel ) exit;;
  esac
done
echo

# Checks for existing eslintrc files
if [ -f ".eslintrc.js" -o -f ".eslintrc.yaml" -o -f ".eslintrc.yml" -o -f ".eslintrc.json" -o -f ".eslintrc" ]; then
  echo -e "${RED}Existing ESLint config file(s) found:${NC}"
  ls -a .eslint* | xargs -n 1 basename
  echo
  echo -e "${RED}CAUTION:${NC} there is loading priority when more than one config file is present: https://eslint.org/docs/user-guide/configuring#configuration-file-formats"
  echo
  read -p  "Write .eslintrc${config_extension} (Y/n)? "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}>>>>> Skipping ESLint config${NC}"
    skip_eslint_setup="true"
  fi
fi
finished=false

# Max Line Length Prompt
while ! $finished; do
  read -p "What max line length do you want to set for ESLint and Prettier? (Recommendation: 100)"
  if [[ $REPLY =~ ^[0-9]{2,3}$ ]]; then
    max_len_val=$REPLY
    finished=true
    echo
  else
    echo -e "${YELLOW}Please choose a max length of two or three digits, e.g. 80 or 100 or 120${NC}"
  fi
done

# Trailing Commas Prompt
echo "What style of trailing commas do you want to enforce with Prettier?"
echo -e "${YELLOW}>>>>> See https://prettier.io/docs/en/options.html#trailing-commas for more details.${NC}"
select trailing_comma_pref in "none" "es5" "all"; do
  case $trailing_comma_pref in
    "none" ) break;;
    "es5" ) break;;
    "all" ) break;;
  esac
done
echo

# Checks for existing prettierrc files
if [ -f ".prettierrc.js" -o -f "prettier.config.js" -o -f ".prettierrc.yaml" -o -f ".prettierrc.yml" -o -f ".prettierrc.json" -o -f ".prettierrc.toml" -o -f ".prettierrc" -o -f ".prettierrc" ]; then
  echo -e "${RED}Existing Prettier config file(s) found${NC}"
  ls -a | grep "prettier*" | xargs -n 1 basename
  echo
  echo -e "${RED}CAUTION:${NC} The configuration file will be resolved starting from the location of the file being formatted, and searching up the file tree until a config file is (or isn't) found. https://prettier.io/docs/en/configuration.html"
  echo
  read -p  "Write .prettierrc${config_extension} (Y/n)? "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}>>>>> Skipping Prettier config${NC}"
    skip_prettier_setup="true"
  fi
  echo
fi

# Checks for existing stylelint files
if [ -f ".stylelintrc.js" -o -f "stylelintrc.config.js" -o -f ".stylelintrc.yaml" -o -f ".stylelintrc.yml" -o -f ".stylelintrc.json" -o -f ".stylelintrc.toml" -o -f ".stylelintrc" -o -f ".stylelintrc" ]; then
  echo -e "${RED}Existing Stylelint config file(s) found${NC}"
  ls -a | grep "stylelint*" | xargs -n 1 basename
  echo
  echo -e "${RED}CAUTION:${NC} The configuration file will be resolved starting from the location of the file being formatted, and searching up the file tree until a config file is (or isn't) found. https://stylelint.io/user-guide/configure"
  echo
  read -p  "Write .stylelintrc${config_extension} (Y/n)? "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}>>>>> Skipping Stylelint config${NC}"
    skip_stylelint_setup="true"
  fi
  echo
fi

# ----------------------
# Perform Configuration
# ----------------------
echo
echo -e "${GREEN}Configuring your development environment... ${NC}"

echo
echo -e "1/7 ${LCYAN}ESLint & Prettier & Stylelint  Installation... ${NC}"
echo
$pkg_cmd -D eslint prettier stylelint eslint-plugin-react-hooks

echo
echo -e "2/7 ${YELLOW}Conforming to Airbnb's JavaScript Style Guide... ${NC}"
echo
$pkg_cmd -D eslint-config-airbnb eslint-plugin-jsx-a11y eslint-plugin-import eslint-plugin-react @babel/eslint-parser @babel/preset-react 

echo
echo -e "3/7 ${LCYAN}Making ESlint/Stylelint  and Prettier play nice with each other... ${NC}"
echo "See https://github.com/prettier/eslint-config-prettier for more details."
echo
$pkg_cmd -D eslint-config-prettier eslint-plugin-prettier stylelint-config-standard stylelint-config-rational-order stylelint-order


if [ "$skip_eslint_setup" == "true" ]; then
  break
else
  echo
  echo -e "4/7 ${YELLOW}Building your .eslintrc${config_extension} file...${NC}"
  > ".eslintrc${config_extension}" # truncates existing file (or creates empty)

  echo ${config_opening}'
  "extends": [
    "airbnb",
    "prettier",
    "plugin:jsx-a11y/recommended",
    "plugin:react-hooks/recommended"
  ],
  "parser": "@babel/eslint-parser",
  "parserOptions": {
      "babelOptions": {
        "presets": ["@babel/preset-react"],
    },
    "ecmaVersion": 8,
    "requireConfigFile": false,
    "ecmaFeatures": {
      "experimentalObjectRestSpread": true,
      "impliedStrict": true,
      "classes": true
    }
  },
  "env": {
    "browser": true,
    "node": true,
    "jquery": true,
    "jest": true
  },
  "rules": {
    "react-hooks/rules-of-hooks": "error",
    "no-debugger": 0,
    "no-alert": 0,
    "no-unused-vars": 1,
    "prefer-const": [
      "error",
      {
        "destructuring": "all"
      }
    ],
     "array-element-newline": [
      "error",
      {
        "ArrayExpression": "consistent",
        "ArrayPattern": { "minItems": 3 },
      },
    ],
    "arrow-body-style": [
      2,
      "as-needed"
    ],
    "no-unused-expressions": [
      2,
      {
        "allowTaggedTemplates": true
      }
    ],
    "no-param-reassign": [
      2,
      {
        "props": false
      }
    ],
    "no-console": 1,
    "import/prefer-default-export": 1,
    "import": 0,
    "func-names": 0,
    "space-before-function-paren": 0,
    "comma-dangle": 0,
    "max-len": 0,
    "import/extensions": 0,
    "no-underscore-dangle": 0,
    "consistent-return": 0,
    "react/display-name": 1,
    "react/no-array-index-key": 0,
    "react/react-in-jsx-scope": 0,
    "react/prefer-stateless-function": 0,
    "react/forbid-prop-types": 0,
    "react/jsx-props-no-spreading": 0,
    "react/no-unescaped-entities": 0,
    "jsx-a11y/accessible-emoji": 0,
    "react/require-default-props": 0,
    "react/jsx-filename-extension": [
      1,
      {
        "extensions": [
          ".js",
          ".jsx"
        ]
      }
    ],
    "radix": 0,
    "no-shadow": "off",
    "quotes": [
      2,
      "single",
      {
        "avoidEscape": true,
        "allowTemplateLiterals": true
      }
    ],
    "prettier/prettier": [
      "error",
      {
        "endOfLine": "auto",
        "trailingComma": "'${trailing_comma_pref}'",
        "singleQuote": true,
        "printWidth": '${max_len_val}',
        "jsxBracketSameLine": true,
        "semi": true,
      }
    ],
    "jsx-a11y/href-no-hash": "off",
    "jsx-a11y/click-events-have-key-events": "off",
    "jsx-a11y/no-static-element-interactions": "off",
    "jsx-a11y/no-noninteractive-element-interactions": "off",
    "jsx-a11y/anchor-is-valid": [
      "warn",
      {
        "aspects": [
          "invalidHref"
        ]
      }
    ]
  },
  "plugins": [
    "prettier",
    "react",
    "react-hooks"
  ]
}' >> .eslintrc${config_extension}
fi



if [ "$skip_prettier_setup" == "true" ]; then
  break
else
  echo -e "5/7 ${YELLOW}Building your .prettierrc${config_extension} file... ${NC}"
  > .prettierrc${config_extension} # truncates existing file (or creates empty)

  echo ${config_opening}'
  "printWidth": '${max_len_val}',
  "singleQuote": true,
  "trailingComma": "'${trailing_comma_pref}'",
   "useTabs": false
}' >> .prettierrc${config_extension}
fi



if [ "$skip_stylelint_setup" == "true" ]; then
  break
else
  echo
  echo -e "6/7 ${YELLOW}Building your .stylelintrc${config_extension} file...${NC}"
  > ".stylelintrc${config_extension}" # truncates existing file (or creates empty)

  echo ${config_opening}'
   "extends": ["stylelint-config-standard"],
    "plugins": [
      "stylelint-order",
      "stylelint-config-rational-order/plugin"
      ],
      "rules": {
      "order/properties-order": [],
      "plugin/rational-order": [true, {
        "border-in-box-model": false,
        "empty-line-between-groups": false
      }],
      "selector-class-pattern": null,
	    "keyframes-name-pattern": null
      }
}' >> .stylelintrc${config_extension}
fi

echo -e "7/7 ${YELLOW}Building your .editorconfig file... ${NC}"
  > .editorconfig # truncates existing file (or creates empty)

  echo '
  root = true
  [*.{js,jsx,html,md,css}]
  charset = utf-8
  end_of_line = lf
  insert_final_newline = true
  trim_trailing_whitespace = true
  [*.{js,jsx,css}]
  indent_size = 2
  indent_style = space
' >> .editorconfig

echo
echo -e "${GREEN}Finished setting up!${NC}"
echo
