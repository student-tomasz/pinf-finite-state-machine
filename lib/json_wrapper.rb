class JsonWrapper
  def initialize(serialized_attributes)
    @serialized_attributes = serialized_attributes
  end
  
  def before_save(record)
    @serialized_attributes.each do |attribute|
      record.send("#{attribute}=", record.send(attribute).to_json)
    end
  end

  def after_save(record)
    @serialized_attributes.each do |attribute|
      record.send("#{attribute}=", ActiveSupport::JSON.decode(record.send(attribute).to_s))
    end
  end

  alias_method :after_find, :after_save
end
