# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "bootstrap", to: "bootstrap.bundle.min.js"

pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/lib", under: "lib"

pin "application"
