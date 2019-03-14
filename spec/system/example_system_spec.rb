require 'rails_helper'

describe "Example System Spec", type: :system do

  before :each do
    visit test_login_path(id: 4363, roles: 'ROOT')
  end

  it 'Shows Example Page', js: true do
    visit root_path

    expect(page).to have_text 'Examples Page'
  end

end
