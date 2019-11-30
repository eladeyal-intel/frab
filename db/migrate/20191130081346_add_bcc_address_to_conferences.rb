class AddBccAddressToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :bcc_email_address, :string
  end
end
