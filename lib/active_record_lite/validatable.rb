Dir[File.dirname(__FILE__) + '/validations/*.rb'].each {|file| require file }
require 'active_support/inflector'

module Validatable
  def validates(field, validations)
    @validations ||= {}
    @validations[field] = validations
  end
  
  def validations
    @validations
  end
end

module Validations
  def do_validations
    self.class.validations.each do |field, f_validations|
      f_validations.each do |validation, value|
        validator = "#{validation.to_s.camelcase}Validator".constantize.new
        v_response = validator.validate(self.send(field))
      
        raise "#{field} failed validation #{validation}" if v_response != value
      end
    end
    true
  end
end