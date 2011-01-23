class Machine < ActiveRecord::Base
private
  @@serialized_attributes = [:states, :alphabet, :accept_states, :start_state, :transition_func]
  @@steps = ['initialize', 'accept', 'complete']

public
  before_save JsonWrapper.new(@@serialized_attributes)
  after_save  JsonWrapper.new(@@serialized_attributes)
  after_find  JsonWrapper.new(@@serialized_attributes)
  
  validates_presence_of :name
  validates_presence_of :states
  validates_presence_of :alphabet
  
  scope :completed, where(:step => @@steps.last)
  
  def self.dummy
    self.new(
      :name     => 'dummy',
      :states   => ['a', 'b', 'c'],
      :alphabet => ['1', '2']
    )
  end
  
  def step    
    self[:step] || @@steps.first
  end

  def step=(value)
    self[:step] = value
    self.save
  end

  def next_step
    i = @@steps.index(step)
    self.step = @@steps[i + 1]
  end
  
  def first_step?
    step == @@steps.first
  end
  
  def last_step?
    step == @@steps[-2]
  end
  
  def completed?
    step == @@steps.last
  end
end
