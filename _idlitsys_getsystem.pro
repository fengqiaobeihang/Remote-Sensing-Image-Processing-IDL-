; $Id: //depot/idl/releases/IDL_80/idldir/lib/itools/framework/_idlitsys_getsystem.pro#1 $
;
; Copyright (c) 2002-2010, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;  _IDLitsys_GetSystem
;
; PURPOSE:
;   Provides a procedurual interface that retrieves access to the
;   underlying system object. This is used by the command line api for
;   the IDL tool system to bridge the gap between the procedureal and
;   object space.
;
;   This is an internal routine.
;
; CALLING SEQUENCE:
;     oSystem = _IDLitSys_GetSystem()
;
; PARAMETERS
;  None
;
; KEYWORDS
;  NO_CREATE  - If set and if the system doesn't exist, it won't be
;               created. In this case a null is returned
;
;
; RETURN VALUE
;  The system object or an null value if the system cannot be created.
;-

function _IDLitSys_GetSystem, NO_CREATE=NO_CREATE
   compile_opt hidden, idl2

   ;; Maintain the object in a common block!!
   common __IDLitSys$SystemCache$__, c_oSystem

   if(~obj_valid(c_oSystem))then $
       c_oSystem = (~keyword_set(NO_CREATE) ?  $
                    obj_new("IDLitSystem") :  $;; create the object
                    obj_new()) ;; set to null
   
   return, c_oSystem

end
