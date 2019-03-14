module CkeditorHelper
  def fill_in_ckeditor(locator, opts)
    content = opts.fetch(:with).to_json # convert to a safe javascript string
    page.execute_script <<-JS
      CKEDITOR.instances['#{locator}'].setData(#{content});
      $('textarea##{locator}').text(#{content});
    JS
  end
end
