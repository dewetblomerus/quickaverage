module.exports = {
  purge: [
    '../lib/**/*.eex',
    '../lib/**/*.ex',
    '../lib/**/*.heex',
    '../lib/**/*.leex',
    './js/**/*.js',
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
