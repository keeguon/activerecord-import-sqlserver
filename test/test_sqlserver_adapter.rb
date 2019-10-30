require 'minitest/autorun'
require 'active_record'
require 'activerecord-import'
require 'activerecord-import/active_record/adapters/sqlserver_adapter'

class SqlServerAdapterTest < Minitest::Test

  def test_get_identity_column_name
    options = {}
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).get_identity_column_name(options)
    assert_equal 'id', result

    options[:id_column_name] = 'foobar'
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).get_identity_column_name(options)
    assert_equal 'foobar', result
  end

  def test_get_sql_noid
    sql_id_index = nil
    columns_names = nil
    base_sql = nil
    column_override = nil
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).get_sql_noid(sql_id_index, columns_names, base_sql, column_override)
    assert_nil result

    sql_id_index = 0
    columns_names = ['id', 'col1','col2','col3','col4','col5']
    base_sql = 'INSERT INTO [schema].[table] ([id],[col1],[col2],[col3],[col4],[col5]) VALUES '
    column_override = 'id'
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).get_sql_noid(sql_id_index, columns_names, base_sql, column_override)
    assert_equal 'INSERT INTO [schema].[table] ([col1],[col2],[col3],[col4],[col5]) VALUES ', result

    sql_id_index = 1
    columns_names = ['col1','id','col2','col3','col4','col5']
    base_sql = 'INSERT INTO [schema].[table] ([col1],[id],[col2],[col3],[col4],[col5]) VALUES '
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).get_sql_noid(sql_id_index, columns_names, base_sql, column_override)
    assert_equal 'INSERT INTO [schema].[table] ([col1],[col2],[col3],[col4],[col5]) VALUES ', result

    sql_id_index = 5
    columns_names = ['col1','col2','col3','col4','col5','id']
    base_sql = 'INSERT INTO [schema].[table] ([col1],[col2],[col3],[col4],[col5],[id]) VALUES '
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).get_sql_noid(sql_id_index, columns_names, base_sql, column_override)
    assert_equal 'INSERT INTO [schema].[table] ([col1],[col2],[col3],[col4],[col5]) VALUES ', result
  end

  def test_get_sql_noid_OLD_AND_BROKEN
    sql_id_index = nil
    columns_names = nil
    base_sql = nil
    column_override = nil
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).get_sql_noid_OLD(sql_id_index, columns_names, base_sql, column_override)
    assert_nil result

    sql_id_index = 0
    columns_names = ['id', 'col1','col2','col3','col4','col5']
    base_sql = 'INSERT INTO [schema].[table] ([id],[col1],[col2],[col3],[col4],[col5]) VALUES '
    column_override = 'id'
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).get_sql_noid_OLD(sql_id_index, columns_names, base_sql, column_override)
    assert_equal 'INSERT INTO [schema].[table] ([col1],[col2],[col3],[col4],[col5]) VALUES ', result

    sql_id_index = 1
    columns_names = ['col1','id','col2','col3','col4','col5']
    base_sql = 'INSERT INTO [schema].[table] ([col1],[id],[col2],[col3],[col4],[col5]) VALUES '
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).get_sql_noid_OLD(sql_id_index, columns_names, base_sql, column_override)
    assert_equal 'INSERT INTO [schema].[table] ([col1],[col2],[col3],[col4],[col5]) VALUES ', result

    sql_id_index = 5
    columns_names = ['col1','col2','col3','col4','col5','id']
    base_sql = 'INSERT INTO [schema].[table] ([col1],[col2],[col3],[col4],[col5],[id]) VALUES '
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).get_sql_noid_OLD(sql_id_index, columns_names, base_sql, column_override)
    # Notice that there is a comma at the end of the columns that shouldn't be there
    assert_equal 'INSERT INTO [schema].[table] ([col1],[col2],[col3],[col4],[col5],) VALUES ', result
  end

  def test_values_to_array
    base_string = "(N'firstcolval',N'second col val',N'third, col & value, with commas and stuff',0,true)"
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).values_to_array base_string
    expected = ["N'firstcolval'", "N'second col val'", "N'third, col & value, with commas and stuff'", "0", "true"]
    assert_equal expected, result
  end

  def test_values_to_array_OLD_AND_BROKEN
    base_string = "(N'firstcolval',N'second col val',N'third, col & value, with commas and stuff',0,true)"
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).values_to_array_OLD base_string

    # Notice that the expected values using the old (split) method does weird things when the data contains commas
    expected = ["N'firstcolval'", "N'second col val'", "N'third"," col & value"," with commas and stuff'", "0", "true"]
    assert_equal expected, result
  end

  def test_parse_column_names
    sql = 'INSERT INTO [schema].[table] ([col1],[col2],[col3],[col4],[col5]) VALUES '
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).parse_column_names_from_sql sql
    expected = ['[col1]', '[col2]','[col3]','[col4]','[col5]']
    assert_equal expected, result
  end

  def test_parse_column_names_OLD_AND_BROKEN
    sql = 'INSERT INTO [schema].[table] ([col1],[col2],[col3],[col4],[col5]) VALUES '
    result = Class.new.extend(ActiveRecord::Import::SQLServerAdapter).parse_column_names_from_sql_OLD sql

    #Notice that there is a trailing ) here, which is bad!
    expected = ['[col1]','[col2]','[col3]','[col4]','[col5])']
    assert_equal expected, result
  end


end