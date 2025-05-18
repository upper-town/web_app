class EnableExtensionPgcrypto < ActiveRecord::Migration[7.1]
  def up
    unless extension_enabled?('pgcrypto')
      enable_extension('pgcrypto')
    end
  end

  def down
    if extension_enabled?('pgcrypto')
      disable_extension('pgcrypto')
    end
  end
end
