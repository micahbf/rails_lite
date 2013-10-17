require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    @class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  attr_reader :class_name, :foreign_key, :primary_key
  
  def initialize(name, params)
    @class_name = params[:class_name] || name.to_s.camelcase
    @foreign_key = params[:foreign_key] || "#{name.to_s.underscore}_id"
    @primary_key = params[:primary_key] || "id"
  end

  def type
    :belongs_to
  end
end

class HasManyAssocParams < AssocParams
  attr_reader :class_name, :foreign_key, :primary_key
    
  def initialize(name, klass, params)
    @class_name = params[:class_name] || name.to_s.singularize.camelcase
    @foreign_key = params[:foreign_key] || "#{klass.to_s.underscore}_id"
    @primary_key = params[:primary_key] || "id"
  end

  def type
    :has_many
  end
end

module Associatable
  def assoc_params
    @assoc_params ||= {}
  end

  def belongs_to(name, params = {})
    a_params = BelongsToAssocParams.new(name, params)
    assoc_params[name] = a_params
    
    self.send(:define_method, name) do
      all_rows = DBConnection.execute(<<-SQL, @id)
        SELECT *
        FROM #{a_params.other_table}
        WHERE #{a_params.other_table}.#{a_params.primary_key} IN
          (
          SELECT #{a_params.foreign_key}
          FROM #{self.class.table_name}
          WHERE #{self.class.table_name}.id = ?
          )
      SQL
      
      a_params.other_class.parse_all(all_rows).first
    end
  end

  def has_many(name, params = {})
    if params[:through]
      has_many_through(name, params)
      return
    end
    
    a_params = HasManyAssocParams.new(name, self, params)
    assoc_params[name] = a_params
    
    self.send(:define_method, name) do
      all_rows = DBConnection.execute(<<-SQL, @id)
        SELECT *
        FROM #{a_params.other_table}
        WHERE #{a_params.other_table}.#{a_params.foreign_key} = ?
      SQL
      
      a_params.other_class.parse_all(all_rows)
    end
  end

  def has_one_through(name, assoc2, assoc1)
    self.send(:define_method, name) do
      result_class = assoc1.to_s.camelcase.constantize
      through_class = assoc2.to_s.camelcase.constantize
      result_table, through_table = result_class.table_name, through_class.table_name
      assoc1_params = through_class.assoc_params[assoc1]
      assoc2_params = self.class.assoc_params[assoc2]
      
      all_rows = DBConnection.execute(<<-SQL)
        SELECT #{result_table}.*
        FROM #{result_table}
        JOIN #{through_table}
        ON #{through_table}.#{assoc1_params.foreign_key}
          = #{result_class.table_name}.#{assoc1_params.primary_key}
        WHERE #{through_table}.#{assoc2_params.primary_key}
          = #{self.send(assoc2_params.foreign_key)}
      SQL
      
      assoc1_params.other_class.parse_all(all_rows).first
    end
  end
  
  def has_many_through(name, params)
    self.send(:define_method, name) do
      result_class = name.to_s.singularize.camelcase.constantize
      through_class = params[:through].to_s.singularize.camelcase.constantize
      result_table, through_table = result_class.table_name, through_class.table_name
      assoc1_params = through_class.assoc_params[name]
      assoc2_params = self.class.assoc_params[params[:through]]
      
      query = <<-SQL
        SELECT #{result_table}.*
        FROM #{result_table}
        JOIN #{through_table}
        ON #{through_table}.#{assoc1_params.primary_key}
          = #{result_class.table_name}.#{assoc1_params.foreign_key}
        WHERE #{through_table}.#{assoc2_params.foreign_key}
          = #{self.send(assoc2_params.primary_key)}
      SQL

      all_rows = DBConnection.execute(query)  
      assoc1_params.other_class.parse_all(all_rows)
    end
  end
end
