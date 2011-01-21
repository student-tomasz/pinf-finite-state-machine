class CreateMachines < ActiveRecord::Migration
  def self.up
    create_table :machines do |t|
      t.string :name, :unique => true
      t.string :states_json
      t.string :alphabet_json
      t.string :start_state_json
      t.string :accept_states_json
      t.text   :transition_json

      t.timestamps
    end
  end

  def self.down
    drop_table :machines
  end
end
