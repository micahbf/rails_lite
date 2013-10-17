require_relative './db_connection'

class Relation
  attr_reader :wheres_hash
  
  def initialize(base_query, base_vals, klass, wheres_hash = {})
    @base_query = base_query
    @base_vals = base_vals
    @klass = klass
    @wheres_hash = wheres_hash
  end
  
  def where(where_hash)
    Relation.new(@base_query, @base_vals, @klass, @wheres_hash.merge(where_hash))
  end
  
  def all
    fire_and_return
  end
    
  private
  
  def fire_and_return
    unless wheres_hash.empty?
      where_line = wheres_hash.keys.map do |key|
        "#{key} = ?"
      end.join(" AND ").prepend(" WHERE ")
      where_vals = wheres_hash.values
    else
      where_line = ""
    end
    
    rows = DBConnection.execute(@base_query + where_line, *@base_vals, *where_vals)
    rows.empty? ? [] : @klass.parse_all(rows)
  end
end