require 'rails_helper'

RSpec.describe Service do

  after(:each) do
    Object.send(:remove_const, :TestService) if Object.const_defined?(:TestService)
    Object.send(:remove_const, :ServicePai) if Object.const_defined?(:ServicePai)
    Object.send(:remove_const, :ServiceFilho) if Object.const_defined?(:ServiceFilho)
  end

  describe '.run' do

    context 'Com sucesso' do

      before(:each) do
        TestService = Class.new do
          include Service

          define_method :run do
            # executa com sucesso
          end
        end
      end

      it 'Retorna instancia do service' do
        service = TestService.run()

        expect(service).to be_a TestService
      end

      it 'success = true' do
        service = TestService.run()

        expect(service).to be_success
      end
    end

    context 'Com erro (fail!)' do

      before(:each) do
        TestService = Class.new do
          include Service

          define_method :run do
            fail! 'Deu erro'
          end
        end
      end

      it 'Retorna instancia do service' do
        service = TestService.run()

        expect(service).to be_a TestService
      end

      it 'success = false' do
        service = TestService.run()

        expect(service).to_not be_success
      end

      it 'armazena mensagem de erro' do
        service = TestService.run()

        expect(service.error_messages).to include 'Deu erro'
      end

    end

    context 'Com erro (exception)' do

      before(:each) do
        TestService = Class.new do
          include Service

          define_method :run do
            raise RuntimeError, 'Deu Erro'
          end
        end
      end

      it 'Nao engole o erro' do

        expect {
          TestService.run()
        }.to raise_error(RuntimeError, 'Deu Erro')
      end
    end

    context 'Com warning' do
      before(:each) do
        TestService = Class.new do
          include Service

          define_method :run do
            add_warning 'Warning message'
          end
        end


      end

      it 'success = true' do
        service = TestService.run()

        expect(service).to be_success
      end

      it 'warning = true' do
        service = TestService.run()

        expect(service).to be_warning
      end

      it 'armazena a mensagem' do
        service = TestService.run()

        expect(service.warning_messages).to include 'Warning message'
      end
    end


  end

  describe '.run!' do

    context 'Com sucesso' do
      before(:each) do
        TestService = Class.new do
          include Service

          define_method :run do
            # sucesso
          end
        end
      end

      it 'success = true' do
        service = TestService.run!()

        expect(service).to be_success
      end
    end

    context 'Com erro (fail!)' do
      before(:each) do
        TestService = Class.new do
          include Service

          define_method :run do
            fail! 'Deu erro'
          end
        end
      end

      it 'levanta excecao Service::Error' do
        expect{ TestService.run!() }.to raise_error(Service::Error, 'Deu erro')
      end
    end

    context 'Com erro (exception)' do
      before(:each) do
        TestService = Class.new do
          include Service

          define_method :run do
            raise RuntimeError, 'Deu erro'
          end
        end
      end

      it 'repassa a excecao original' do
        expect{ TestService.run!() }.to raise_error(RuntimeError, 'Deu erro')
      end
    end

  end

  describe 'compose' do

    context 'Quando o filho executa com sucesso' do

      before(:each) do
        ServicePai = Class.new do
          include Service

          attr_accessor :result_filho

          define_method :run do
            service_filho = compose ServiceFilho, 1, 2
            @result_filho = service_filho.result
          end
        end

        ServiceFilho = Class.new do
          include Service

          attr_reader :result

          define_method :initialize do |a, b|
            @a, @b = a, b
          end

          define_method :run do
            @result = @a + @b
          end
        end
      end

      it 'Chama o filho passando os parametros' do
        service_pai = ServicePai.run()

        expect(service_pai.result_filho).to eq 3
      end
    end

    context 'Quando o filho falha (fail!)' do

      before(:each) do
        ServicePai = Class.new do
          include Service

          attr_accessor :result

          define_method :run do
            service_filho = compose ServiceFilho
            @result = 1
          end
        end

        ServiceFilho = Class.new do
          include Service

          define_method :run do
            fail! 'Erro no filho'
          end
        end
      end

      it 'Seta success=false e captura erro do filho' do
        service_pai = ServicePai.run()

        expect(service_pai).to_not be_success
        expect(service_pai.error_messages).to include 'Erro no filho'
      end

      it 'Continua executando o pai ate o final' do
        service_pai = ServicePai.run()

        expect(service_pai.result).to eq 1
      end

    end

  end

  describe 'compose!' do

    context 'Quando o filho falha (fail!)' do

      before(:each) do
        ServicePai = Class.new do
          include Service

          attr_accessor :result

          define_method :run do
            service_filho = compose! ServiceFilho
            @result = 1
          end
        end

        ServiceFilho = Class.new do
          include Service

          define_method :run do
            fail! 'Erro no filho'
          end
        end
      end

      it 'Seta success=false e captura erro do filho' do
        service_pai = ServicePai.run()

        expect(service_pai).to_not be_success
        expect(service_pai.error_messages).to include 'Erro no filho'
      end

      it 'Interrompe a execucao do pai' do
        service_pai = ServicePai.run()

        expect(service_pai.result).to be_nil
      end
    end

  end

end
