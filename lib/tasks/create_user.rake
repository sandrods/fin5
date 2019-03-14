#
# USAGE: rake db:user:create[admapp_dev_sandro]
# USAGE: rake db:user:grants

namespace :db do
  namespace :user do

    task :create, [:username] => :conn_as_dba do |_, args|

      user = args.username

      ddls = <<-DDL
        CREATE USER #{user} IDENTIFIED BY teste1
        DEFAULT TABLESPACE "PRODUCAO"
        TEMPORARY TABLESPACE "TEMP"
        |
        GRANT "CONNECT" TO #{user}
        |
        GRANT "RESOURCE" TO #{user}
        |
        GRANT CREATE SYNONYM TO #{user}
        |
        GRANT CREATE VIEW TO #{user}
        |
        GRANT UNLIMITED TABLESPACE TO #{user}
      DDL

      ddls.split("|").each do |ddl|
        ddl.strip!
        puts "-> #{ddl}"
        ActiveRecord::Base.connection.execute ddl
      end

      puts "\n== User (#{user}) created\n\n"

      grants(user)
    end

    task grants: :conn_as_dba do
      user = ActiveRecord::Base.configurations[Rails.env]['username']
      grants(user)
    end

    task conn_as_dba: :environment do
      conf = ActiveRecord::Base.configurations[Rails.env]

      dba_conf = conf.dup
      dba_conf['username'] = 'cosis'
      dba_conf['password'] = 'cosisdba'

      ActiveRecord::Base.establish_connection dba_conf
    end

    def grants(user)
      grants = %w(
        acesso2.usuarios
        acesso2.setores
      )

      grants.each do |table|
        command = "grant select on #{table} to #{user}"
        puts "-> #{command}"
        ActiveRecord::Base.connection.execute command
      end

      puts "\n== Grants to (#{user}) conceded\n\n"
    end
  end
end
