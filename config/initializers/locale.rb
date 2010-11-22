# The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
# All files from in config/locales/**/*.rb,yml are added automatically.

I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
I18n.default_locale = :es_ES

# Overwrtie I18n.available_locales, with our supported locales
module I18n
  def self.available_locales
    [:es_ES, :gl_ES]
  end
end


AVAILABLE_LANGUAGES =
  I18n.available_locales.inject({}) do |acum, value|
    I18n.locale = value
    acum[value] = I18n.t('this_file_language')
    acum
  end.freeze

LOCALE_IDENTIFIER = :locale

#puts "LANGUAGES: #{AVAILABLE_LANGUAGES.to_yaml}"

