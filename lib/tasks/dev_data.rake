require 'benchmark'

namespace :db do

  task :dev_data => :environment do

    begin

      Benchmark.bm(15) do |x|

        x.report("Limpando banco") do

        end

        x.report("Model 1") do

        end

      end

    rescue ActiveRecord::RecordInvalid => e
      puts "\n Colision Detected. Starting Again. \n"
      retry
    end

  end

end
