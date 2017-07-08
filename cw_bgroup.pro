; $Id: //depot/Release/IDL_81/idl/idldir/lib/cw_bgroup.pro#1 $
;
; Copyright (c) 1992-2011, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;   CW_BGROUP
;
; PURPOSE:
;   CW_BGROUP is a compound widget that simplifies creating
;   a base of buttons. It handles the details of creating the
;   proper base (standard, exclusive, or non-exclusive) and filling
;   in the desired buttons. Events for the individual buttons are
;   handled transparently, and a CW_BGROUP event returned. This
;   event can return any one of the following:
;       - The Index of the button within the base.
;       - The widget ID of the button.
;       - The name of the button.
;       - An arbitrary value taken from an array of User values.
;
; CATEGORY:
;   Compound widgets.
;
; CALLING SEQUENCE:
;       Widget = CW_BGROUP(Parent, Names)
;
;   To get or set the value of a CW_BGROUP, use the GET_VALUE and
;   SET_VALUE keywords to WIDGET_CONTROL. The value of a CW_BGROUP
;   is:
;
;       -----------------------------------------------
;       Type        Value
;       -----------------------------------------------
;       normal      None
;       exclusive       Index of currently set button
;       non-exclusive   Vector indicating the position
;               of each button (1-set, 0-unset)
;       -----------------------------------------------
;
;
; INPUTS:
;       Parent:     The ID of the parent widget.
;   Names:      A string array, containing one string per button,
;           giving the name of each button.
;
; KEYWORD PARAMETERS:
;
;   BUTTON_UVALUE:  An array of user values to be associated with
;           each button and returned in the event structure.
;   COLUMN:     Buttons will be arranged in the number of columns
;           specified by this keyword.
;   EVENT_FUNCT:    The name of an optional user-supplied event function
;           for buttons. This function is called with the return
;           value structure whenever a button is pressed, and
;           follows the conventions for user-written event
;           functions.
;   EXCLUSIVE:  Buttons will be placed in an exclusive base, with
;           only one button allowed to be selected at a time.
;   FONT:       The name of the font to be used for the button
;           titles. If this keyword is not specified, the default
;           font is used.
;   FRAME:      Specifies the width of the frame to be drawn around
;           the base.
;   IDS:        A named variable into which the button IDs will be
;           stored, as a longword vector.
;   LABEL_LEFT: Creates a text label to the left of the buttons.
;   LABEL_TOP:  Creates a text label above the buttons.
;   MAP:        If set, the base will be mapped when the widget
;           is realized (the default).
;   NONEXCLUSIVE:   Buttons will be placed in an non-exclusive base.
;           The buttons will be independent.
;   NO_RELEASE: If set, button release events will not be returned.
;   RETURN_ID:  If set, the VALUE field of returned events will be
;           the widget ID of the button.
;   RETURN_INDEX:   If set, the VALUE field of returned events will be
;           the zero-based index of the button within the base.
;           THIS IS THE DEFAULT.
;   RETURN_NAME:    If set, the VALUE field of returned events will be
;           the name of the button within the base.
;   ROW:        Buttons will be arranged in the number of rows
;           specified by this keyword.
;   SCROLL:     If set, the base will include scroll bars to allow
;           viewing a large base through a smaller viewport.
;   SET_VALUE:  The initial value of the buttons. This is equivalent
;           to the later statement:
;
;           WIDGET_CONTROL, widget, set_value=value
;
;   SPACE:      The space, in pixels, to be left around the edges
;           of a row or column major base. This keyword is
;           ignored if EXCLUSIVE or NONEXCLUSIVE are specified.
;   UVALUE:     The user value to be associated with the widget.
;   UNAME:      The user name to be associated with the widget.
;   XOFFSET:    The X offset of the widget relative to its parent.
;   XPAD:       The horizontal space, in pixels, between children
;           of a row or column major base. Ignored if EXCLUSIVE
;           or NONEXCLUSIVE are specified.
;   XSIZE:      The width of the base.
;   X_SCROLL_SIZE:  The width of the viewport if SCROLL is specified.
;   YOFFSET:    The Y offset of the widget relative to its parent.
;   YPAD:       The vertical space, in pixels, between children of
;           a row or column major base. Ignored if EXCLUSIVE
;           or NONEXCLUSIVE are specified.
;   YSIZE:      The height of the base.
;   Y_SCROLL_SIZE:  The height of the viewport if SCROLL is specified.
;
; OUTPUTS:
;       The ID of the created widget is returned.
;
; SIDE EFFECTS:
;   This widget generates event structures with the following definition:
;
;       event = { ID:0L, TOP:0L, HANDLER:0L, SELECT:0, VALUE:0 }
;
;   The SELECT field is passed through from the button event. VALUE is
;   either the INDEX, ID, NAME, or BUTTON_UVALUE of the button,
;   depending on how the widget was created.
;
; RESTRICTIONS:
;   Only buttons with textual names are handled by this widget.
;   Bitmaps are not understood.
;
; MODIFICATION HISTORY:
;   15 June 1992, AB
;   7 April 1993, AB, Removed state caching.
;   6 Oct. 1994, KDB, Font keyword is not applied to the label.
;       10 FEB 1995, DJC  fixed bad bug in event procedure, getting
;                         id of stash widget.
;   11 April 1995, AB Removed Motif special cases.
;-


pro CW_BGROUP_SETV, id, value
  compile_opt hidden

  ON_ERROR, 2                       ;return to caller

  stash = WIDGET_INFO(id, /CHILD)
  WIDGET_CONTROL, stash, GET_UVALUE=state, /NO_COPY

  case state.type of
    0: message,'unable to set plain button group value'
    1: begin
      WIDGET_CONTROL, SET_BUTTON=0, state.ids[state.excl_pos]
      state.excl_pos = value
      WIDGET_CONTROL, /SET_BUTTON, state.ids[value]
    end
    2: begin
      n = n_elements(value)-1
      for i = 0, n do begin
        state.nonexcl_curpos[i] = value[i]
        WIDGET_CONTROL, state.ids[i], SET_BUTTON=value[i]
      endfor
    end
  endcase

  WIDGET_CONTROL, stash, SET_UVALUE=state, /NO_COPY
end



function CW_BGROUP_GETV, id, value

  compile_opt hidden
  ON_ERROR, 2                       ;return to caller

  stash = WIDGET_INFO(id, /CHILD)
  WIDGET_CONTROL, stash, GET_UVALUE=state, /NO_COPY

  case state.type of
    0: message,'unable to get plain button group value'
    1: ret = state.excl_pos
    2: ret = state.nonexcl_curpos
  endcase

  WIDGET_CONTROL, stash, SET_UVALUE=state, /NO_COPY

  return, ret

end



function CW_BGROUP_EVENT, ev
  compile_opt hidden
  WIDGET_CONTROL, ev.handler, GET_UVALUE=stash
  WIDGET_CONTROL, stash, GET_UVALUE=state, /NO_COPY
  WIDGET_CONTROL, ev.id, get_uvalue=uvalue

  ret = 1           ;Assume we return a struct
  case state.type of
    0:
    1: if (ev.select eq 1) then begin
      state.excl_pos = uvalue
    ENDIF else begin
      if (state.no_release ne 0) then ret = 0
    ENDELSE
    2: begin
      ; Keep track of the current state
      state.nonexcl_curpos[uvalue] = ev.select
          if (state.no_release ne 0) and (ev.select eq 0) then ret = 0
    end
  endcase

  if ret then begin     ;Return a struct?
      ret = { ID:state.base, TOP:ev.top, HANDLER:0L, SELECT:ev.select, $
           VALUE:state.ret_arr[uvalue] }
      efun = state.efun
      WIDGET_CONTROL, stash, SET_UVALUE=state, /NO_COPY
      if efun ne '' then return, CALL_FUNCTION(efun, ret) $
      else return, ret
  endif else begin      ;Trash the event
      WIDGET_CONTROL, stash, SET_UVALUE=state, /NO_COPY
      return, 0
  endelse
end







function CW_BGROUP, parent, names, $
    BUTTON_UVALUE = button_uvalue, COLUMN=column, EVENT_FUNCT = efun, $
    EXCLUSIVE=excl, FONT=font, FRAME=frame, IDS=ids, LABEL_TOP=label_top, $
    LABEL_LEFT=label_left, MAP=map, $
    NONEXCLUSIVE=nonexcl, NO_RELEASE=no_release, RETURN_ID=return_id, $
    RETURN_INDEX=return_index, RETURN_NAME=return_name, $
    ROW=row, SCROLL=scroll, SET_VALUE=sval, SPACE=space, $
    TAB_MODE=tab_mode, UVALUE=uvalue, $
    XOFFSET=xoffset, XPAD=xpad, XSIZE=xsize, X_SCROLL_SIZE=x_scroll_size,$
    YOFFSET=yoffset, YPAD=ypad, YSIZE=ysize, Y_SCROLL_SIZE=y_scroll_size, $
    UNAME=uname


  IF (N_PARAMS() ne 2) THEN MESSAGE, 'Incorrect number of arguments'

  ON_ERROR, 2                       ;return to caller

  ; Set default values for the keywords
  version = WIDGET_INFO(/version)
  if (version.toolkit eq 'OLIT') then def_space_pad = 4 else def_space_pad = 3
  IF (N_ELEMENTS(column) eq 0)      then column = 0
  IF (N_ELEMENTS(excl) eq 0)        then excl = 0
  IF (N_ELEMENTS(frame) eq 0)       then frame = 0
  IF (N_ELEMENTS(map) eq 0)     then map=1
  IF (N_ELEMENTS(nonexcl) eq 0)     then nonexcl = 0
  IF (N_ELEMENTS(no_release) eq 0)  then no_release = 0
  IF (N_ELEMENTS(row) eq 0)     then row = 0
  IF (N_ELEMENTS(scroll) eq 0)      then scroll = 0
  IF (N_ELEMENTS(space) eq 0)       then space = def_space_pad
  IF (N_ELEMENTS(uname) eq 0)      then uname = 'CW_BGROUP_UNAME'
  IF (N_ELEMENTS(uvalue) eq 0)      then uvalue = 0
  IF (N_ELEMENTS(xoffset) eq 0)     then xoffset=0
  IF (N_ELEMENTS(xpad) eq 0)        then xpad = def_space_pad
  IF (N_ELEMENTS(xsize) eq 0)       then xsize = 0
  IF (N_ELEMENTS(x_scroll_size) eq 0)   then x_scroll_size = 0
  IF (N_ELEMENTS(yoffset) eq 0)     then yoffset=0
  IF (N_ELEMENTS(ypad) eq 0)        then ypad = def_space_pad
  IF (N_ELEMENTS(ysize) eq 0)       then ysize = 0
  IF (N_ELEMENTS(y_scroll_size) eq 0)   then y_scroll_size = 0




  top_base = 0L
  if (n_elements(label_top) ne 0) then begin
    next_base = WIDGET_BASE(parent, XOFFSET=xoffset, YOFFSET=yoffset, /COLUMN)
    if(keyword_set(font))then $
       junk = WIDGET_LABEL(next_base, value=label_top,font=font) $
    else    junk = WIDGET_LABEL(next_base, value=label_top)
    top_base = next_base
  endif else next_base = parent

  if (n_elements(label_left) ne 0) then begin
    next_base = WIDGET_BASE(next_base, XOFFSET=xoffset, YOFFSET=yoffset, /ROW)
    if(keyword_set(font))then $
       junk = WIDGET_LABEL(next_base, value=label_left, font=font) $
    else junk = WIDGET_LABEL(next_base, value=label_left)
    if (top_base eq 0L) then top_base = next_base
  endif
  ; We need some kind of outer base to hold the users UVALUE
  if (top_base eq 0L) then begin
    top_base = WIDGET_BASE(parent, XOFFSET=xoffset, YOFFSET=yoffset)
    next_base = top_base
  endif
  If (top_base EQ next_base) THEN $
     next_base = WIDGET_BASE(top_base, Xpad=1, Ypad=1, Space=1)

  ; Set top level base attributes
  WIDGET_CONTROL, top_base, MAP=map, $
    FUNC_GET_VALUE='CW_BGROUP_GETV', PRO_SET_VALUE='CW_BGROUP_SETV', $
    SET_UVALUE=uvalue, SET_UNAME=uname

  ; Tabbing
  if (n_elements(tab_mode) ne 0) then begin
    WIDGET_CONTROL, top_base, TAB_MODE=tab_mode
    WIDGET_CONTROL, next_base, TAB_MODE=tab_mode
  end

  ; The actual button holding base
  base = WIDGET_BASE(next_base, COLUMN=column, EXCLUSIVE=excl, FRAME=frame, $
    NONEXCLUSIVE=nonexcl, ROW=row, SCROLL=scroll, SPACE=space, $
    XPAD=xpad, XSIZE=xsize, X_SCROLL_SIZE=x_scroll_size, $
    YPAD=ypad, YSIZE=ysize, Y_SCROLL_SIZE=y_scroll_size, $
    EVENT_FUNC='CW_BGROUP_EVENT', $
    UVALUE=WIDGET_INFO(top_base, /child))


  n = n_elements(names)
  ids = lonarr(n)
  for i = 0, n-1 do begin
    if (n_elements(font) eq 0) then begin
      ids[i] = WIDGET_BUTTON(base, value=names[i], UVALUE=i, $
      UNAME=uname+'_BUTTON'+STRTRIM(i,2))
    endif else begin
      ids[i] = WIDGET_BUTTON(base, value=names[i], FONT=font, $
      UVALUE=i, UNAME=uname+'_BUTTON'+STRTRIM(i,2))
    endelse
  endfor

  ; Keep the state info in the real (inner) base UVALUE.
  ; Pick an event value type:
  ; 0 - Return ID
  ; 1 - Return INDEX
  ; 2 - Return NAME
  ret_type = 1
  if KEYWORD_SET(RETURN_ID) then ret_type = 0
  if KEYWORD_SET(RETURN_NAME) then ret_type = 2
  if KEYWORD_SET(BUTTON_UVALUE) then ret_type = 3
    case ret_type of
      0: ret_arr = ids
      1: ret_arr = indgen(n)
      2: ret_arr = names
      3: ret_arr = button_uvalue
    endcase
  type = 0
  if (excl ne 0) then type = 1

  if (nonexcl ne 0) then type = 2
  if n_elements(efun) le 0 then efun = ''
  state = { type:type, $    ; 0-Standard, 1-Exclusive, 2-Non-exclusive
        base: top_base, $   ; cw_bgroup base...
        ret_arr:ret_arr, $  ; Vector of event values
        efun : efun, $  ; Name of event fcn
        nonexcl_curpos:intarr(n), $ ; If non-exclus, tracks state
        excl_pos:0, $           ; If exclusive, current button
        ids:ids, $          ; Ids of buttons
        no_release:no_release }
  WIDGET_CONTROL, WIDGET_INFO(top_base, /CHILD), SET_UVALUE=state, /NO_COPY

  if (n_elements(sval) ne 0) then CW_BGROUP_SETV, top_base, sval

  return, top_base
END
