class MassObject  
  def self.my_attr_accessible(*attributes)
    attributes.each do |attribute|
      attr_accessor attribute
    end

    @attributes ||= []
    @attributes += attributes
  end

  def self.attributes
    @attributes || []
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      if self.class.attributes.include?(attr_name.to_sym)
        self.send("#{attr_name}=", value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
end