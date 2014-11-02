class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :name
      t.belongs_to :category
      t.timestamps
    end
  end
end
