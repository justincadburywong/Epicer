/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{html,erb,js}",
    "./app/helpers/**/*.{rb}",
    "./app/javascript/**/*.{js,ts}",
    "./app/views/**/*.{html,erb}",
  ],
  darkMode: 'media',
  theme: {
    extend: {},
  },
  plugins: [],
}
