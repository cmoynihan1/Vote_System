class AddInitialTables < ActiveRecord::Migration[7.0]
  def change
    create_table :campaigns do |t|
      t.text :campaign_id, null: false, index: { unique: true }
      t.integer :valid_votes, default: 0
      t.integer :invalid_votes, default: 0
      t.integer :error_votes, default: 0

      t.timestamps
    end

    create_table :candidates do |t|
      t.text :name
      t.belongs_to :campaign
      t.integer :votes, default: 0

      t.timestamps
    end
  end
end
