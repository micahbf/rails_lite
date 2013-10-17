require_relative './db_connection'
require_relative './relation'

module Relatable
  def all
    rows = DBConnection.execute(all_query)
    self.parse_all(rows)
  end
  
  def where(where_hash)
    Relation.new(all_query, [], self, where_hash)
  end
    
  private
  
  def all_query
    <<-SQL
      SELECT *
      FROM #{self.table_name}
    SQL
  end
end