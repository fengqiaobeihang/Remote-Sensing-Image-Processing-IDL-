; $Id: //depot/idl/releases/IDL_80/idldir/lib/itools/framework/idlitsrvlangcat__define.pro#1 $
;
; Copyright (c) 2003-2010, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; CLASS_NAME:
;	IDLitsrvLangCat
;
; PURPOSE:
;	This file implements the IDL Tool services needed for using
;	the language catalogs
;
; CATEGORY:
;	Internationalization
;
; SUPERCLASSES:
;       IDLitOperation
;
; SUBCLASSES:
;       This class has no subclasses.
;
; CREATION:
;       Created by the Tool system routines.
;
; METHODS:
;       IDLitsrvLangCat::Query
;       IDLitsrvLangCat::SetLanguage
;       IDLitsrvLangCat::GetAvailableLanguages
;
; MODIFICATION HISTORY:
; 	Created by:  AGEH, December 2003
;-

;;----------------------------------------------------------------------------
;; IDLitsrvLangCat::Init
;;
;; Purpose:
;;   Initialization routine
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   SIMPLE - If set only create this object, do not call init on
;;            superclasses.  This is so that the member data can be
;;            retrieved via get property without creating additional
;;            resources.
;;
FUNCTION IDLitsrvLangCat::Init, SIMPLE=simple, _extra=_extra
  compile_opt hidden,idl2

  ;; set initial values
  self._application = ptr_new(['itools*'])
  self._appDirName = 'itools'
  self._defaultLang = 'English'
  self._verbose = 0

  IF KEYWORD_SET(simple) THEN return,1

  return, self->IDLitOperation::Init(NAME='Language Catalog', _extra=_extra)

END

;;----------------------------------------------------------------------------
;; IDLitsrvLangCat::Query
;;
;; Purpose:
;;   Returns the string, or array of strings, that correspond with the
;;   supplied key value(s).
;;
;; Parameters:
;;   KEY (required) - A string, or array of strings
;;
;; Keywords:
;;   NONE
;;
;; Return value:
;;   The string, or array of strings, one element for each element of KEY
;;
FUNCTION IDLitsrvLangCat::Query, key
  compile_opt hidden, idl2

  IF ~obj_valid(self._oLangCat) THEN $
    return, 'No Valid LangCat Object'

  str = self._oLangCat->Query(key, DEFAULT_STRING='Key Not Found ['+key+']')

  return, str

END

;;----------------------------------------------------------------------------
;; IDLitsrvLangCat::SetLanguage
;;
;; Purpose:
;;   Sets the language for the catalog
;;
;; Parameters:
;;   LANGUAGE - a string containing the name of the LANGUAGE to load
;;              from the catalog.
;;
;; Keywords:
;;   NONE
;;
PRO IDLitsrvLangCat::SetLanguage, language
  compile_opt hidden, idl2

  IF n_elements(language) EQ 0 THEN return

  IF ~obj_valid(self._oLangCat) THEN BEGIN
    self._oLangCat = obj_new('IDLffLangCat',language[0], $
                             APP_NAME=*self._application, $
                             RSI_APP_PATH=self._appDirName, $
                             DEFAULT_LANGUAGE=self._defaultLang, $
                             VERBOSE=self._verbose)
  ENDIF ELSE BEGIN
    self._oLangCat->SetProperty,language=language[0]
  ENDELSE

END

;;----------------------------------------------------------------------------
;; IDLitsrvLangCat::GetAvailableLanguages
;;
;; Purpose:
;;   Returns string array of available languages
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
;; Return value:
;;   A string array containing the available languages
;;
FUNCTION IDLitsrvLangCat::GetAvailableLanguages
  compile_opt hidden,idl2

  IF obj_valid(self._oLangCat) THEN $
    self._oLangCat->GetProperty,Available_languages=availLangs $
  ELSE $
    availLangs = ''

  return, availLangs

END

;;----------------------------------------------------------------------------
;; IDLitsrvLangCat::GetLanguage
;;
;; Purpose:
;;   Returns string of current language
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
;; Return value:
;;   A string containing the current languages
;;
FUNCTION IDLitsrvLangCat::GetLanguage
  compile_opt hidden,idl2

  IF obj_valid(self._oLangCat) THEN $
    self._oLangCat->GetProperty,LANGUAGE=language $
  ELSE $
    language = ''

  return, language

END

;;----------------------------------------------------------------------------
;; IDLitsrvLangCat::_GetDefaultLanguage
;;
;; Purpose:
;;   Returns string array of default language
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
FUNCTION IDLitsrvLangCat::_GetDefaultLanguage
  compile_opt hidden,idl2

  return, self._defaultLang

END

;;----------------------------------------------------------------------------
;; IDLitsrvLangCat::GetProperty
;;
;; Purpose:
;;   Retrieves a property or some properties
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
PRO IDLitsrvLangCat::GetProperty, APP_NAME=appName, $
                                  RSI_APP_PATH=rsiAppPath, $
                                  VERBOSE=verbose, $
                                  _REF_EXTRA=_extra
  compile_opt hidden,idl2

  if (ARG_PRESENT(appName)) then $
    appName = ptr_valid(self._application) ? *self._application : ''

  if (ARG_PRESENT(rsiAppPath)) then $
    rsiAppPath = self._appDirName

  if (ARG_PRESENT(verbose)) then $
    verbose = self._verbose

  IF (n_elements(_extra) GT 0) then begin
    if obj_valid(self._oLangCat) THEN $
        self._oLangCat->GetProperty, _EXTRA=_extra
    self->IDLitOperation::GetProperty, _EXTRA=_extra
  endif

END


;;----------------------------------------------------------------------------
;; IDLitsrvLangCat::Cleanup
;;
;; Purpose:
;;   Cleanup routine
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
PRO IDLitsrvLangCat::Cleanup
  compile_opt hidden,idl2

  ptr_free,self._application
  obj_destroy,self._oLangCat

  self->IDLitOperation::Cleanup

END

;;----------------------------------------------------------------------------
;; IDLitsrvLangCat__Define
;;
;; Purpose:
;;   Definition procedure for the IDLitsrvLangCat object
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
PRO IDLitsrvLangCat__define
  compile_opt idl2, hidden

  struct = {IDLitsrvLangCat, $
            inherits IDLitOperation, $
            _oLangCat : obj_new(), $
            _appDirName : '', $
            _application : ptr_new(), $
            _defaultLang : '', $
            _verbose : 0 $
           }

END

