;+
;         《IDL程序设计》
; --数据快速可视化与ENVI二次开发（配盘）
;
; 示例源代码
;
; 作者: 董彦卿
;
; 联系方式：sdlcdyq@sina.com
;
;-
;+
; NAME:
;       CENTERTLB
;
; PURPOSE:
;
;       This is a utility routine to position a widget program
;       on the display at an arbitrary location. By default the
;       widget is centered on the display.
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:

;       Utilities
;
; CALLING SEQUENCE:
;
;       CenterTLB, tlb, [x, y, /NOCENTER]
;
; REQUIRED INPUTS:
;
;       tlb: The top-level base identifier of the widget program.
;
; OPTIONAL INPUTS:
;
;       x:  Set this equal to a normalized position for the center
;       of the widget as measured from the left-hand side of the screen.
;       The default value is 0.5 (the center)  Setting this equal to 1.0
;       places the widget at the far right-hand side of the screen.
;
;       y:  Set this equal to a normalized position for the center
;       of the widget as measured from the bottom of the screen.
;       The default value is 0.5 (the center) Setting this equal to 1.0
;       places the widget at the top of the screen.
;
; KEYWORDS:
;
;      NOCENTER:  By default, the center of the widget is positioned at the
;      location specified by the x and y parameters.  If NOCENTER is set
;      to a non-zero value, then the upper left corner of the widget
;      is postioned at the specifed location.
;
; PROCEDURE:
;
;       The program should be called after all the widgets have
;       been created, but just before the widget hierarchy is realized.
;       It uses the top-level base geometry along with the display size
;       to calculate offsets for the top-level base that will center the
;       top-level base on the display.
;
; COMMENT:
;       Regardless of the values set for x, y and NOCENTER, the widget
;       is not permitted to run off the display.
;
; MODIFICATION HISTORY:
;
;       Written by:  Dick Jackson, 12 Dec 98.
;       Modified to use device-independent Get_Screen_Size
;            function. 31 Jan 2000. DWF.
;       Added x, y, NOCENTER and run-off protection. 26 Jan 2001. BT.
;       Added a maximum value of 1280 for X screen size. This helps
;            center the widget on a single monitor when using dual
;            monitor settings with some graphics cards. 3 Feb 2003. DWF.
;       Added "IDLsysMonitorInfo" to get screen size;
;           2008-12 DYQ
;
;-
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright 1998-2000 Fanning Software Consulting
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################

PRO CenterTLB, tlb, x, y, NoCenter=nocenter

  Compile_Opt StrictArr

  geom = Widget_Info(tlb, /Geometry)

  IF N_Elements(x) EQ 0 THEN xc = 0.5 ELSE xc = Float(x[0])
  IF N_Elements(y) EQ 0 THEN yc = 0.5 ELSE yc = 1.0 - Float(y[0])
  center = 1 - Keyword_Set(nocenter)
  ;
  oMonInfo = OBJ_NEW('IDLsysMonitorInfo')
  rects = oMonInfo -> GetRectangles(Exclude_Taskbar=exclude_Taskbar)
  pmi = oMonInfo -> GetPrimaryMonitorIndex()
  OBJ_DESTROY, oMonInfo

  screenSize =rects[[2, 3], pmi]

  ; Get_Screen_Size()
  IF screenSize[0] GT 2000 THEN screenSize[0] = screenSize[0]/2 ; Dual monitors.
  xCenter = screenSize[0] * xc
  yCenter = screenSize[1] * yc

  xHalfSize = geom.Scr_XSize / 2 * center
  yHalfSize = geom.Scr_YSize / 2 * center

  XOffset = 0 > (xCenter - xHalfSize) < (screenSize[0] - geom.Scr_Xsize)
  YOffset = 0 > (yCenter - yHalfSize) < (screenSize[1] - geom.Scr_Ysize)

  Widget_Control, tlb, XOffset=XOffset, YOffset=YOffset
END

Pro AnimateTlb, tlb, scr_xsize, scr_ysize, updown=updown

  Compile_Opt StrictArr

  if Keyword_Set(updown) then begin
   nStep = 20
   Widget_Control, tlb, scr_ysize=1
   for i=0, nStep-1 do begin
     Widget_Control, tlb, $
           scr_xsize=(i+1)*scr_xsize/Float(nStep), $
           scr_ysize=(i+1)*scr_ysize/Float(nStep)
   endfor
  endif

End