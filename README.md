Set Preferred Locale
====================

For I18n applications.
Creates a before_filter in all controllers for change the locale if needed.

### It Checks:

  * locale param (ex: ?locale=es_ES)
  * user locale (reads current_user var)
  * session locale (reads session[LOCALE_IDENTIFIER])
  * browser (client) preferences (reads and parses the `HTTP_ACCEPT_LANGUAGE` param from the request)