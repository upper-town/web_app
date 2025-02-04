# frozen_string_literal: true

module Admin
  class TablePresenter
    def initialize(collection: [], columns: [])
      @collection = collection
      @columns = columns
    end

    def render?
      @collection.any?
    end
  end
end
