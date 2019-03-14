class OdtInspector

  def initialize(input)
    @content = nil
    Zip::InputStream.open(StringIO.new(input)) do |io|
      loop do
        c = io.get_next_entry
        raise "ODT Inválido - sem content.xml" if c.nil?
        if c.name == 'content.xml'
          @content = c.get_input_stream.read
          break
        end
      end
    end
  end

  def xml
    @xml ||= Nokogiri::XML(@content)
  end

  def text
    @text ||= xml.to_s
  end

end
