# frozen_string_literal: true

SimpleCov.start do
  primary_coverage :line
  enable_coverage  :branch

  add_filter "/bin/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/test/"
  add_filter "/vendor/"

  add_group "Channels",    "app/channels"
  add_group "Components",  "app/components"
  add_group "Controllers", "app/controllers"
  add_group "Domain",      "app/domain"
  add_group "Helpers",     "app/helpers"
  add_group "Jobs",        "app/jobs"
  add_group "Libraries",   "app/lib"
  add_group "Mailers",     "app/mailers"
  add_group "Models",      "app/models"
  add_group "Normalizers", "app/normalizers"
  add_group "Policies",    "app/policies"
  add_group "Presenters",  "app/presenters"
  add_group "Queries",     "app/queries"
  add_group "Services",    "app/services"
  add_group "Validators",  "app/validators"
  add_group "Values",      "app/values"

  track_files "{app,lib}/**/*.rb"

  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.single_report_path      = "coverage/lcov.info"
  end

  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ])
end
