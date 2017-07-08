; $Id: //depot/idl/releases/IDL_80/idldir/lib/obsolete/idlfflanguagecat__define.pro#1 $
;
; Copyright (c) 1998-2010, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; CLASS_NAME:
;	IDLffLanguageCat
;
; PURPOSE:
;	An IDLffLanguageCat object provides an interface to IDL language catalog files.
;
; CATEGORY:
;	Internationalization
;
; SUPERCLASSES:
;       This class has no superclasses.
;
; SUBCLASSES:
;       This class has no subclasses.
;
; CREATION:
;       See IDLffLanguageCat::Init
;
; METHODS:
;       Intrinsic Methods
;       This class has the following methods:
;
;       IDLffLanguageCat::Cleanup
;       IDLffLanguageCat::GetFilename
;       IDLffLanguageCat::Init
;       IDLffLanguageCat::IsValid
;       IDLffLanguageCat::Query
;       IDLffLanguageCat::SetCatalog
;
; MODIFICATION HISTORY:
; 	Written by:	Scott J. Lasica, 12/1/98
;-

;+
; =============================================================
;
; METHODNAME:
;       IDLffLanguageCat::Init
;
; PURPOSE:
;       The IDLffLanguageCat::Init function method initializes the
;       language catalog object.
;
;       NOTE: Init methods are special lifecycle methods, and as such
;       cannot be called outside the context of object creation.  This
;       means that in most cases, you cannot call the Init method
;       directly.  There is one exception to this rule: If you write
;       your own subclass of this class, you can call the Init method
;       from within the Init method of the subclass.
;
; CALLING SEQUENCE:
;       oCatalog = OBJ_NEW('IDLffLanguageCat')
;
;       or
;
;       Result = oCatalog->[IDLffLanguageCat::]Init()
;
; OUTPUTS:
;       1: successful, 0: unsuccessful.
;
; EXAMPLE:
;       oColorbar = OBJ_NEW('IDLffLanguageCat')
;
; MODIFICATION HISTORY:
; 	Written by:	Scott J. Lasica, 11/11/98
;-

FUNCTION IDLffLanguageCat::Init
	self.filename = ''
	self.cat_lun = -1
	return, 1
END

;+
; =============================================================
;
; METHODNAME:
;       IDLffLanguageCat::Cleanup
;
; PURPOSE:
;       The IDLffLanguageCat::Cleanup procedure method preforms all cleanup
;       on the object.
;
;       NOTE: Cleanup methods are special lifecycle methods, and as such
;       cannot be called outside the context of object destruction.  This
;       means that in most cases, you cannot call the Cleanup method
;       directly.  There is one exception to this rule: If you write
;       your own subclass of this class, you can call the Cleanup method
;       from within the Cleanup method of the subclass.
;
; CALLING SEQUENCE:
;       OBJ_DESTROY, oCatalog
;
;       or
;
;       oCatalog->[IDLffLanguageCat::]Cleanup
;
; INPUTS:
;       There are no inputs for this method.
;
; KEYWORD PARAMETERS:
;       There are no keywords for this method.
;
; MODIFICATION HISTORY:
; 	Written by:	Scott J. Lasica, 11/11/98
;-

PRO IDLffLanguageCat::Cleanup
	if (self.cat_lun ne -1) then $
		FREE_LUN, self.cat_lun
	self.cat_lun = -1
	if (OBJ_VALID(self.list)) then OBJ_DESTROY,self.list
END

;+
; =============================================================
;
; METHODNAME:
;       IDLffLanguageCat::Query
;
; PURPOSE:
;       The IDLffLanguageCat::Query function method is used to return the language
;       string associated with the given key.
;
; CALLING SEQUENCE:
;       Result = oCatalog->[IDLffLanguageCat::]Query( key )
;
; INPUTS:
;       key - The scalar, or array of (string) keys associated with the desired language
;             string.  If key is an array, Result will be a string array of the
;             associated language strings.  For all instances of keys not found, the
;             null string is returned unless the DEFAULT_STRING keyword is set.
;
; KEYWORD PARAMETERS:
;       DEFAULT_STRING - Set this keyword to the desired value of the return string if
;             the key cannot be found in the language catalog file.  The default value
;             is the empty string.
;
; EXAMPLE:
;       base = WIDGET_BASE(TITLE=oCatalog->Query("my_title", DEFAULT_STRING="My App")
;
; MODIFICATION HISTORY:
; 	Written by:	Scott J. Lasica, 11/11/98
;-

function IDLffLanguageCat::Query, key, DEFAULT_STRING=defStr

	catch, error_status
	if (error_status ne 0) then begin
		return,''
	endif

	;; Now, let's see how many keys the user is requesting
	num_user_keys = N_ELEMENTS(key)
	ret_str = strarr(num_user_keys)

	;; Fill in defaults if not given
	if (N_ELEMENTS(defStr) lt N_ELEMENTS(key)) then begin
		defStrTmp = strarr(N_ELEMENTS(key))
		if (N_ELEMENTS(defStr) gt 0) then $
			defStrTmp[0] = defStr
		defStr = defStrTmp
	endif

	if (OBJ_VALID(self.list) NE 0) then begin
		for i=0,num_user_keys-1 do begin
			found = self.list->Find(key[i], offset)
			if (not found) then ret_str[i] = defStr[i] $
			else begin
				point_lun, self.cat_lun, $
				           offset + self.start_offset
				tmp=''
				readf, self.cat_lun, tmp
				ret_str[i] = tmp
			endelse
		endfor
	endif else $
		ret_str = defStr

	if (N_ELEMENTS(ret_str) eq 1) then return,ret_str[0]

	return, ret_str
END

;+
; =============================================================
;
; METHODNAME:
;       IDLffLanguageCat::SetCatalog
;
; PURPOSE:
;       The IDLffLanguageCat::SetCatalog function method is used to set the
;       appropriate catalog file.  This function returns 1 upon success and 0 on failure.
;
; CALLING SEQUENCE:
;       Result = oCatalog->[IDLffLanguageCat::]SetCatalog( application )
;
; INPUTS:
;       application - A scalar string representing the name of the desired application's
;       	catalog file.
;
; KEYWORD PARAMETERS:
;       FILENAME - Set this keyword to a scalar string containing the full path and
;           filename of the catalog file to open.  If this keyword is set, application
;           and locale are ignored.
;
;       LOCALE - Set this keyword to the desired locale for the catalog file.  If not
;           set, the current Windows locale is used (if available).
;
;		PATH - Set this keyword to a scalar string specifying the path in which to look
;           for language catalog files.
;
; EXAMPLE:
;       success = oCatalog->SetCatalog("myApp")
;
; MODIFICATION HISTORY:
; 	Written by:	Scott J. Lasica, 11/11/98
;-

function IDLffLanguageCat::SetCatalog, application, $
											FILENAME = filename, $
											LOCALE = locale, $
											PATH = path
	catch, error_status
	if (error_status ne 0) then begin
		return,0
	endif

	;; FILENAME keyword overrides everything else
	if (N_ELEMENTS(filename) gt 0) then begin
		found = FILE_SEARCH(filename)
		if (found[0] eq '') then return, 0
		self.filename = filename
		if (self.cat_lun ne -1) then $
			FREE_LUN, self.cat_lun
		OPENR, cat_lun, filename, /GET_LUN
		self.cat_lun = cat_lun
	endif else begin
		;; Argument is NOT optional
		if (N_ELEMENTS(application) eq 0) then return, 0

		;; Switch to path if need be
		if (N_ELEMENTS(path) gt 0) then $
			CD,path,CURRENT=old_dir

		cats = FILE_SEARCH('*.cat')
		if (cats[0] eq '') then begin
			CD,old_dir
			return, 0
		endif

		if (N_ELEMENTS(locale) eq 0) then $
			locale = LOCALE_GET()

		;; Now look for the right file
		for i=0,N_ELEMENTS(cats)-1 do begin
			if (self.cat_lun ne -1) then $
				FREE_LUN, self.cat_lun
			OPENR, cat_lun, cats[i], /GET_LUN
			self.cat_lun = cat_lun
			point_lun, self.cat_lun, 0
			magic_number = ''
			locale_file = ''
			readf, self.cat_lun, magic_number
			readf, self.cat_lun, locale_file
			app_name = STRMID(magic_number, 26, 1000)
			if ((app_name eq application) and (STRPOS(locale_file,locale) ne -1)) then begin
				;; Found it, bail out
				self.filename = cats[i]
				goto,break
			endif else begin
				FREE_LUN, cat_lun
				self.cat_lun = -1
			endelse
		endfor
break:
		if (N_ELEMENTS(old_dir) ne 0) then $
			CD, old_dir
	endelse

	;; Need to bail if I can't find a match
	if (self.cat_lun eq -1) then return,0

	;; Cache the keys and offsets for performance
	;; First, read in the magic number, number of keys and offsets
	point_lun, self.cat_lun, 0
	magic_number = ''
	locale_file = ''
	readf, self.cat_lun, magic_number
	readf, self.cat_lun, locale_file
	magic_number = STRMID(magic_number, 0, 25)
	if (magic_number ne "IDL_I18N_Language_Catalog") then return,0
	num_keys = ''
	start_offset = ''
	readf, self.cat_lun, num_keys
	readf, self.cat_lun, start_offset
	num_keys = LONG(num_keys)
	start_offset = LONG(start_offset)

	;; Let's get all of the keys
	tmp=''
	my_keys = strarr(num_keys)
	my_offs = lonarr(num_keys)

	for i=0,num_keys-1 do begin
		readf, self.cat_lun, tmp
		key_off = STRTOK(tmp, ' ',/EXTRACT)
		my_keys[i] = key_off[0]
		my_offs[i] = LONG(key_off[1])
	endfor

	if (OBJ_VALID(self.list)) then obj_destroy, self.list
	self.list = OBJ_NEW('IDLdsSkipList',my_keys, my_offs)

;	self.keys = PTR_NEW(my_keys)
;	self.offsets = PTR_NEW(my_offs)
	self.start_offset = start_offset

	return, 1
END

;+
;----------------------------------------------------------------------------
; IDLffLanguageCat::GetFilename
;
; Purpose:
;  Return the private object filename.
;
; MODIFICATION HISTORY:
; 	Written by:	Scott J. Lasica, 11/11/98
;-

function IDLffLanguageCat::GetFilename
	return, self.filename
end

;+
;----------------------------------------------------------------------------
; IDLffLanguageCat::IsValid
;
; Purpose:
;  Return true if a valid catalog, false otherwise.
;
; MODIFICATION HISTORY:
; 	Written by:	Scott J. Lasica, 12/1/98
;-

function IDLffLanguageCat::IsValid
	if (self.cat_lun eq -1) then return,0
	status = FSTAT(self.cat_lun)
	if (status.open eq 0) then return,0
	return,1
end

;+
;----------------------------------------------------------------------------
; IDLffLanguageCat__Define
;
; Purpose:
;  Defines the object structure for an IDLffLanguageCat object.
;
; MODIFICATION HISTORY:
; 	Written by:	Scott J. Lasica, 11/11/98
;-

PRO IDLffLanguageCat__Define

    COMPILE_OPT hidden

    struct = {  IDLffLanguageCat, $
	    		filename: '', $
	    		cat_lun: -1, $
	    		list: OBJ_NEW(), $
	    		start_offset: 0L, $
                IDLffLanguageCatVersion: 1 $
             }
END







