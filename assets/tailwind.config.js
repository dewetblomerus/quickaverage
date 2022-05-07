module.exports = {
  mode: 'jit',
  purge: [
    '../lib/**/*.eex',
    '../lib/**/*.ex',
    '../lib/**/*.heex',
    '../lib/**/*.leex',
    './js/**/*.js',
  ],
  darkMode: 'media',
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
