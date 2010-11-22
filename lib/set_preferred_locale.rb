module SetPreferredLocale

  module Controller
    def self.included(base)
      base.class_eval do
        prepend_before_filter :set_locale        
      end
    end
  
  protected
    
    # Change I18m.locale if needed
    def set_locale
      
      locale = nil
      
      # locale param (ex: ?locale=es_ES). Most priority method to set locale
      if locale.blank? and params[LOCALE_IDENTIFIER]
        #puts ">>>>> params[LOCALE_IDENTIFIER]: #{params[LOCALE_IDENTIFIER].inspect}"
        locale = find_compatible_locale_for(params[LOCALE_IDENTIFIER])
        #puts ">>>>> find_compatible_locale_for(#{params[LOCALE_IDENTIFIER].inspect}): #{locale.inspect}"
        if locale and current_user
          current_user.locale = locale.to_s # si se guarda como symbol, extrañamente lo convierte a algo como "--- :es_ES\n"
          current_user.save(false)
        end
      end
      
      # user locale
      if locale.blank? and current_user
        #puts ">>>>> current_user.locale (#{current_user.locale.inspect})"
        locale = current_user.locale
      end
        
      # session locale
      if locale.blank? and session[LOCALE_IDENTIFIER]
        #puts ">>>>> session (#{session[LOCALE_IDENTIFIER].inspect})"
        locale = session[LOCALE_IDENTIFIER]
      end
      
      # browser (client) preferences
      if locale.blank?
        user_locales = user_preferred_languages(request)
        #puts ">>>>> user_locales (#{user_locales.inspect})"
        user_compatible_locales = user_locales.map{ |loc| find_compatible_locale_for loc}.compact
        #puts ">>>>> user_compatible_locales (#{user_compatible_locales.inspect})"
        locale = user_compatible_locales.first
      end
      
      # Set locale
      I18n.locale = find_compatible_locale_for(locale) || I18n.default_locale
      session[LOCALE_IDENTIFIER] = I18n.locale
    end
    
    # Si locale está en I18n.available_locales, devuelve locale, 
    # sino, busca alguno compatible (mirando solo los dos primeros caracteres),
    # y si tampoco encuentra nada, devuelve nil.
    def find_compatible_locale_for(locale)
      I18n.available_locales.find do |a| # Check if this locale is available
        a.to_s.gsub('-', '_') == locale.to_s.gsub('-', '_') # first check exact match (así tenemos que: "es-ES" == "es_ES" == :es_ES == :"es-ES")
      end || I18n.available_locales.find do |a|
        a.to_s.split(/-|_/, 2).first == locale.to_s.split(/-|_/, 2).first # if not exact match, try ignoring region (check just 2 first chars)
      end
    end
    
    # Método copiado de https://github.com/iain/http_accept_language/blob/master/lib/http_accept_language.rb
    # No merecía la pena instalar toda la gema cuando solo utilizamos este poquito.
    #
    # Returns a sorted array based on user preference in HTTP_ACCEPT_LANGUAGE.
    # Browsers send this HTTP header, so don't think this is holy.
    # Example: request.user_preferred_languages # => [ 'nl-NL', 'nl-BE', 'nl', 'en-US', 'en' ]
    def user_preferred_languages(request)
      @user_preferred_languages ||= request.env['HTTP_ACCEPT_LANGUAGE'].split(/\s*,\s*/).collect do |l|
        l += ';q=1.0' unless l =~ /;q=\d+\.\d+$/
        l.split(';q=')
      end.sort do |x,y|
        raise "Not correctly formatted" unless x.first =~ /^[a-z\-]+$/i
        y.last.to_f <=> x.last.to_f
      end.collect do |l|
        l.first.downcase.gsub(/-[a-z]+$/i) { |x| x.upcase }
      end
    rescue # Just rescue anything if the browser messed up badly.
      []
    end
    
  end
  
  module Helper
    def language_selection(options = {}, &block)
      options[:separator] = '&nbsp;/&nbsp;' unless options.include? :separator
      
      AVAILABLE_LANGUAGES.collect do |language_code, language|
        if block_given?
          yield language_code, language
        else
          link_to_change_locale language_code, language
        end
      end.join options[:separator]
    end
    
    # Genera un enlace a la misma página pero pasándole el locale
    # Si el locale es el actual (I18n.locale) entonces genera un span class="current_locale selected" en lugar de un enlace.
    def link_to_change_locale(language_code, language, html_options={})
      if I18n.locale.to_s == language_code.to_s
        content_tag :span, language, html_options.merge(:class  => 'current_locale selected')
      else
        link_to language, "?#{locale_identifier}=#{language_code}", html_options
      end
    end
    
    # params key that identificate a locale code
    def locale_identifier
      LOCALE_IDENTIFIER
    end
  end
end

