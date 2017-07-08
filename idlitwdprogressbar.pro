; $Id: //depot/idl/releases/IDL_80/idldir/lib/itools/ui_widgets/idlitwdprogressbar.pro#1 $
; Copyright (c) 2002-2010, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;   IDLitwdProgressBar
;
; PURPOSE:
;   This function implements the Progress Bar.
;
; CALLING SEQUENCE:
;   IDLitwdProgressBar
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;
;
; MODIFICATION HISTORY:
;   Written by:  CT, RSI, August 2002
;   Modified:
;
;-


;-------------------------------------------------------------------------
PRO IDLITWDPROGRESSBAR_SETVALUE, id, percentIn

  COMPILE_OPT idl2, hidden
  
  
  ; Retrieve cache info.
  child = WIDGET_INFO(id, /CHILD)
  WIDGET_CONTROL, child, GET_UVALUE=state
  
  
  ; Check if user hit the "Cancel" button.
  ; We cannot use SAVE_HOURGLASS because on Windows it never
  ; processes the events if the hourglass is present.
  ; Presumably if we are using a progress bar, we really don't
  ; need to see the hourglass anyway since we've got our own.
  event = WIDGET_EVENT(state.WCANCEL, BAD_ID=wBad, /NOWAIT)
  
  
  ; In case user closed the window by hitting the "X" or Cancel.
  IF ((wBad NE 0) OR (event.ID EQ state.WCANCEL)) THEN BEGIN;
    IF (WIDGET_INFO(state.WBASE, /VALID)) THEN $
      WIDGET_CONTROL, state.WBASE, /DESTROY
    RETURN
  ENDIF
  
  
  ; Watch out for those 104% space shuttle engines...
  percent = 0 > percentIn[0] < 100
  
  ; New block every 1%
  nblock = 100
  iblock = LONG((percent/100d)*nblock)
  
  ; Fill in last block if we are at 98%. Technically this isn't
  ; correct but it looks nicer if the last square actually fills in.
  IF (percent GE 99) THEN $
    iblock = nblock
    
  doUpdate = (iblock NE state.IBLOCK)
  previoustime = state.TIME
  
  ; If this is the first call, reinitialize the time and percent.
  IF (state.IBLOCK LT 0) THEN BEGIN
    state.TIME = SYSTIME(1)
    state.PERCENT = percent
  ENDIF
  
  ; Cache the new block number.
  state.IBLOCK = iblock
  WIDGET_CONTROL, child, SET_UVALUE=state
  
  
  ; Only update the progress bar if we need to.
  IF (doUpdate) THEN BEGIN
  
    ; Size of one block within the progress bar.
    ; Leave room for the 1 pixel border.
    blocksize = (state.XSIZE - 4d)/nblock
    
    ; New ProgressBar size.
    x = iblock*blocksize
    y = state.YSIZE
    
    ; Fire everything to the pixmap first.
    WSET, state.PIXMAP
    
    TVLCT, red, green, blue, /GET
    rsave = red
    gsave = green
    bsave = blue
    ; Fill in our progress bar color.
    red[252:254] = [0b, state.BACKGROUND[0], 255b]
    green[252:254] = [255b, state.BACKGROUND[1], 255b]
    blue[252:254] = [0b, state.BACKGROUND[2], 255b]
    ; Our new color table.
    TVLCT, red, green, blue
    
    DEVICE, GET_DECOMPOSED=decomposed
    DEVICE, DECOMPOSED=0
    ERASE, 254
    
    ; Leave a one-pixel gap around the edges. This assumes that POLYFILL
    ; will not draw the bottom row.
    POLYFILL, [2, x+2, x+2, 2], [0, 0, y-2, y-2], $
      COLOR=252, /DEVICE
      
    ; Cut off the corners.
    PLOTS, [2,2,x+1,x+1], [1,y-2,1,y-2], COLOR=254, PSYM=3, /DEVICE
    PLOTS, [0,0,state.XSIZE-1,state.XSIZE-1], [0,y-1,0,y-1], $
      COLOR=253, PSYM=3, /DEVICE
      
    ; Copy pixmap to the draw widget.
    WSET, state.WIN
    DEVICE, COPY=[0, 0, state.XSIZE, state.YSIZE, 0, 0, state.PIXMAP]
    
    DEVICE, DECOMPOSED=decomposed
    TVLCT, rsave, gsave, bsave
    
  ENDIF
  
  
  ; Do not update the label if the block hasn't changed,
  ; unless we are on the last block, in which case we should show the
  ; final time/percent counting off.
  IF (~doUpdate && iblock LT (nblock-1)) THEN $
    RETURN
    
    
  ; If TIME keyword hasn't been set, just display the percentage.
  IF (~state.USETIME) THEN BEGIN
    WIDGET_CONTROL, state.WLABEL, $
      SET_VALUE=' '+STRTRIM(LONG(percent), 2)+'%'
    RETURN
  ENDIF
  
  
  ; Display the TIME.
  
  ; Determine approximate time remaining until complete.
  elapsedtime = SYSTIME(1) - previoustime
  fractiondone = (percent - state.PERCENT)/(100d - state.PERCENT) > 0.01
  totalexpectedtime = elapsedtime/fractiondone
  timeleft = LONG(totalexpectedtime - elapsedtime) + 1
  
  ; Assume all hours, minutes, seconds are off.
  hh = -1
  mm = -1
  ss = -1
  
  ; Different formatting depending upon magnitude.
  CASE (1) OF
    (timeleft GE 3600) : BEGIN  ; 1 hour
      hh = timeleft/3600
      timeleft = timeleft - hh*3600
      mm = timeleft/60
    END
    (timeleft GE 60) : BEGIN   ; 1 minute
      mm = timeleft/60
      ss = timeleft - mm*60
    END
    ELSE: ss = timeleft
  ENDCASE
  
  ; Build up label from time pieces.
  time = ''
  ff = '(I2)'
  
  ; Hours
  IF (hh GE 0) THEN time = time + $
    STRING(hh,FORMAT=ff) + ' ' + ((hh NE 1) ? $
    IDLITLANGCATQUERY('UI:wdProgBar:Hours')+' ' : $
    IDLITLANGCATQUERY('UI:wdProgBar:Hour')+'  ')
    
  ; Minutes
  IF (mm GE 0) THEN time = time + $
    STRING(mm,FORMAT=ff) + ' ' + ((mm NE 1) ? $
    IDLITLANGCATQUERY('UI:wdProgBar:Minutes')+' ' : $
    IDLITLANGCATQUERY('UI:wdProgBar:Minute')+'  ')
    
  ; Seconds
  IF (ss GE 0) THEN time = time + $
    STRING(ss,FORMAT=ff) + ' ' + ((ss NE 1) ? $
    IDLITLANGCATQUERY('UI:wdProgBar:Seconds') : $
    IDLITLANGCATQUERY('UI:wdProgBar:Second'))
    
  WIDGET_CONTROL, state.WLABEL, SET_VALUE=STRTRIM(time, 2)
  
END


;-------------------------------------------------------------------------
;Modified By DYQ
;进度条嵌入到界面中
FUNCTION IDLITWDPROGRESSBAR, $
    base, $
    CANCEL=cancelIn, $
    ;GROUP_LEADER=groupLeader, $
    TIME=time, $
    TITLE=titleIn, VALUE=value, $
    _REF_EXTRA=_extra
    
    
  COMPILE_OPT idl2, hidden
  
  myname = 'IDLitwdProgressBar'
  
  ; Check keywords.
  title = (N_ELEMENTS(titleIn) GT 0) ? titleIn[0] : ''
  IF (title EQ '') THEN $
    title = IDLITLANGCATQUERY('UI:wdProgBar:Title')
    
  ;if (not WIDGET_INFO(groupLeader, /VALID)) then $
  ;    MESSAGE, IDLitLangCatQuery('UI:NeedGroupLeader')
    
    
  ; Create our floating base. Modified by DYQ
  wBase = WIDGET_BASE( base, $
    /ROW, $
    ;        /FLOATING, $
    ;        GROUP_LEADER=groupLeader, $
    ;        /MODAL, $   ; Cannot use because of blocking
    PRO_SET_VALUE=myname+'_setvalue', $
    SPACE=5, XPAD=5, YPAD=5, $
    /BASE_ALIGN_BOTTOM ,$
    TITLE=title, $
    ;        TLB_FRAME_ATTR=1, $
    _EXTRA=_extra)
    
  ; Construct the actual property sheet.
  ;Add By DYQ
  wBase1 = WIDGET_BASE(wbase,map=0)
  
  ;Modified by DYQ, column→ ROW
  wCol = WIDGET_BASE(wBase, /ROW, SPACE=2)
  xsize = 204
  ysize = 12
  wDraw = WIDGET_DRAW(wCol, $
    XSIZE=xsize, YSIZE=ysize)
  wLabel = WIDGET_LABEL(wCol, $
    /DYNAMIC_RESIZE, $
    VALUE=' ')
  ;Add By DYQ
    
  wButbase = WIDGET_BASE(wBase1, /ROW)
  cancel = (SIZE(cancelIn, /TYPE) EQ 7 && cancelIn NE '') ? $
    STRTRIM(cancelIn, 2) : IDLITLANGCATQUERY('UI:Cancel')
  wCancel = WIDGET_BUTTON(wButbase, $
    VALUE='  ' + cancel + '  ')
    
    
  ; Create an offscreen pixmap.
  WINDOW, /FREE, /PIXMAP, XSIZE=xsize, YSIZE=ysize
  pixmap = !D.WINDOW   ; retrieve window index.
  
  ; Retrieve the window index and erase.
  WIDGET_CONTROL, wBase, /REALIZE
  WIDGET_CONTROL, wDraw, GET_VALUE=win
  
  WSET, win
  
  TVLCT, red, green, blue, /GET
  rsave = red
  gsave = green
  bsave = blue
  ; Fill in our progress bar color.
  red[254] = 255b
  green[254] = 255b
  blue[254] = 255b
  ; Our new color table.
  TVLCT, red, green, blue
  
  DEVICE, GET_DECOMPOSED=decomposed
  DEVICE, DECOMPOSED=0
  
  ERASE, 254
  
  DEVICE, DECOMPOSED=decomposed
  TVLCT, rsave, gsave, bsave
  
  background = (WIDGET_INFO(wBase, /SYSTEM_COLORS)).FACE_3D
  
  ; Cache my state information within my child.
  state = { $
    wBase: wBase, $
    wDraw: WLABEL, $
    wLabel: WLABEL, $
    wCancel: wCancel, $
    xsize: xsize, $
    ysize: ysize, $
    pixmap: pixmap, $
    win: win, $
    iblock: -1L, $   ; initialize value
    background: background, $
    usetime: KEYWORD_SET(time), $
    time: SYSTIME(1), $
    percent: 0d}
    
  wChild = WIDGET_INFO(wBase, /CHILD)
  WIDGET_CONTROL, wChild, SET_UVALUE=state
  
  IF (N_ELEMENTS(value) GT 0) THEN $
    IDLITWDPROGRESSBAR_SETVALUE, wBase, value
    
  RETURN, wBase
  
END

