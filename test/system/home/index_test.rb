# frozen_string_literal: true

require "application_system_test_case"

class HomeTest < ApplicationSystemTestCase
  test "index" do
    visit(root_path)

    assert_text("Upper Town")
  end
end
