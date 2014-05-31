class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      # post relation
      t.integer  :parent_post_id
      
      # post meta
      t.string :title
      t.string :author
      t.string :email

      # author info
      t.string :remote_ip,      null: false
      t.string :identity_hash,  null: false

      # post content
      t.text :message
      t.string :image_dimensions
      
      # post control
      t.string :delete_password
      t.boolean :locked,     default: false
      
      t.timestamps

      # table index
      t.index :parent_post_id
      t.index :updated_at
    end
  end
end
