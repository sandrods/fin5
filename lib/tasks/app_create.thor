# encoding: utf-8

require 'thor/group'
require 'active_support'
require 'active_support/core_ext' # para usar o camelcase
require 'tty-prompt'

module App

  class Create < Thor::Group

    include Thor::Actions

    desc "Cria uma nova aplicação a partir do modelo."
    argument :app_name, type: :string, desc: 'nome da aplicação (ex: my_app)'

    def self.source_root
      File.expand_path("../..", File.dirname(__FILE__))
    end

    def replace_app_name
      say "Modificando arquivos..."

      gsub_file 'package.json', 'APP_NAME', app_name

      gsub_file 'app/views/layouts/application.html.erb', 'APP_NAME', app_name.tr('-', '_').camelize
      gsub_file 'app/views/layouts/_navbar.html.erb', 'APP_NAME', app_name.titleize.upcase
      gsub_file 'app/views/layouts/_header_je.html.erb', 'APP_NAME', app_name.titleize

      gsub_file 'config/application.rb', 'Modelo', app_name.tr('-', '_').camelize
      gsub_file 'config/environments/production.rb', 'APP_NAME_#{Rails.env}', "#{app_name}_\#{Rails.env}"

      gsub_file 'config/cable.yml', 'APP_NAME_production', "#{app_name}_production"
      gsub_file 'config/cable.yml', 'APP_NAME_staging', "#{app_name}_staging"

      gsub_file '.env', 'APP_NAME', app_name
      gsub_file 'config/newrelic.yml', 'APP_NAME', app_name.tr('-', '_').camelize

    end

    def disables
      @features = prompt.multi_select("\nSelecione as features que deseja utilizar: \n", cycle: true, echo: false, per_page: 10) do |m|
        m.enum ']'

        m.choice "Websockets (ActionCable)"           , 1
        m.choice "Upload de Arquivos (ActiveStorage)" , 2
        m.choice "Envio de Emails (ActionMailer)"     , 3
        m.choice "Background Jobs (ActiveJob)"        , 4
        m.choice "Relatórios ODT e PDF"               , 5
        m.choice "Autenticação"                       , 6
        m.choice "Trix (HTML Editor)"                 , 7
      end

      remove_action_cable   unless @features.include?(1)
      remove_active_storage unless @features.include?(2)
      remove_action_mailer  unless @features.include?(3)
      remove_jobs           unless @features.include?(4)
      remove_reports        unless @features.include?(5)
      remove_login          unless @features.include?(6)
      remove_trix           unless @features.include?(7)

      remove_sidekiq        if (@features & [1, 2, 3, 4]).blank?

    end

    def choose_deploy_mode
      deploy_choice = prompt.select('Escolha a forma de deploy:') do |menu|
        menu.choice name: 'virtual host (https://<app_name>.host.tre-rs.gov.br)', value: 1
        menu.choice name: 'subdiretório (https://host.tre-rs.gov.br/<app_name>)', value: 2
      end

      config_deploy_subdir if deploy_choice == 2
    end

    def create_config_files
      say "Criando arquivos de configuracao..."
      copy_file 'config/environments/production.rb', 'config/environments/staging.rb'

      if @features.include?(3)
        insert_into_file 'config/environments/staging.rb', after: "config.action_mailer.perform_caching = false\n" do
          "  config.action_mailer.delivery_method = :letter_opener_web\n\n"
        end
      end

    end

    def get_packages
      say "Running bundle / yarn"

      inside "." do
        run "bundle"
        run "yarn"
      end
    end

    def git_init
      say "Creating git repository"

      remove_dir '.git'

      inside "." do
        run "git init"
        run "git add ."
        run "git commit -m 'App gerada a partir do modelo'"
      end
    end


    def final_message
      say ''
      say 'Aplicação gerada com sucesso!!', :green
      say ''
      say 'Para criar usuario no banco:', :blue
      say "  rake db:user:create[#{app_name}_dev_username]", :blue
      say '  rake db:user:grants', :blue
      say ''
    end

    no_commands do

      def config_deploy_subdir
        say 'Configurando Deploy em subdiretório'

        gsub_file('config.ru', 'run Rails.application') do
          <<~RUBY
            map ENV['RAILS_RELATIVE_URL_ROOT'] || "/" do
              run Rails.application
            end
          RUBY
        end

        gsub_file 'Dockerfile',
                  'RUN bundle exec rake assets:precompile',
                  "RUN bundle exec rake assets:precompile RAILS_RELATIVE_URL_ROOT='/#{app_name}'"

        insert_into_file 'config/environments/production.rb', after: "Rails.application.configure do\n" do
          "\n  config.relative_url_root = '/#{app_name}'\n\n"
        end

        %w(.env.production .env.staging).each do |f|
          append_to_file f, "\nRAILS_RELATIVE_URL_ROOT=/#{app_name}"
        end

        gsub_file 'docker-compose_staging.yml',
                  'traefik.frontend.rule=Host:${CI_PROJECT_NAME}.dev.tre-rs.gov.br',
                  'traefik.frontend.rule=Host:dev.tre-rs.gov.br;PathPrefix:/${CI_PROJECT_NAME}'

        gsub_file 'docker-compose_production.yml',
                  'traefik.frontend.rule=Host:${CI_PROJECT_NAME}.farm.tre-rs.gov.br',
                  'traefik.frontend.rule=Host:dkr.dmz-rs.gov.br;PathPrefix:/${CI_PROJECT_NAME}'

        gsub_file '.gitlab-ci.yml',
                  'PRODUCTION_CLUSTER: farm',
                  'PRODUCTION_CLUSTER: dmz'

        gsub_file '.env',
                  'LOGIN_URL=https://login.tre-rs.gov.br/login',
                  'LOGIN_URL=https://login.tre-rs.jus.br/login'

      end

      def remove_action_cable
        say 'Disabling Action Cable'

        comment_lines 'config/application.rb', 'action_cable'
        remove_file 'app/assets/javascripts/cable.js'
        remove_dir 'app/assets/javascripts/channels'
        remove_dir 'app/channels'
        remove_file 'config/cable.yml'
      end

      def remove_active_storage
        say 'Disabling ActiveStorage'

        comment_lines 'Gemfile', /aws-sdk-s3/
        remove_file 'lib/tasks/s3.rake'
        remove_file 'config/storage.yml'

        gsub_file 'app/assets/javascripts/application.js', '//= require activestorage', ''

        %w(.env .env.development .env.production .env.staging).each do |f|
          gsub_file f, /S3_.+$/, ''
        end

        %w(development test production).each do |f|
          comment_lines "config/environments/#{f}.rb", /active_storage/
        end

        comment_lines 'config/application.rb', /active_storage/

      end

      def remove_action_mailer
        say 'Disabling ActionMailer'

        comment_lines 'Gemfile', /letter_opener_web/

        %w(development test production).each do |f|
          comment_lines "config/environments/#{f}.rb", /action_mailer/
        end

        comment_lines 'config/application.rb', /action_mailer/
        remove_file   'config/initializers/mail.rb'

        %w(.env .env.development .env.production .env.staging).each do |f|
          gsub_file f, /SMTP_.+$/, ''
        end

        remove_dir 'app/mailers'
        remove_file 'app/views/layouts/mailer.html.erb'
        remove_file 'app/views/layouts/mailer.text.erb'
      end

      def remove_reports
        say 'Disabling Reports'

        comment_lines 'Gemfile', /odf-report/
        comment_lines 'Gemfile', /pdfconverter/

        %w(.env .env.development .env.production .env.staging).each do |f|
          gsub_file f, /PDF_CONVERTER_.+$/, ''
        end

        remove_file 'config/initializers/pdfconverter.rb'
        remove_dir 'app/reports'
      end

      def remove_jobs
        say 'Disabling ActiveJob'

        comment_lines 'config/application.rb', /active_job/
        remove_file 'config/initializers/active_job_logger.rb'

        %w(development test production).each do |f|
          comment_lines "config/environments/#{f}.rb", /active_job/
        end

        remove_dir 'app/jobs'
      end

      def remove_sidekiq
        say 'Disabling Sidekiq'

        comment_lines 'Gemfile', /sidekiq/

        remove_file 'config/initializers/sidekiq.rb'
        remove_file 'config/sidekiq.yml'
      end

      def remove_login
        say 'Disabling Login'

        comment_lines 'Gemfile', /login_client/

        remove_file 'config/initializers/acesso.rb'

        %w(.env .env.development .env.production .env.staging).each do |f|
          gsub_file f, /^LOGIN_.+$/, ''
          gsub_file f, /^ACESSO_.+$/, ''
        end

        comment_lines 'app/controllers/application_controller.rb', /LoginClient/
      end

      def remove_trix
        say 'Removing Trix'

        gsub_file 'app/assets/javascripts/application.js', /^.*trix.*$/, ''
        gsub_file 'app/assets/stylesheets/application.scss', /^.*trix.*$/, ''

        gsub_file 'package.json', /^.*trix.*$/, ''

      end

      def prompt
        @prompt ||= TTY::Prompt.new
      end

    end

  end

end
