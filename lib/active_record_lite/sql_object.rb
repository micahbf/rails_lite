require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './validatable'
require_relative './relatable'
require 'active_support/inflector'

class SQLObject < MassObject
  extend Associatable
  extend Relatable
  extend Validatable
  include Validations
  
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.underscore.pluralize
  end

  def self.all
    all_rows = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL
    
    self.parse_all(all_rows)
  end

  def self.find(id)
    all_rows = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{self.table_name}
      WHERE id = ?
    SQL
    
    return nil if all_rows.count == 0
    self.new(all_rows.first)
  end

  def save
    do_validations
    
    if @id.nil?
      create
    else
      update
    end
  end

  private
  
  def create
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name}
      (#{safe_attrs.join(", ")})
      VALUES (#{(['?'] * safe_attrs.count).join(", ")})
    SQL
    
    @id = DBConnection.last_insert_row_id
  end

  def update
    set_line = safe_attrs.map do |attr_name|
      "#{attr_name} = ?"
    end.join(", ")
    
    DBConnection.execute(<<-SQL, *attribute_values, @id)
      UPDATE #{self.class.table_name}
      SET #{set_line}
      WHERE id = ?
    SQL
  end
  
  def safe_attrs
    self.class.attributes - [:id]
  end
  
  def attribute_values
    safe_attrs.map do |attr_name|
      self.send(attr_name)
    end
  end
end
