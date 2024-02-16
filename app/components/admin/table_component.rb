# frozen_string_literal: true

module Admin
  class TableComponent < ApplicationComponent
    def initialize(collection: [], columns: [])
      super()

      @collection = collection
      @columns = columns
    end

    def render?
      @collection.any?
    end
  end
end
