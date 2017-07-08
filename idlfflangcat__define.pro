; $Id: //depot/idl/releases/IDL_80/idldir/lib/idlfflangcat__define.pro#1 $
;
; Copyright (c) 2003-2010, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; CLASS_NAME:
; IDLffLangCat
;
; PURPOSE:
; An IDLffLangCat object provides an interface to IDL language
; catalog files.
;
; CATEGORY:
; Internationalization
;
; SUPERCLASSES:
;       This class has no superclasses.
;       IDLffLangCat_AppName inherits from IDLffXMLSAX.
;
; SUBCLASSES:
;       This class has no subclasses.
;
; CREATION:
;       See IDLffLangCat::Init
;
; METHODS:
;       IDLffLangCat::Cleanup
;       IDLffLangCat::DefineMessageBlock
;       IDLffLangCat::Query
;       IDLffLangCat::GetProperty
;       IDLffLangCat::SetProperty
;       IDLffLangCat::AppendCatalog
;       IDLffLangCat::_GetApplicationFiles
;       IDLffLangCat::_Load
;       IDLffLangCat::Init
;
;       IDLffLangCat_Appname::Init
;       IDLffLangCat_Appname::GetAppName
;       IDLffLangCat_Appname::Error
;       IDLffLangCat_Appname::FatalError
;       IDLffLangCat_Appname::StartElement
;
;       IDLffLangCat_Show_Error
;       IDLffLangCat_Swallow_Error
;
; MODIFICATION HISTORY:
;   Created by:  AGEH, December 2003
;-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This section describes the helper class IDLffLangCat_AppName
;; This class should not need to be invoked directly
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;----------------------------------------------------------------------------
;; IDLffLangCat_AppName::getAppName
;;
;; Purpose:
;;   Returns the application name of the given catalog input file.
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
FUNCTION IDLffLangCat_AppName::getAppName
  compile_opt idl2, hidden

  return,self.application_name

END

;;----------------------------------------------------------------------------
;; IDLffLangCat_AppName::Error
;;
;; Purpose:
;;   The IDLffXMLSAX::Error procedure method is called when the parser
;;   detects an error that is not expected to be fatal.
;;
;; Parameters:
;;   ID - not used
;;
;;   LINENUMBER - the line number of the file where the error occurred
;;
;;   COLUMNNUMBER - the column number where the error occurred
;;
;;   MESSAGE - the error message
;;
;; Keywords:
;;   NONE
;;
PRO IDLffLangCat_AppName::Error,ID,LineNumber,ColumnNumber,Message
  compile_opt idl2, hidden

  self->stopParsing

END

;;----------------------------------------------------------------------------
;; IDLffLangCat_AppName::FatalError
;;
;; Purpose:
;;   The IDLffXMLSAX::Error procedure method is called when the parser
;;   detects a fatal error.
;;
;; Parameters:
;;   ID - not used
;;
;;   LINENUMBER - the line number of the file where the error occurred
;;
;;   COLUMNNUMBER - the column number where the error occurred
;;
;;   MESSAGE - the error message
;;
;; Keywords:
;;   NONE
;;
PRO IDLffLangCat_AppName::FatalError,ID,LineNumber,ColumnNumber,Message
  compile_opt idl2, hidden

  self->stopParsing

END

;;----------------------------------------------------------------------------
;; IDLffLangCat_AppName::startElement
;;
;; Purpose:
;;   The IDLffXMLSAX::StartElement procedure method is called when the
;;   parser detects the beginning of an element.  It stores the value
;;   of the APPLICATION attribute, if it exists, from the first
;;   element of the input file.
;;
;; Parameters:
;;   VOID1,VOID2 - not used
;;
;;   NAME - A string containing the element name found in the XML
;;          file.
;;
;;   ATTRNAME - A string array representing the names of the
;;              attributes associated with the element, if any.
;;
;;   ATTRVALUE - A string array representing the values of each
;;               attribute associated with the element, if any. The
;;               returned array will have the same number of elements
;;               as the array returned in the attrName keyword
;;               variable.
;;
;; Keywords:
;;   NONE
;;
PRO IDLffLangCat_AppName::startElement,void1,void2,name,attrName,attrValue
  compile_opt idl2, hidden

  wh = where(attrName EQ 'APPLICATION')
  IF wh[0] NE -1 THEN self.application_name = attrValue[wh]
  self->stopParsing

END

;;----------------------------------------------------------------------------
;; IDLffLangCat_AppName::init
;;
;; Purpose:
;;   Initialization routine
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   FILENAME (required) - name of input XML catalog file
;;
FUNCTION IDLffLangCat_AppName::init,filename=filename
  compile_opt idl2, hidden

  ;; catch errors if bad input file
  ErrorStatus = 0
  CATCH, ErrorStatus
  IF (ErrorStatus NE 0) THEN BEGIN
    CATCH, /CANCEL
    MESSAGE, /RESET
    return,0
  ENDIF

  self->parsefile,filename
  return,1

END

;;----------------------------------------------------------------------------
;; IDLffLangCat_AppName__define
;;
;; Purpose:
;;   Definition routine for the appname object
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
PRO IDLffLangCat_AppName__define
  compile_opt idl2, hidden

  void = {IDLffLangCat_AppName,inherits IDLffXMLSAX, $
          application_name:''}

END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This section hold the two error handling routines needed by the DOM
;; parser
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;----------------------------------------------------------------------------
;; idlfflangcat_show_error
;;
;; Purpose:
;;   output DOM error messages
;;
;; Parameters:
;;   FILENAME - the name of the input file
;;
;;   LINENUMBER - the line number where the parsing error occurred
;;
;;   COLUMNNUMBER - the column number where the parsing error occurred
;;
;;   MESSAGE - the parser error message
;;
;; Keywords:
;;   NONE
;;
PRO idlfflangcat_show_error,filename,linenumber,columnnumber,message
  compile_opt hidden,idl2

  message,/informational,/noname, $
          'A parsing error occurred at line '+strtrim(linenumber,2)+ $
          ', column '+strtrim(columnnumber,2)+', in file: '+filename

END

;;----------------------------------------------------------------------------
;; idlfflangcat_swallow_error
;;
;; Purpose:
;;   swallows all DOM parser error messages
;;
;; Parameters:
;;   FILENAME - the name of the input file
;;
;;   LINENUMBER - the line number where the parsing error occurred
;;
;;   COLUMNNUMBER - the column number where the parsing error occurred
;;
;;   MESSAGE - the parser error message
;;
;; Keywords:
;;   NONE
;;
PRO idlfflangcat_swallow_error,filename,linenumber,columnnumber,message
  compile_opt hidden,idl2
END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This section describes the main class IDLffLangCat
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;----------------------------------------------------------------------------
;; IDLffLangCat::Cleanup
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
PRO IDLffLangCat::Cleanup
  compile_opt hidden,idl2

  ptr_free,[self.filenames,self._available_files,self.applications, $
            self.application_path,self.keys,self.strings,self.def_keys, $
            self.def_strings,self.available_languages]

END

;;----------------------------------------------------------------------------
;; IDLffLangCat::DefineMessageBlock
;;
;; Purpose:
;;   Defines the message block needed for reporting initialization
;;   errors
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
PRO IDLffLangCat::DefineMessageBlock
  compile_opt hidden,idl2

  blockname = 'IDL_MBLK_LANGCAT'
  prefix = 'IDL_M_LANGCAT_'
  names = ['FILENOTFOUND','DIRNOTFOUND','APPNOTFOUND','LANGNOTFOUND', $
           'DEFLANGNOTFOUND','BADLANGUAGE','BADINPUT','NOCATFILES']
  formats = ['IDLFFLANGCAT::INIT: Input file not found: %s', $
             'IDLFFLANGCAT::INIT: Application directory not found: %s', $
             'IDLFFLANGCAT::INIT: Application not found: %s', $
             'IDLFFLANGCAT::INIT: Language not found', $
             'IDLFFLANGCAT::INIT: Default language not found', $
             'IDLFFLANGCAT::INIT: A single language must be specified', $
             'IDLFFLANGCAT::INIT: Either an application(s) or a ' + $
                                 'filename(s) must be specified', $
             'IDLFFLANGCAT::INIT: No catalog files were found']
  DEFINE_MSGBLK,blockname,names,formats,PREFIX=prefix,/IGNORE_DUPLICATE

END

;;----------------------------------------------------------------------------
;; IDLffLangCat::Query
;;
;; Purpose:
;;   Returns the string, or array of strings, that correspond with the
;;   supplied key value(s).
;;
;; Parameters:
;;   KEY (required) - A string, or array of strings
;;
;; Keywords:
;;   DEFAULT_STRING = A string that will be returned in the key is not
;;   found.  This can be an array and if there are few elements in
;;   DEFAULT_STRING than are in KEY the values in DEFAULT_STRING will
;;   cycle.  If no DEFAULT_STRING is supplied a null string will be
;;   used.
;;
;; Return value:
;;   The string, or array of strings, one element for each element of KEY
;;
FUNCTION IDLffLangCat::Query, key, DEFAULT_STRING=defString
  compile_opt hidden,idl2

  ;; let's see how many keys the user is requesting
  num_user_keys = N_ELEMENTS(key)
  IF num_user_keys EQ 0 THEN return,'IDLffLangCat:: No key supplied'

  IF n_elements(defString) EQ 0 THEN defString = ''
  nDef = n_elements(defString)

  ret_str = strarr(num_user_keys)

  FOR i=0,num_user_keys-1 DO BEGIN
    found = ptr_valid(self.keys) ? $
            where(strupcase(key[i]) EQ (*self.keys)) : -1
    ;; if nothing found, check default language
    IF found[0] EQ -1 && ptr_valid(self.def_keys) THEN $
      defFound = where(strupcase(key[i]) EQ *self.def_keys) $
    ELSE $
      defFound = -1
    CASE 1 OF
      ;; use string from current language
      found[0] NE -1 : ret_str[i] = (*self.strings)[found]
      ;; use string from default language
      defFound[0] NE -1 : ret_str[i] = (*self.def_strings)[defFound]
      ;; if defString is a scalar return it
      size(defString,/n_dimensions) EQ 0 : ret_str[i] = defString
      ;; return array index of defString, or a null string
      ELSE : ret_str[i] = (i GE nDef ? '' : defString[i])
    ENDCASE
  ENDFOR

  ;; if only one key, return a scalar instead of a one element array
  IF n_elements(ret_str) EQ 1 THEN return,ret_str[0]
  return,ret_str

END

;;----------------------------------------------------------------------------
;; IDLffLangCat::GetProperty
;;
;; Purpose:
;;   Retrieves a property or some properties
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   APP_NAME - The name(s) of the current application(s)
;;
;;   APP_PATH - The names of the directories searched for the
;;              application(s)
;;
;;   FILENAME - The name of the file(s) currently loaded
;;
;;   KEYS - A list of all the currently loaded keys
;;
;;   N_KEYS - The number of keys currently loaded
;;
;;   DEFAULT_KEYS - A list of all the currently loaded keys in the
;;                  default language
;;
;;   DEFAULT_N_KEYS - The number of keys currently loaded in the
;;                    default language
;;
;;   LANGUAGE - The current language
;;
;;   DEFAULT_LANGUAGE - The default language
;;
;;   AVAILABLE_LANGUAGES - A list of all languages that exist in the
;;                         input file
;;
;    VERBOSE - The value of the verbose flag
;;
PRO IDLffLangCat::GetProperty, $
  APP_NAME=appName, $
  APP_PATH=appPath, $
  FILENAME=filename, $
  KEYS=keys, $
  N_KEYS=nkeys, $
  LANGUAGE=language, $
  AVAILABLE_LANGUAGES=availablelanguages, $
  DEFAULT_LANGUAGE=defLanguage, $
  DEFAULT_KEYS=defKeys, $
  DEFAULT_N_KEYS=defNKeys, $
  VERBOSE=verbose

  compile_opt hidden,idl2

  if (ARG_PRESENT(appName)) then $
    appName = ptr_valid(self.applications) ? *self.applications : ''

  if (ARG_PRESENT(appPath)) then $
    appPath = ptr_valid(self.application_path) ? *self.application_path : ''

  if (ARG_PRESENT(filename)) then $
    filename = ptr_valid(self.filenames) ? *self.filenames : ''

  if (ARG_PRESENT(keys)) then $
    keys = ptr_valid(self.keys) ? *self.keys : ''

  if (ARG_PRESENT(nkeys)) then $
    nkeys = self.n_keys

  if (ARG_PRESENT(language)) then $
    language = self.language

  if (ARG_PRESENT(defKeys)) then $
    defKeys = ptr_valid(self.def_keys) ? *self.def_keys : ''

  if (ARG_PRESENT(defNKeys)) then $
    defNKeys = self.n_def_keys

  if (ARG_PRESENT(defLanguage)) then $
    defLanguage = self.default_language

  if (ARG_PRESENT(availablelanguages)) then $
    availablelanguages = $
      ptr_valid(self.available_languages) ? *self.available_languages : ''

  if (ARG_PRESENT(verbose)) then $
    verbose = self.verbose

END

;;----------------------------------------------------------------------------
;; IDLffLangCat::SetProperty
;;
;; Purpose:
;;   Sets the properties of the object
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   LANGUAGE - a string containing the name of the LANGUAGE to load
;;              from the catalog.
;;
;;   VERBOSE - sets the verbose flag
;;
PRO IDLffLangCat::SetProperty, LANGUAGE=language, VERBOSE=verbose
  compile_opt hidden,idl2

  IF n_elements(verbose) THEN self.verbose = keyword_set(verbose)

  IF n_elements(language) THEN BEGIN
    self.language = language
    ;; reset file list
    IF ptr_valid(self._available_files) THEN $
      *self.filenames = *self._available_files
    self.n_keys = 0
    self->_Load,self.language
  ENDIF

END

;;----------------------------------------------------------------------------
;; IDLffLangCat::AppendCatalog
;;
;; Purpose:
;;   Adds key/value pairs, in the current language, to the catalog
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   APP_NAME - A string containing the name of the desired
;;              application
;;
;;   APP_PATH - a string containing the directory in which to search
;;              for the given application
;;
;;   FILENAME - a string (array) containing the name(s) of the catalog
;;              to load
;;
;; Return value:
;;   True (1) if a valid catalog was found and loaded, False (0) if
;;   not
;;
FUNCTION IDLffLangCat::AppendCatalog, APP_NAME=appName, $
                                      APP_PATH=appPathIn, $
                                      FILENAME=filenameIn
  compile_opt hidden,idl2

  IF self.verbose THEN $
    message,/informational,/noname, $
            '*** Begin IDLffLangCat AppendCatalog log ***'

  ;; make copies so as not to alter incoming variables
  IF (n_elements(appPathIn) NE 0) THEN appPath = appPathIn
  IF (n_elements(filenameIn) NE 0) THEN filename = filenameIn

  ;; verify all directories in appPath and trim non-existing ones
  IF (n_elements(appPath) NE 0) AND (n_elements(appName) NE 0) THEN BEGIN
    FOR i=0,n_elements(appPath)-1 DO $
      appPath[i] = (file_search(appPath[i],/mark_directory,/test_directory))[0]
    wh = where(appPath EQ '',complement=com)
    IF com[0] NE -1 THEN appPath = appPath[com] ELSE $
      appPath=''
  ENDIF
  IF n_elements(appPath) EQ 0 THEN appPath='IDLFFLANGCAT_NO_VALID_DIRECTORIES'

  IF self.verbose && $
    (appPath[0] NE 'IDLFFLANGCAT_NO_VALID_DIRECTORIES') && $
      (appPath[0] NE '') THEN BEGIN
    message,/informational,/noname, $
            'Valid input application path(s):'
    FOR i=0,n_elements(appPath)-1 DO $
      message,/informational,/noname,appPath[i]
  ENDIF

  ;; if appName was specified use it, otherwise check and use filename
  IF n_elements(appName) NE 0 THEN BEGIN
    IF self.verbose THEN BEGIN
      message,/informational,/noname, $
              'Input application strings(s):'
      FOR i=0,n_elements(appName)-1 DO $
        message,/informational,/noname,appName[i]
    ENDIF
    files = self->_GetApplicationFiles(appName,appPath)
  ENDIF ELSE BEGIN
    files=''
    IF (n_elements(filename) NE 0) THEN BEGIN
      FOR i=0,n_elements(filename)-1 DO $
        filename[i] = (file_search(filename[i],/fully_qualify_path))[0]
      wh = where(filename EQ '',complement=com)
      IF com[0] NE -1 THEN files = filename[com]
    ENDIF
  ENDELSE

  ;; eliminate files that are in the current list
  IF ptr_valid(self.filenames) THEN BEGIN
    FOR i=0,n_elements(*self.filenames)-1 DO BEGIN
      wh = where(files EQ (*self.filenames)[i],complement=com)
      IF wh[0] NE -1 THEN BEGIN
        IF com[0] NE -1 THEN files = files[com] ELSE files = ''
      ENDIF
    ENDFOR
  ENDIF

  ;; bail if no matching files exist
  IF (n_elements(files) EQ 1) && (files EQ '') THEN BEGIN
    IF self.verbose THEN BEGIN
      message,/informational,/noname,'No new files added to catalog'
      message,/informational,/noname, $
              '*** End IDLffLangCat AppendCatalog log ***'
    ENDIF
    return,0
  ENDIF

  ;; eliminate paths that are in the current list
  IF ptr_valid(self.application_path) THEN BEGIN
    FOR i=0,n_elements(*self.application_path)-1 DO BEGIN
      wh = where(appPath EQ (*self.application_path)[i],complement=com)
      IF wh[0] NE -1 THEN BEGIN
        IF com[0] NE -1 THEN appPath = appPath[com] ELSE $
          appPath = 'IDLFFLANGCAT_NO_VALID_DIRECTORIES'
      ENDIF
    ENDFOR
  ENDIF

  ;; add appPath to the list
  IF appPath[0] NE 'IDLFFLANGCAT_NO_VALID_DIRECTORIES' THEN BEGIN
    IF ptr_valid(self.application_path) THEN $
      *self.application_path = [*self.application_path,appPath] $
    ELSE $
      self.application_path = ptr_new(appPath)
  ENDIF

  ;; get number of current files
  nFiles = ptr_valid(self.filenames) ? n_elements(*self.filenames) : 0

  ;; add files to current list
  IF ptr_valid(self.filenames) THEN $
    *self.filenames = [*self.filenames,files] $
  ELSE $
    self.filenames = ptr_new(files)

  IF self.verbose THEN BEGIN
    message,/informational,/noname, $
            'Added files:'
    FOR i=0,n_elements(files)-1 DO $
      message,/informational,/noname,files[i]
  ENDIF

  ;; add files to available files list
  IF ~ptr_valid(self._available_files) THEN BEGIN
    self._available_files = ptr_new(files)
  ENDIF ELSE BEGIN
    *self._available_files = [*self._available_files,files]
    *self._available_files = $
      (*self._available_files)[uniq(*self._available_files, $
                                    sort(*self._available_files))]
  ENDELSE

  self->_Load,self.language,append=nFiles

  ;; save application names from the files
  self->_GetApplicationNames

  IF ptr_valid(self.applications) && self.verbose THEN BEGIN
    message,/informational,/noname,'Application names found in all files:'
    FOR i=0,n_elements(*self.applications)-1 DO $
      message,/informational,/noname,(*self.applications)[i]
  ENDIF

  IF self.verbose THEN $
    message,/informational,/noname, $
            '*** End IDLffLangCat AppendCatalog log ***'

  return,1

END

;;----------------------------------------------------------------------------
;; IDLffLangCat::_StrReplace
;;
;; Purpose:
;;   Replaces all occurrences of [pattern] in str with [replacement].
;;   Note:  This is a quick and dirty undocumented internal routine
;;   with no error checking whatsoever.
;;
;; Parameters:
;;   STR (required) - input scalar string
;;
;;   PATTERN (required) - scalar string to search for and replace
;;
;;   REPLACEMENT (required) - scalar string used to replace any
;;                            occurrences of [pattern]
;;
;; Keywords:
;;   NONE
;;
FUNCTION IDLffLangCat::_StrReplace,str,pattern,replacement
  compile_opt hidden,idl2

  return, ((pos=strpos(str,pattern))) EQ -1 ? str : $
    strmid(str,0,pos) + replacement + $
    self->_StrReplace(strmid(str,pos+strlen(pattern)),pattern,replacement)

END

;;----------------------------------------------------------------------------
;; IDLffLangCat::_GetApplicationNames
;;
;; Purpose:
;;   Returns the application names from all the available files
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
PRO IDLffLangCat::_GetApplicationNames
  compile_opt idl2, hidden

  ptr_free,self.applications

  IF ~ptr_valid(self._available_files) then return

  ;; go through each file and get application name, if any.
  FOR i=0,n_elements(*self._available_files)-1 DO BEGIN
    langCat = obj_new('IDLffLangCat_AppName', $
                      filename=(*self._available_files)[i])
    appName = obj_valid(langCat) ? langCat->getAppName() : ''
    IF obj_valid(langCat) THEN obj_destroy,langCat
    IF appName EQ '' THEN CONTINUE
    appList = n_elements(appList) EQ 0 ? appName : [appList,appName]
  ENDFOR

  IF n_elements(appList) EQ 0 THEN return

  appListTemp = strupcase(appList)
  ;; sort out possible duplicate names
  self.applications = $
    ptr_new(appList[uniq(appListTemp,sort(appListTemp))])

END

;;----------------------------------------------------------------------------
;; IDLffLangCat::_GetApplicationFiles
;;
;; Purpose:
;;   Returns the file name(s) of the given catalog application.
;;
;; Parameters:
;;   APPLICATION (required) - name of input catalog application(s)
;;
;;   APP_DIR - name of directory(s) in which to look for the
;;             application(s)
;;
;; Keywords:
;;   NONE
;;
FUNCTION IDLffLangCat::_GetApplicationFiles,applications,app_dir
  compile_opt idl2, hidden

  ;; make a local copy so as not to change the incoming variable
  application = applications

  ;; if directory(s) is supplied, look there
  IF (n_elements(app_dir) NE 0) && $
    (app_dir[0] NE 'IDLFFLANGCAT_NO_VALID_DIRECTORIES') THEN BEGIN
    ;; filter out any possible null strings
    wh = where(app_dir EQ '',complement=com)
    IF wh[0] NE -1 THEN BEGIN
      ;; if only null strings were passed in, return nothing
      IF com[0] NE -1 THEN app_dir = app_dir[com] ELSE return,''
    ENDIF
    directory = strtrim(app_dir,2)
    ;; add trailing path separation character if needed
    FOR i=0,n_elements(directory)-1 DO $
      IF strpos(directory[i],path_sep(),/reverse_search) NE $
        (strlen(directory[i])-1) THEN directory[i]+=path_sep()
    files = file_search(directory+'*.cat',/fully_qualify_path)
  ENDIF ELSE BEGIN
    files = file_search('./*.cat',/fully_qualify_path)
  ENDELSE

  IF files[0] EQ '' THEN return,'IDLFFLANGCAT_NO_INPUT_FILES_FOUND'

  ;; determine if wildcard matching is needed
  wildcard = bytarr(n_elements(application))
  FOR i=0,n_elements(application)-1 DO BEGIN
    IF strpos(application[i],'*') NE -1 THEN BEGIN
      wildcard[i] = 1b
      application[i] = self->_StrReplace(application[i],'*','.*')
    ENDIF
  ENDFOR

  ;; go through each file and get application name, if any.
  applicationFound = bytarr(n_elements(application))
  fileNames = ''
  FOR i=0,n_elements(files)-1 DO BEGIN
    langCat = obj_new('IDLffLangCat_AppName',filename=files[i])
    appName = obj_valid(langCat) ? langCat->getAppName() : ''
    IF obj_valid(langCat) THEN obj_destroy,langCat
    IF appName EQ '' THEN CONTINUE
    match = 0
    FOR j=0,n_elements(application)-1 DO BEGIN
      found = $
        (wildcard[j] ? $
         (stregex(strupcase(appName),strupcase(application[j])) NE -1): $
         (strupcase(appName) EQ strupcase(application[j])))
      match >= found
      applicationFound[j] >= found
    ENDFOR
    IF match THEN fileNames = [fileNames,files[i]]
  ENDFOR

  wh = where(~applicationFound)
  IF self.strict && (wh[0] NE -1) THEN $
    return,['IDLFFLANGCAT_APPLICATION_NOT_FOUND',applications[wh[0]]]

  ;; remove possible duplicate filenames
  valid = bytarr(n_elements(fileNames))+1b
  FOR i=0,n_elements(fileNames)-2 DO $
    IF (where(fileNames[i+1:*] EQ fileNames[i]))[0] NE -1 THEN valid[i] = 0b
  fileNames = fileNames[where(valid)]

  IF n_elements(fileNames) GT 1 THEN return,fileNames[1:*]
  return,''

END

;;----------------------------------------------------------------------------
;; IDLffLangCat::_Load
;;
;; Purpose:
;;   Loads file and updates key/string pair arrays for current
;;   language
;;
;; Parameters:
;;   LANGUAGE - A scalar string denoting the language to load
;;
;; Keywords:
;;   DEFAULT - If set load the default language
;;
;;   APPEND - the index into the list of the filenames indicating
;;            where to start for appending purposes.
;;
PRO IDLffLangCat::_Load,language,default=default,append=append
  compile_opt hidden,idl2

  ;; if langauge not specified or no files exist, return
  IF (n_elements(language) EQ 0) || (~ptr_valid(self.filenames)) THEN BEGIN
    IF ~keyword_set(default) THEN ptr_free,[self.keys,self.strings]
    return
  ENDIF

  IF self.verbose && keyword_set(default) THEN $
    message,/informational,/noname, $
    'Creating default language: '+language $
  ELSE IF self.verbose THEN $
    message,/informational,/noname, $
    'Updating current language: '+language

  ; If our desired language is the same as the default language,
  ; and we aren't appending, then just copy the default.
  if (self.default_language && $
      (strupcase(language) eq strupcase(self.default_language)) && $
        ~KEYWORD_SET(default) && N_ELEMENTS(append) eq 0) then begin
    if (ptr_valid(self.keys) && (self.keys NE self.def_keys)) then begin
      ptr_free, self.keys
      ptr_free, self.strings
    endif
    self.keys = self.def_keys
    self.strings = self.def_strings
    self.n_keys = self.n_def_keys
    self.language = language
    return
  endif
  IF (~keyword_set(append) && (self.keys EQ self.def_keys)) THEN BEGIN
    self.keys = ptr_new()
    self.strings = ptr_new()
  ENDIF

  ;; number of key/values in each allocated block
  blockSize = 1000
  ;; if appending save current keys, else reset keys
  IF n_elements(append) NE 0 THEN BEGIN
    keys = ptr_valid(self.keys) ? [*self.keys,strarr(blockSize)] : strarr(blockSize)
    strings = ptr_valid(self.strings) ? [*self.strings,strarr(blockSize)] : strarr(blockSize)
  ENDIF ELSE BEGIN
    keys = strarr(blockSize)
    strings = strarr(blockSize)
  ENDELSE
  ;; mark current position
  currPos = (where(keys EQ ''))[0]

  ;; set DOM error handling routines
  IF self.verbose THEN $
    error_file = 'idlfflangcat_show_error' $
  ELSE $
    error_file = 'idlfflangcat_swallow_error'

  ;; set starting index based on value of append
  IF n_elements(append) EQ 0 THEN i=0 ELSE i=append[0]>0

  WHILE i LT n_elements(*self.filenames) DO BEGIN

    ;; catch errors if bad input file
    ErrorStatus = 0
    CATCH, ErrorStatus
    IF (ErrorStatus NE 0) THEN BEGIN
      CATCH, /CANCEL
      obj_destroy,oDoc
      ;; remove file from available filelist
      IF !error_state.msg NE 'no keys found' THEN BEGIN
        ;; send error message
        IF self.verbose THEN $
          message,/informational,/noname, $
                  (*self.filenames)[i]+' is not a valid input file'
        wh = where((*self.filenames)[i] EQ *self._available_files, $
                   complement=com)
        IF com[0] NE -1 THEN BEGIN
          *self._available_files = (*self._available_files)[com]
        ENDIF ELSE BEGIN
          *self._available_files = ''
        ENDELSE
      ENDIF
      message,/reset
      ;; remove file from filelist
      IF n_elements(*self.filenames) EQ 1 THEN BEGIN
        *self.filenames = ''
        return
      ENDIF ELSE BEGIN
        CASE 1 OF
          i EQ 0 : *self.filenames = (*self.filenames)[1:*]
          i EQ n_elements(*self.filenames)-1 : BEGIN
            *self.filenames=(*self.filenames)[0:n_elements(*self.filenames)-2]
            flag = 1
          END
          ELSE : *self.filenames = $
            [(*self.filenames)[0:i-1],(*self.filenames)[i+1:*]]
        ENDCASE
        ;; if last file in list was removed then break out of loop
        IF n_elements(flag) THEN BREAK
        i--
      ENDELSE
      i++
      ;; start the next iteration of while loop, which will reset the
      ;; catch block
      CONTINUE
    ENDIF

    ;; Create new DOM object and load file
    oDoc = obj_new('IDLffXMLDOMDocument')
    oDoc->Load,filename=(*self.filenames)[i], $
               msg_error=error_file,msg_fatal=error_file, $
               msg_warning=error_file

    IF self.verbose THEN $
      message,/informational,/noname, $
              'Reading file: '+(*self.filenames)[i]

    ;; find all language tags
    oNodeList = oDoc->GetElementsByTagName('LANGUAGE')
    nLangs = oNodeList->GetLength()
    nKeys = 0
    langFound = 0b
    FOR j=0,nLangs-1 DO BEGIN
      oLang = oNodeList->item(j)
      oNodeMap = oLang->GetAttributes()
      oName = oNodeMap->GetNamedItem('NAME')
      lang = oName->GetNodeValue()
      IF self.verbose THEN $
        message,/informational,/noname, $
                'Processing language: '+lang
      ;; add language to available languages list
      IF ~ptr_valid(self.available_languages) THEN BEGIN
        IF self.verbose THEN $
          message,/informational,/noname, $
                  'Adding: '+lang+' to the available language list'
        self.available_languages = ptr_new([lang])
      ENDIF ELSE BEGIN
        wh = where(strupcase(lang) EQ strupcase(*self.available_languages))
        IF wh[0] EQ -1 THEN BEGIN
          IF self.verbose THEN $
            message,/informational,/noname, $
                    'Adding: '+lang+' to the available language list'
          *self.available_languages = [*self.available_languages,lang]
          *self.available_languages = $
            (*self.available_languages)[sort(*self.available_languages)]
        ENDIF ELSE BEGIN
          IF lang NE (*self.available_languages)[wh] THEN BEGIN
            IF self.verbose THEN $
              message,/informational,/noname, $
                      'Replacing, '+(*self.available_languages)[wh]+ $
                      ', with, '+lang+' in the available language list'
            (*self.available_languages)[wh] = lang
          ENDIF
        ENDELSE
      ENDELSE
      IF strupcase(lang) EQ strupcase(language) THEN BEGIN
        langFound = 1b
        ;; load keys
        oKeyList = oLang->GetElementsByTagName('KEY')
        nKeys = oKeyList->GetLength()
        FOR k=0,nKeys-1 DO BEGIN
          oKey = oKeyList->item(k)
          oKeyNodeMap = oKey->GetAttributes()
          ;; get name attribute
          oKeyName = oKeyNodeMap->GetNamedItem('NAME')
          ;; get key
          key = oKeyName->GetNodeValue()

          ;; get text node
          oKeyChildren = oKey->GetChildNodes()
          oKeyText = oKeyChildren->item(0)
          ;; get text
          valueText = obj_valid(oKeyText) ? oKeyText->GetNodeValue() : ''

          ;; check for duplicate keys
          wh = where(strupcase(key) EQ keys)
          IF wh[0] NE -1 THEN BEGIN
            ;; save error message
            IF self.verbose THEN $
              message,/informational,/noname, $
                      'Replacing old Key: '+keys[wh[0]]+', Value: '+ $
                      strings[wh[0]]+', with new Key: '+key+', Value: '+ $
                      valueText
            ;; replace key/value pair
            keys[wh[0]] = strupcase(key)
            strings[wh[0]] = valueText
          ENDIF ELSE BEGIN
            IF self.verbose THEN $
              message,/informational,/noname, $
                      'Adding key/value: '+key+' , '+valueText
            IF ~((currPos+1) MOD blockSize) THEN BEGIN
              keys = [keys, strarr(blockSize)]
              strings = [strings, strarr(blockSize)]
            ENDIF
            keys[currPos] = strupcase(key)
            strings[currPos] = valueText
            currPos++
          ENDELSE
        ENDFOR
      ENDIF
    ENDFOR
    obj_destroy,oDoc
    IF self.verbose THEN BEGIN
      IF (nKeys EQ 0) THEN BEGIN
        message,/informational,/noname,'No keys found for current language'
      ENDIF ELSE BEGIN
        message,/informational,/noname,strtrim(nKeys,2)+ $
                ' keys added to current language'
      ENDELSE
    ENDIF
    ;; if no keys found, remove from current filelist
    IF ~nKeys && ~langFound THEN message,/noname,'no keys found'
    i++
  ENDWHILE

  ;; return if no keys found
  IF (keys[0] EQ '') THEN BEGIN
    IF keyword_set(default) THEN $
      self.default_language = language $
    ELSE $
      self.language = language
    IF ptr_valid(self.keys) THEN BEGIN
      *self.keys = ''
      *self.strings = ''
    ENDIF ELSE BEGIN
      self.keys = ptr_new('')
      self.strings = ptr_new('')
    ENDELSE
    self.n_keys = n_elements(*self.keys)
    return
  ENDIF

  IF keyword_set(default) THEN BEGIN
    ;; set up default language properties
    self.def_keys = ptr_new(keys[0:currPos-1])
    self.n_def_keys = n_elements(*self.def_keys)
    self.def_strings = ptr_new(strings[0:currPos-1])
    self.default_language = language
  ENDIF ELSE BEGIN
    ;; update current properties, adding to list if one exists
    IF ptr_valid(self.keys) THEN BEGIN
      *self.keys = keys[0:currPos-1]
      *self.strings = strings[0:currPos-1]
    ENDIF ELSE BEGIN
      self.keys = ptr_new(keys[0:currPos-1], /no_copy)
      self.strings = ptr_new(strings[0:currPos-1], /no_copy)
    ENDELSE
    self.n_keys = n_elements(*self.keys)
    self.language = language
  ENDELSE

END

;;----------------------------------------------------------------------------
;; IDLffLangCat::Init
;;
;; Purpose:
;;   Initialization routine for the IDLffLangCat object
;;
;; Parameters:
;;   LANGUAGE - a string containing the name of the LANGUAGE to load
;;              from the catalog.  If LANGUAGE is not specified or is
;;              a null string then the DEFAULT_LANGUAGE from the
;;              catalog will be loaded
;;
;; Keywords:
;;   APP_NAME - A string containing the name of the desired
;;              application
;;
;;   APP_PATH - a string containing the directory in
;;              which to search for the given application
;;
;;   RSI_APP_PATH - Undocumented: THIS IS FOR INTERNAL RSI USE ONLY.
;;                  A string denoting the directory in which to search
;;                  for files.  This is a single directory that can be
;;                  found in the resource/langcat directory.
;;                  Example:  If RSI_APPLICATION='itools' then the
;;                  directory searched for files will be:
;;                    /idldir/resource/langcat/itools/
;;                  This is prepended to any input of APP_PATH.
;;
;;   FILENAME - a string containing the name of the catalog to load
;;
;;   DEFAULT_LANGUAGE - a string containing the language to load as
;;                      the default
;;
;;   CONTINUE_ON_ERROR - if set init will return a null object if any
;;                       of the inputs are invalid, e.g., input file
;;                       does not exist, or input app_path directory
;;                       does not exist.
;;
;;   VERBOSE - if set, output messages based on loading of the input file(s)
;;
FUNCTION IDLffLangCat::Init, language, $
                             APP_NAME=application, $
                             APP_PATH=app_path, $
                             RSI_APP_PATH=rsiAppPath, $
                             FILENAME=filenames, $
                             DEFAULT_LANGUAGE=defLanguage, $
                             CONTINUE_ON_ERROR=continueonerror, $
                             VERBOSE=verbose
  compile_opt hidden,idl2

  ;; initialize error message block
  self->DefineMessageBlock

  self.verbose = keyword_set(verbose)
  self.strict = ~keyword_set(continueonerror)
  IF (n_elements(rsiAppPath) NE 0) THEN BEGIN
    str = ''
    FOR i=0,n_elements(rsiAppPath) DO $
      str = [str,filepath('',subdirectory=['resource','langcat',rsiAppPath])]
    appPath = (temporary(str))[1:*]
  ENDIF
  IF (n_elements(app_path)) NE 0 THEN $
    appPath = n_elements(appPath) EQ 0 ? app_path : [appPath,app_path]
  IF n_elements(appPath) NE 0 THEN app_path = appPath
  IF (n_elements(filenames) NE 0) THEN filename = filenames

  IF self.verbose THEN $
    message,/informational,/noname,'*** Begin IDLffLangCat log ***'

  ;; language must be specified
  IF (n_elements(language) NE 1) || (size(language,/type) NE 7) THEN BEGIN
    message,/CONTINUE,block='IDL_MBLK_LANGCAT',name='IDL_M_LANGCAT_BADLANGUAGE'
    return,0
  ENDIF

  ;; either application or filename must be specified
  IF (n_elements(application) EQ 0) && (n_elements(filename) EQ 0) THEN BEGIN
    IF self.verbose THEN BEGIN
      message,/informational,/noname, $
              'Either an application or a filename must be specified'
      message,/informational,/noname,'*** End IDLffLangCat log ***'
    ENDIF
    IF self.strict THEN BEGIN
      message,/continue,/noprint,block='IDL_MBLK_LANGCAT', $
              name='IDL_M_LANGCAT_BADINPUT'
      self->Cleanup
      return,0
    ENDIF
  ENDIF

  ;; verify all directories in appPath and trim non-existing ones
  IF (n_elements(appPath) NE 0) AND (n_elements(application) NE 0) THEN BEGIN
    FOR i=0,n_elements(appPath)-1 DO $
      appPath[i] = (file_search(appPath[i],/mark_directory,/test_directory))[0]
    wh = where(appPath EQ '',complement=com)
    IF self.strict && (wh[0] NE -1) THEN BEGIN
      IF self.verbose THEN BEGIN
        message,/informational,/noname,'An invalid app_path entry was found:'
        message,/informational,/noname,app_path[wh[0]]
        message,/informational,/noname,'*** End IDLffLangCat log ***'
      ENDIF
      message,/continue,/noprint,block='IDL_MBLK_LANGCAT', $
              name='IDL_M_LANGCAT_DIRNOTFOUND',app_path[wh[0]]
      self->Cleanup
      return,0
    ENDIF
    IF com[0] NE -1 THEN appPath = appPath[com] ELSE $
      appPath=''
  ENDIF

  IF n_elements(appPath) EQ 0 THEN appPath='IDLFFLANGCAT_NO_VALID_DIRECTORIES'
  self.application_path = ptr_new(appPath)

  IF self.verbose && $
    (appPath[0] NE 'IDLFFLANGCAT_NO_VALID_DIRECTORIES') && $
      (appPath[0] NE '') THEN BEGIN
    message,/informational,/noname, $
            'Valid input application path(s):'
    FOR i=0,n_elements(appPath)-1 DO $
      message,/informational,/noname,appPath[i]
  ENDIF

  ;; find proper files, using application if available
  IF n_elements(application) NE 0 THEN BEGIN
    IF self.verbose THEN BEGIN
      message,/informational,/noname, $
              'Input application strings(s):'
      FOR i=0,n_elements(application)-1 DO $
        message,/informational,/noname,application[i]
    ENDIF
    files = self->_GetApplicationFiles(application,*self.application_path)
    IF files[0] EQ 'IDLFFLANGCAT_APPLICATION_NOT_FOUND' THEN BEGIN
      IF self.verbose THEN BEGIN
        message,/informational,/noname,'An invalid app_name was found:'
        message,/informational,/noname,files[1]
        message,/informational,/noname,'*** End IDLffLangCat log ***'
      ENDIF
      message,/continue,/noprint,block='IDL_MBLK_LANGCAT', $
              name='IDL_M_LANGCAT_APPNOTFOUND',files[1]
      self->Cleanup
      return,0
    ENDIF
    IF files[0] EQ 'IDLFFLANGCAT_NO_INPUT_FILES_FOUND' THEN BEGIN
      IF self.verbose THEN BEGIN
        message,/informational,/noname,'No catalog files were found:'
        message,/informational,/noname,'*** End IDLffLangCat log ***'
      ENDIF
      message,/continue,/noprint,block='IDL_MBLK_LANGCAT', $
              name='IDL_M_LANGCAT_NOCATFILES'
      self->Cleanup
      return,0
    ENDIF
  ENDIF ELSE IF (n_elements(filename) NE 0) THEN BEGIN
    FOR i=0,n_elements(filename)-1 DO $
      filename[i] = (file_search(filename[i],/fully_qualify_path))[0]
    wh = where(filename EQ '',complement=com)
    IF self.strict && (wh[0] NE -1) THEN BEGIN
      IF self.verbose THEN BEGIN
        message,/informational,/noname,'An invalid file name was found:'
        message,/informational,/noname,filenames[wh[0]]
        message,/informational,/noname,'*** End IDLffLangCat log ***'
      ENDIF
      message,/continue,/noprint,block='IDL_MBLK_LANGCAT', $
              name='IDL_M_LANGCAT_FILENOTFOUND',filenames[wh[0]]
      self->Cleanup
      return,0
    ENDIF
    IF com[0] NE -1 THEN files = filename[com] ELSE files=''
  ENDIF
  IF n_elements(files) EQ 0 THEN files=''

  ;; if we have any files to use, save them
  IF files[0] NE '' THEN BEGIN
    self.filenames = ptr_new(files)
    self._available_files = ptr_new(files)
    IF self.verbose THEN BEGIN
      message,/informational,/noname,'Available files:'
      FOR i=0,n_elements(files)-1 DO $
        message,/informational,/noname,files[i]
    ENDIF
  ENDIF ELSE BEGIN
    IF self.verbose THEN $
      message,/informational,/noname,'No valid files found'
  ENDELSE

  IF n_elements(defLanguage) EQ 1 THEN BEGIN
    self->_Load,defLanguage,/default
    IF self.strict && (self.default_language EQ '') THEN BEGIN
      IF self.verbose THEN BEGIN
        message,/informational,/noname,'Default language not found'
        message,/informational,/noname,'*** End IDLffLangCat log ***'
      ENDIF
      message,/continue,/noprint,block='IDL_MBLK_LANGCAT', $
              name='IDL_M_LANGCAT_DEFLANGNOTFOUND'
      self->Cleanup
      return,0
    ENDIF
  ENDIF

  ;; reset the list of files to search (_load alters the file list)
  IF ptr_valid(self._available_files) THEN $
    *self.filenames = *self._available_files
  ;; if we have any valid files, load the current language
  IF ptr_valid(self.filenames) && ((*self.filenames)[0] NE '') THEN $
    self->_Load,language

  IF self.strict && (self.language EQ '') THEN BEGIN
    IF self.verbose THEN BEGIN
      message,/informational,/noname,'Requested language not found'
      message,/informational,/noname,'*** End IDLffLangCat log ***'
    ENDIF
    message,/continue,/noprint,block='IDL_MBLK_LANGCAT', $
            name='IDL_M_LANGCAT_LANGNOTFOUND'
    self->Cleanup
    return,0
  ENDIF

  ;; save application names from the files
  self->_GetApplicationNames

  IF ptr_valid(self.applications) && self.verbose THEN BEGIN
    message,/informational,/noname,'Application names found in files:'
    FOR i=0,n_elements(*self.applications)-1 DO $
      message,/informational,/noname,(*self.applications)[i]
  ENDIF

  IF self.verbose THEN $
    message,/informational,/noname,'*** End IDLffLangCat log ***'

  return,1

END

;;----------------------------------------------------------------------------
;; IDLffLangCat__Define
;;
;; Purpose:
;;   Definition procedure for the IDLffLangCat object
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
PRO IDLffLangCat__Define
  compile_opt hidden,idl2

  struct = {IDLffLangCat, $
            filenames: ptr_new(), $
            _available_files: ptr_new(), $
            language: '', $
            default_language: '', $
            applications: ptr_new(), $
            application_path: ptr_new(), $
            keys: ptr_new(), $
            n_keys: 0l, $
            strings: ptr_new(), $
            def_keys: ptr_new(), $
            n_def_keys: 0l, $
            def_strings: ptr_new(), $
            available_languages: ptr_new(), $
            verbose: 0b, $
            strict: 0b, $
            IDLffLangCatVersion: '1.0' $
           }
END
