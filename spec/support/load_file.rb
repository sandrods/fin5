module LoadFile
  def file_as_data(filename = nil)

    if filename.present?
      file_path = Rails.root.join('spec/fabricators/pdfs', filename)
    else
      file_path = Dir.glob(Rails.root.join('spec/fabricators/pdfs/*.pdf')).sample
    end

    file_as_data = File.read(file_path)
  end
end
