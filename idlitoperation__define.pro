; $Id: //depot/idl/releases/IDL_80/idldir/lib/itools/framework/idlitoperation__define.pro#1 $
;
; Copyright (c) 2002-2010, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;----------------------------------------------------------------------------
;+
; CLASS_NAME:
;   IDLitOperation
;
; PURPOSE:
;   This file implements the abstract operation component.
;
; CATEGORY:
;   IDL Tools
;
; SUPERCLASSES:
;
; SUBCLASSES:
;
; CREATION:
;   See IDLitOperation::Init
;
;-


;---------------------------------------------------------------------------
; Lifecycle Routines
;---------------------------------------------------------------------------
; IDLitOperation::Init
;
; Purpose:
; The constructor of the IDLitOperation object.
;
; Parameters:
; None.
;
; Keywords:
;   TOOL
;   The tool or enviroment of the operation (internal use).
;
;   REVERSIBLE_OPERATION
;   If set, data is not cached for this operation for undo
;   operations. Instead the UndoExecute() method is called
;
;  EXPENSIVE_COMPUTATION
;  If set, the results of the operation are cached so when a redo
;  operatoin is executed, the cached information is used.
;
;
function IDLitOperation::Init,$
    REVERSIBLE_OPERATION=REVERSIBLE_OPERATION, $
    EXPENSIVE_COMPUTATION=EXPENSIVE_COMPUTATION, $
    _REF_EXTRA=_extra

    compile_opt idl2, hidden

    if (~self->IDLitiMessaging::Init(_EXTRA=_extra)) then $
        return, 0

    if (~self->IDLitComponent::Init(_EXTRA=_extra)) then $
        return, 0

    if(n_elements(REVERSIBLE_OPERATION) gt 0)then $
      self._reversible = keyword_set(REVERSIBLE_OPERATION)

    if(n_elements(EXPENSIVE_COMPUTATION) gt 0)then $
      self._bExpensive = keyword_set(EXPENSIVE_COMPUTATION)

    ; By default, hide our NAME property and desensitize DESCRIPTION.
    ; This prevents the user from changing menu item names via
    ; the Operations Browser or Macro Editor.
    ; The programmer can always re-enable them.
    self->SetPropertyAttribute, 'NAME', /HIDE
    self->SetPropertyAttribute, 'DESCRIPTION', SENSITIVE=0

    ; Need to use this as a property so that the obj/desc works
    self->RegisterProperty, 'TYPES', USERDEF='', /HIDE
    self->RegisterProperty, 'NUMBER_DS', USERDEF='', /HIDE

    ; Register the show dialog property, but hide it. Many operations won't
    ; have a dialog. Those that do can set HIDE=0 on this property.
    self->RegisterProperty, 'SHOW_EXECUTION_UI', /BOOLEAN, $
        /HIDE, $
        NAME='Show dialog', $
        DESCRIPTION='Show the operation dialog before execution'

    ; Default is to always show any UI.
    self._bShowExecutionUI = 1b

    self._types = ptr_new('')
    self._numberDS = '0+'

    if (N_ELEMENTS(_extra) gt 0) then $
        self->IDLitOperation::SetProperty, _EXTRA=_extra

    return, 1
end


;---------------------------------------------------------------------------
; IDLitOperation::Create
;
; Purpose:
; The heavyweight constructor of the IDLitOperation object.
;
; Parameters:
; None.
;
function IDLitOperation::Create

    compile_opt idl2, hidden

    return, 1
end


;-------------------------------------------------------------------------
; IDLitOperation::Cleanup
;
; Purpose:
; The destructor of the IDLitOperation object.
;
; Parameters:
; None.
;
pro IDLitOperation::Cleanup

    compile_opt idl2, hidden

    ptr_free, self._types
    self->IDLitComponent::Cleanup
end


;-------------------------------------------------------------------------
; IDLitOperation::Shutdown
;
; Purpose:
; The shutdown of the IDLitOperation object.
;
; Parameters:
; None.
;
;-------------------------------------------------------------------------
pro IDLitOperation::Shutdown

    compile_opt idl2, hidden
end


;-------------------------------------------------------------------------
; IDLitOperation::GetProperty
;
; Purpose:
;
; Parameters:
; None.
;
pro IDLitOperation::GetProperty,        $
                  REVERSIBLE_OPERATION=REVERSIBLE_OPERATION, $
                  EXPENSIVE_COMPUTATION=EXPENSIVE_COMPUTATION, $
                  MACRO_SHOWUIIFNULLCMD=MacroShowUIifNullCmd, $
                  MACRO_SUPPRESSREFRESH=MacroSuppressRefresh, $
                  TYPES = types,    $
                  NUMBER_DS = numDS, $
                  SHOW_EXECUTION_UI=showUI, $
                  SKIP_HISTORY=skipHistory, $
                  SKIP_MACRO=skipMacro, $
                  _REF_EXTRA=_extra

    compile_opt idl2, hidden


    if(arg_present(MacroShowUIifNullCmd))then $
       MacroShowUIifNullCmd = self._bMacroShowUIifNullCmd

    if(arg_present(MacroSuppressRefresh))then $
       MacroSuppressRefresh = self._bMacroSuppressRefresh

    if(arg_present(showUI))then $
       showUI = self._bShowExecutionUI

    if(arg_present(skipHistory))then $
       skipHistory = self._bSkipHistory

    if(arg_present(skipMacro))then $
       skipMacro = self._bSkipMacro

    if(arg_present(REVERSIBLE_OPERATION))then $
      REVERSIBLE_OPERATION = self._reversible

    if(arg_present(EXPENSIVE_COMPUTATION))then $
      EXPENSIVE_COMPUTATION = self._bExpensive

    if (arg_present(types)) then $
        types = *self._types

    if (arg_present(numDS)) then $
        numDS = self._numberDS

    if (n_elements(_extra) gt 0) then $
        self->IDLitComponent::GetProperty, _EXTRA=_extra
end


;-------------------------------------------------------------------------
; IDLitOperation::SetProperty
;
; Purpose:
;
; Parameters:
; None.
;
; Keywords:
;   SHOW_EXECUTION_UI
;   Used to determine if the UI method of the operation is called
;   before it is executed.
;
pro IDLitOperation::SetProperty, $
    MACRO_SHOWUIIFNULLCMD=MacroShowUIifNullCmd, $
    MACRO_SUPPRESSREFRESH=MacroSuppressRefresh, $
    SHOW_EXECUTION_UI=showUI, $
    SKIP_HISTORY=skipHistory, $
    SKIP_MACRO=skipMacro, $
    TYPES=types, $
    NUMBER_DS=numDS, $
    _REF_EXTRA=_extra

    compile_opt idl2, hidden

    ; some operations need to always show the UI
    if(n_elements(MacroSuppressRefresh) gt 0)then $
       self._bMacroSuppressRefresh = KEYWORD_SET(MacroSuppressRefresh)

    if(n_elements(MacroShowUIifNullCmd) gt 0)then $
       self._bMacroShowUIifNullCmd = KEYWORD_SET(MacroShowUIifNullCmd)

    if(n_elements(skipHistory) gt 0)then $
       self._bSkipHistory = KEYWORD_SET(skipHistory)

    if(n_elements(skipMacro) gt 0)then $
       self._bSkipMacro = KEYWORD_SET(skipMacro)

    if(n_elements(showUI) gt 0)then $
       self._bShowExecutionUI = KEYWORD_SET(showUI)

    if (n_elements(types) gt 0) then $
        *self._types = types

    if (n_elements(numDS) gt 0) then $
        self._numberDS = numDS

    if (n_elements(_extra) gt 0) then $
        self->IDLitComponent::SetProperty, _EXTRA=_extra
end


;---------------------------------------------------------------------------
; IDLitOperation::UndoOperation
;
; Purpose:
;  Undo the commands contained in the command set.
;
function IDLitOperation::UndoOperation, oCommandSet

   compile_opt idl2, hidden

  return, 1
end


;---------------------------------------------------------------------------
; IDLitOperation::ReDoOperation
;
; Purpose:
;   Used to execute this operation on the given command set.
;   Used with redo for the most part.
;
function IDLitOperation::RedoOperation, oCommandSet

   compile_opt idl2, hidden

  return, 1

end


;---------------------------------------------------------------------------
; IDLitOperation::DoAction
;
; Purpose: Perform (subclass) operation on all data objects that the
; subclass operation can handle in the selected visualization.
;
; Parameters:
; The Tool..
;
function IDLitOperation::DoAction, oTool

   compile_opt idl2, hidden

   self->_SetTool, oTool
   idOp = self->GetFullIdentifier()
   self->IDLitComponent::GetProperty, NAME=name
   oCmdSet = OBJ_NEW("IDLitCommandSet", NAME=name, $
                     OPERATION_IDENTIFIER=idOp)

   return, oCmdSet
end


;---------------------------------------------------------------------------
function IDLitOperation::RecordInitialValues, oCommandSet, oTargets, $
                       idParameters

   compile_opt idl2, hidden

   return, 1
end


;---------------------------------------------------------------------------
function IDLitOperation::RecordFinalValues, oCommandSet, oTargets, $
                       idParameters

   compile_opt idl2, hidden

   return, 1
end


;---------------------------------------------------------------------------
; Purpose:
;   Records all initial property values for a target, needed for undo/redo.
;   This is usually called at the beginning of a DoAction method.
;
; Result:
;   Returns a CommandSet object reference, or a null object if there
;   were no registered properties.
;
; Arguments:
;   Targets: An optional argument containing a scalar or vector array of
;       object references. All registered properties for each target
;       will be recorded. If Target is not supplied, then our self is used.
;
;   SrcDesc: An optional argument containing an object reference
;       from which to retrieve the registered properties to record.
;       If SrcDesc is not provided then each target records
;       its own properties.
;
; Keywords:
;   SKIP_HIDDEN: If set then do not record hidden,
;       undefined, or userdef properties. This is needed for styles.
;
function IDLitOperation::RecordInitialProperties, oTargets, oSrcDesc, $
    SKIP_HIDDEN=skipHidden

    compile_opt idl2, hidden

    oTool = self->GetTool()
    if (~OBJ_VALID(oTool)) then $
        return, OBJ_NEW()

    oProperty = oTool->GetService("SET_PROPERTY")
    if (~OBJ_VALID(oProperty)) then $
        return, OBJ_NEW()

    ; Create our new command set.
    oCommandSet = OBJ_NEW("IDLitCommandSet", $
            OPERATION_IDENTIFIER=oProperty->GetFullIdentifier())

    ; Record my own properties.
    if (N_ELEMENTS(oTargets) eq 0) then $
        oTargets = self

    hasSrc = OBJ_VALID(oSrcDesc)

    ; Loop thru all targets.
    for i=0,N_ELEMENTS(oTargets)-1 do begin

        oSrc = hasSrc ? oSrcDesc : oTargets[i]

        ; Retrieve all of our registered properties to record.
        ; Only need to retrieve them once if we have SrcDesc.
        ; Otherwise retrieve them for each target.
        if (i eq 0 || ~hasSrc) then $
            propIDs = oSrc->QueryProperty()

        ; If we don't have any properties, we are done.
        if (propIDS[0] eq '') then $
            return, OBJ_NEW()

        ; Record all of our initial values into the Command set.
        for j=0,N_ELEMENTS(propIDs)-1 do begin
            if (KEYWORD_SET(skipHidden)) then begin
                oSrc->GetPropertyAttribute, propIDs[j], $
                    HIDE=hide, TYPE=type, UNDEFINED=undefined
                if (hide || undefined || (type eq 0)) then $
                    continue
            endif
            ; We will quietly ignore any errors in trying to
            ; get a particular property value. This may happen for
            ; userdefined properties in particular (although note that
            ; if GetProperty doesn't work then they will not be undoable).
            void = oProperty->RecordInitialValues(oCommandSet, $
                oTargets[i], propIDs[j])
        endfor

    endfor

    return, oCommandSet

end


;---------------------------------------------------------------------------
; Purpose:
;   Records the final property values for a target, needed for undo/redo.
;   This is usually called at the end of a DoAction method.
;
; Arguments:
;   CommandSet: An object reference to the command set
;       as created by IDLitOperation::RecordInitialProperties.
;       If CommandSet is a null object then this method quietly returns.
;
; Keywords:
;   None.
;
pro IDLitOperation::RecordFinalProperties, oCommandSet, _EXTRA=_extra

    compile_opt idl2, hidden

    if (~OBJ_VALID(oCommandSet)) then $
        return

    oTool = self->GetTool()
    if (~OBJ_VALID(oTool)) then $
        return

    oProperty = oTool->GetService("SET_PROPERTY")
    if (~OBJ_VALID(oProperty)) then $
        return

    void = oProperty->RecordFinalValues(oCommandSet, _EXTRA=_extra)

end


;-------------------------------------------------------------------------
; IDLitOperation::QueryAvailability
;
; Purpose:
;   This function method determines whether this object is applicable
;   for the given data and/or visualization types for the given tool.
;
; Return Value:
;   This function returns a 1 if the object is applicable for
;   the selected items, or a 0 otherwise.
;
; Parameters:
;   oTool - A reference to the tool object for which this query is
;     being issued.
;
;   selTypes - A vector of strings representing the visualization
;     and/or data types of the selected items.
;
; Keywords:
;   None
;
function IDLitOperation::QueryAvailability, oTool, selTypes

    compile_opt idl2, hidden

    ; check for multiple dataspaces
    oSel = oTool->GetSelectedItems(COUNT=ct)
    for i=0,ct-1 do begin
      oManip = oSel[i]->GetManipulatorTarget()
      ;; Save normalizer dataspaces
      if (OBJ_ISA(oManip, 'IDLitVisNormalizer')) then $
        oDS = (N_ELEMENTS(oDS) eq 0) ? [oManip] : [oDS, oManip] 
    endfor
    ; Filter out reduntant dataspaces
    nDS = N_ELEMENTS(UNIQ(oDS, SORT(oDS)))
    case self._numberDS of
      '0+' :
      '1-' : if (nDS gt 1) then return, 0
      '1' : if (nDS ne 1) then return, 0
      '1+' : if (nDS eq 0) then return, 0
      '2+' : if (nDS lt 2) then return, 0
      else :
    endcase

    ; If I have no types, or none were passed in.
    nSelected = N_ELEMENTS(selTypes)
    if (~N_ELEMENTS(*self._types) || $
        ((N_ELEMENTS(*self._types) eq 1) && (*self._types eq '')) || $
        ~nSelected) then $
        return, 1

    ; If '' is passed in and matches
    if ((nSelected eq 1) && (selTypes eq '') && $
        MAX(selTypes eq *self._types)) then $
      return, 1 

    ; Search for a match between the selected item types and the
    ; described object's types.
    for i=0, nSelected-1 do begin
        hasMatch = MAX(selTypes[i] eq *self._types)
        ; Match found. We're done.
        if (hasMatch) then $
            break
    endfor
    return, (hasMatch gt 0)

end


;-------------------------------------------------------------------------
; Purpose:
;   Returns the current availability (sensitivity) of the operation.
;   Used by subclasses that don't need to check types.
;
; Return Value:
;   This function returns a 1 if the object is sensitive
;   or a 0 otherwise.
;
; Parameters:
;   oTool - A reference to the tool object for which this query is
;     being issued.
;
; Keywords:
;   None
;
function IDLitOperation::_CurrentAvailability, oTool

    compile_opt idl2, hidden

    ; Simply return the current value for DISABLED.
    id = self->GetFullIdentifier()
    oObjDesc = oTool->GetByIdentifier(id)
    if (~OBJ_VALID(oObjDesc)) then $
        return, 0

    oObjDesc->GetProperty, DISABLE=disabled

    return, ~disabled

end


;-------------------------------------------------------------------------
pro IDLitOperation__define

    compile_opt idl2, hidden

    struc = {IDLitOperation,       $
             inherits IDLitComponent,$
             inherits IDLitIMessaging, $ ; tool communication interface
             _bExpensive : 0b, $
             _reversible : 0b,  $
             _bShowExecutionUI : 0b, $ ; display UI
             _bSkipHistory : 0b, $
             _bSkipMacro : 0b, $
             _bMacroShowUIifNullCmd : 0b, $
             _bMacroSuppressRefresh : 0b, $
             _numberDS: '', $ ; number of data spaces that can be op'ed
             _types: ptr_new() $ ; types of visualizations that can be op'ed
            }
end

