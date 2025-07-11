module.exports = {
  content: [
    './js/**/*.js',
    '../lib/dog_food_safety_web.ex',
    '../lib/dog_food_safety_web/**/*.*ex'
  ],
  theme: {
    extend: {},
  },
  plugins: [require("daisyui")],
  daisyui: {
    themes: ["light", "dark"],
  },
}