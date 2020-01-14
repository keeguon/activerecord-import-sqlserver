module ActiveRecord::Import::SQLServerAdapter
  include ActiveRecord::Import::ImportSupport

  def supports_on_duplicate_key_update?
    false
  end

  def insert_many( sql, values, options = {}, *args )
    base_sql, post_sql = if sql.is_a?( String )
      [sql, '']
    elsif sql.is_a?( Array )
      [sql.shift, sql.join( ' ' )]
    end

    column_override = get_identity_column_name options
    columns_names = parse_column_names_from_sql base_sql
    sql_id_index  = columns_names.index("[#{column_override}]")
    sql_noid      = get_sql_noid sql_id_index, columns_names, base_sql, column_override

    max = max_allowed_packet

    number_of_inserts = 0
    while !(batch = values.shift(max)).blank? do
      if sql_id_index
        null_ids     = []
        supplied_ids = []

        batch.each do |value|
          values_sql = values_to_array(value)
          if values_sql[sql_id_index] == "NULL"
            values_sql.delete_at(sql_id_index)
            null_ids << "(#{values_sql.join(',')})"
          else
            supplied_ids << value
          end
        end

        unless null_ids.empty?
          number_of_inserts += 1
          sql2insert = sql_noid + null_ids.join( ',' ) + post_sql
          insert( sql2insert, *args )
        end
        unless supplied_ids.empty?
          number_of_inserts += 1
          sql2insert = base_sql + supplied_ids.join( ',' ) + post_sql
          insert( sql2insert, *args )
        end
      else
        number_of_inserts += 1
        sql2insert = base_sql + batch.join( ',' ) + post_sql
        insert( sql2insert, *args )
      end
    end

    ActiveRecord::Import::Result.new([], number_of_inserts, [], [])
  end

  def max_allowed_packet
    1000
  end

  def get_identity_column_name( options )
    options[:id_column_name] || 'id'
  end

  def get_sql_noid(sql_id_index, columns_names, base_sql, column_override)
    if sql_id_index.nil?
      nil
    else
      (sql_id_index == (columns_names.length - 1) ? base_sql.clone.gsub(/,\[#{column_override}\]/, '') : base_sql.clone.gsub(/\[#{column_override}\],/, ''))
    end
  end

  # This can be removed, it's just here to show the old way and compare with the new way
  def get_sql_noid_OLD(sql_id_index, columns_names, base_sql, column_override)
    if sql_id_index.nil?
      nil
    else
      (sql_id_index == (columns_names.length - 1) ? base_sql.clone.gsub(/\[id\]/, '') : base_sql.clone.gsub(/\[id\],/, ''))
    end
  end

  def parse_column_names_from_sql( sql )
    sql.match(/(?<=\().*(?=\).*VALUES)/)[0].split(',')
  end

  # This can be removed, it's just here to show the old way and compare with the new way
  def parse_column_names_from_sql_OLD( sql )
    sql.match(/INSERT INTO (\[.*\]) (\(.*\)) VALUES /)[2][1..-1].split(',')
  end

  def values_to_array( value )
    value[1..-2].scan(/N\'.*?\'|[^,]+/)
  end

  # This can be removed, it's just here to show the old way and compare with the new way
  def values_to_array_OLD( value )
    value[1..-2].split(',')
  end

end
