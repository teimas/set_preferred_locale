require 'set_preferred_locale'

ActionController::Base.send :include, SetPreferredLocale::Controller
ActionView::Base.send       :include, SetPreferredLocale::Helper

