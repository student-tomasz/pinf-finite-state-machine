class AddStepToMachines < ActiveRecord::Migration
  def self.up
    change_table :machines do |t|
      t.string :step
    end
    Machine.update_all :step => "complete"
  end

  def self.down
    remove_column :machines, :step
  end
end
