# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true

pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'

pin "@tailwindcss/line-clamp", to: "https://ga.jspm.io/npm:@tailwindcss/line-clamp@0.4.2/src/index.js"
pin "tailwindcss/plugin", to: "https://ga.jspm.io/npm:tailwindcss@3.2.4/plugin.js"
pin "@tailwindcss/forms", to: "https://ga.jspm.io/npm:@tailwindcss/forms@0.5.3/src/index.js"
pin "mini-svg-data-uri", to: "https://ga.jspm.io/npm:mini-svg-data-uri@1.4.4/index.js"
pin "picocolors", to: "https://ga.jspm.io/npm:picocolors@1.0.0/picocolors.browser.js"
pin "tailwindcss/colors", to: "https://ga.jspm.io/npm:tailwindcss@3.2.4/colors.js"
pin "tailwindcss/defaultTheme", to: "https://ga.jspm.io/npm:tailwindcss@3.2.4/defaultTheme.js"
