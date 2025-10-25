# frozen_string_literal: true

module MigrationExtensions
  def create_table(table_name, id: :primary_key, primary_key: nil, **, &)
    super.tap do
      alter_id_sequence(table_name) if default_id_options?(id, primary_key)
    end
  end

  def default_id_options?(id, primary_key)
    id == :primary_key && primary_key.nil?
  end

  def alter_id_sequence(table_name)
    execute("ALTER SEQUENCE #{table_name}_id_seq RESTART WITH 1001")
  end
end

ActiveRecord::Migration.include MigrationExtensions
