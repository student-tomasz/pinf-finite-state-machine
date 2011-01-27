class AddAttachmentGraphToMachine < ActiveRecord::Migration
  def self.up
    add_column :machines, :graph_file_name,    :string
    add_column :machines, :graph_content_type, :string
    add_column :machines, :graph_file_size,    :integer
    add_column :machines, :graph_updated_at,   :datetime
  end

  def self.down
    remove_column :machines, :graph_file_name
    remove_column :machines, :graph_content_type
    remove_column :machines, :graph_file_size
    remove_column :machines, :graph_updated_at
  end
end
