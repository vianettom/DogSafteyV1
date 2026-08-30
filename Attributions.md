# Attributions

## UI

The interface is built with [Tailwind CSS](https://tailwindcss.com) ([MIT](https://github.com/tailwindlabs/tailwindcss/blob/main/LICENSE)) and
[daisyUI](https://daisyui.com) ([MIT](https://github.com/saadeghi/daisyui/blob/master/LICENSE)).

The original prototype was generated with Figma Make and included components from
[shadcn/ui](https://ui.shadcn.com/) under the [MIT license](https://github.com/shadcn-ui/ui/blob/main/LICENSE.md).
Those components were replaced during the port to Phoenix LiveView and no longer ship with this project.

## Data

Every entry in `priv/data/food_data.json` carries its own `citations` field naming the
source it was drawn from. Primary sources include:

- [ASPCA Animal Poison Control Center](https://www.aspca.org/pet-care/animal-poison-control)
- [Pet Poison Helpline](https://www.petpoisonhelpline.com/)
- [Merck Veterinary Manual](https://www.merckvetmanual.com/)
