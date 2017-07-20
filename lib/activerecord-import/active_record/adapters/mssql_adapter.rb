require "active_record/connection_adapters/mssql_adapter"
require "activerecord-import/adapters/sqlserver_adapter"

class ActiveRecord::ConnectionAdapters::MSSQLAdapter
  include ActiveRecord::Import::SQLServerAdapter
end