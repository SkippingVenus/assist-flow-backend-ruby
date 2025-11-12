# Concern for adding search functionality to models
module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, ->(query) { where(build_search_query(query)) }
  end

  class_methods do
    def searchable_fields(*fields)
      @searchable_fields = fields
    end

    def build_search_query(query)
      return if query.blank?
      
      fields = @searchable_fields || [:name]
      conditions = fields.map { |field| "#{field} ILIKE :query" }.join(' OR ')
      
      [conditions, { query: "%#{query}%" }]
    end
  end
end
