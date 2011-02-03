class CreateMachines < ActiveRecord::Migration
  def self.up
    create_table :machines do |t|
      t.string :name
      t.string :states
      t.string :alphabet
      t.text   :transition_func
      t.string :start_state
      t.string :accept_states

      t.timestamps
    end
  end

  def self.down
    drop_table :machines
  end
end
