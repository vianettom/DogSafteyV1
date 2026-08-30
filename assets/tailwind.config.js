const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/dog_food_safety_web.ex',
    '../lib/dog_food_safety_web/**/*.*ex'
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require("daisyui"),

    // Embeds Heroicons (https://heroicons.com) as `hero-*` classes, backed by
    // CSS masks so they inherit `currentColor` and Tailwind sizing utilities.
    //
    //     <.icon name="hero-check-circle" />        -- 24/outline
    //     <.icon name="hero-x-mark-solid" />        -- 24/solid
    //     <.icon name="hero-information-circle-mini" /> -- 20/solid
    //
    plugin(function ({ matchComponents, theme }) {
      const iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      const values = {}
      const icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]

      icons.forEach(([suffix, dir]) => {
        const fullDir = path.join(iconsDir, dir)
        if (!fs.existsSync(fullDir)) { return }

        fs.readdirSync(fullDir).forEach(file => {
          const name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(fullDir, file) }
        })
      })

      matchComponents({
        "hero": ({ name, fullPath }) => {
          const content = fs.readFileSync(fullPath).toString()
            .replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, { values })
    })
  ],
  daisyui: {
    themes: ["light", "dark"],
  },
}
