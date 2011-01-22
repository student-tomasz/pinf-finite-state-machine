class Machine < ActiveRecord::Base
private
  @@serialized_attributes = [:states, :alphabet]

public
  before_save JsonWrapper.new(@@serialized_attributes)
  after_save  JsonWrapper.new(@@serialized_attributes)
  after_find  JsonWrapper.new(@@serialized_attributes)
  
  validates_presence_of :name
  validates_presence_of :states
  validates_presence_of :alphabet
  
  def self.dummy
    self.new(
      :name     => 'dummy',
      :states   => ['a', 'b', 'c'],
      :alphabet => ['1', '2']
    )
  end
  
  def humanize
    @@serialized_attributes.each do |attribute|
      self.send("#{attribute}=", self.send(attribute).join("\n")) if self.send(attribute).class == Array
    end
    self
  end
  
  def dehumanize
    @@serialized_attributes.each do |attribute|
      self.send("#{attribute}=", self.send(attribute).split(" ")) if self.send(attribute).class == String
    end
    self
  end
end
