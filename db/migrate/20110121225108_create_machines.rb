class CreateMachines < ActiveRecord::Migration
  def self.up
    create_table :machines do |t|
      t.string :name
      t.string :states
      t.string :alphabet
      t.string :accept_states
      t.string :start_state
      t.text   :transition_func

      t.timestamps
    end
  end

  def self.down
    drop_table :machines
  end
end
