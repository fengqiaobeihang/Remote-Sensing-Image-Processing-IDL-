;; $Id: //depot/idl/releases/IDL_80/idldir/lib/itools/framework/idlitlangcatquery.pro#1 $
;;
;; Copyright (c) 2004-2010, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;;+
;; NAME:
;;       IDLitLangCatQuery.pro
;;
;; PURPOSE:
;;       Queries the lang cat system for the itools.  If no system
;;       exists then create a temporary langcat object and get the
;;       value of the key in ENGLISH
;;
;; CATEGORY:
;;       IDL iTools system
;;
;; CALLING SEQUENCE:
;;       value = IDLitLangCatQuery('Key')
;;
;; ARGUMENTS:
;;       KEY - A string, or array of strings
;;
;; KEYWORDS:
;;       LANGUAGE - If set to a named variable the current language
;;                  will be returned.
;;                  NOTE - If the itools system does not currently
;;                         exist a null string will be returned.
;;
;;       AVAILABLE_LANGUAGES - If set to a named varialbe a list of
;;                             all languages that exist in the system
;;                             will be returned.
;;                             NOTE - If the itools system does not
;;                             currently exist a null string will be
;;                             returned.
;;
;;       _VERBOSE - If set and the tool system has not been created
;;                  then run the query in verbose mode.  This is only
;;                  for debugging the itools language catalogs from
;;                  the command line.
;;
;; RETURN VALUE:
;;       A string, or array of strings, one element for each element
;;       of KEY
;;
;; CREATED BY: AGEH, April 2004.
;;
;;---

FUNCTION IDLitLangCatQuery, key, LANGUAGE=language, $
                            AVAILABLE_LANGUAGES=availLangs, $
                            _VERBOSE=verboseIn
  compile_opt hidden,idl2

  oSys = _IDLitSys_GetSystem(/NO_CREATE)

  IF obj_valid(oSys) THEN BEGIN

    ;; get the lang cat service if needed for return values
    IF arg_present(language) || arg_present(availLangs) THEN BEGIN
      oSrvLangCat = oSys->GetService('LANGCAT')
      
      IF arg_present(language) THEN $
        language = oSrvLangCat->GetLanguage()

      IF arg_present(availLangs) THEN $
        availLangs = oSrvLangCat->GetAvailableLanguages()
    ENDIF

    ;; return system langcat query
    return, oSys->LangCatQuery(key)

  ENDIF ELSE BEGIN

    ;; no system, thus no current or available languages
    IF arg_present(language) THEN $
      language = ''

    IF arg_present(availLangs) THEN $
      availLangs = ''

    ;; if key was not supplied the user only wants to to retrieve
    ;; language and available_language information 
    IF (n_elements(key) EQ 0) THEN return,''

    ;; get values from langcat service
    oSrvLangCat = obj_new('IDLitsrvLangCat',/SIMPLE)
    oSrvLangCat->GetProperty,APP_NAME=appName, $
                             RSI_APP_PATH=rsiAppPath, $
                             VERBOSE=verbose
    obj_destroy,oSrvLangCat

    ;; create new langcat object
    oLangCat = obj_new('IDLffLangCat','ENGLISH', $
                       APP_NAME=appName, $
                       RSI_APP_PATH=rsiAppPath, $
                       VERBOSE=(verbose || keyword_set(verboseIn)))
    IF obj_valid(oLangCat) THEN BEGIN
      value = oLangCat->Query(key)
      obj_destroy,oLangCat
    ENDIF ELSE $
      value = 'No Valid LangCat Object'

    return, value

  ENDELSE

END
