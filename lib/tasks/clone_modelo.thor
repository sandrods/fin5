require 'thor/group'

module App
  class Clone < Thor::Group

    include Thor::Actions

    desc "Clone o modelo do Gitlab e Cria uma nova aplicação a partir dele."
    argument :app_name, type: :string, desc: 'nome da aplicação (ex: my_app)'

    def validate_app_exists
      if File.exists?(app_name)
        say_status('ERROR', "App #{app_name} already exists", :red)
        exit 1
      end
    end

    def git_clone
      run "git clone git@gitlab.tre-rs.gov.br:cosis/modelo.git #{app_name}"
    end

    def create_app
      inside app_name do
        run "thor app:create #{app_name}"
      end
    end

  end

end
