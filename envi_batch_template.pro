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
;:Description:
;   ENVI二次开发的批处理模版
;   默认为数据格式转换为tiff格式
;
; Author: DYQ
;-
;析构函数
PRO ENVI_BATCH_TEMPLATE_CLEANUP,tlb
  WIDGET_CONTROL,tlb,get_UValue = pState
  PTR_FREE,pState
END
;事件响应函数
PRO ENVI_BATCH_TEMPLATE_EVENT,event
  COMPILE_OPT idl2
  WIDGET_CONTROL,event.TOP, get_UValue = pState
  
  ;关闭事件
  IF TAG_NAMES(event, /Structure_Name) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
    ;
    status = DIALOG_MESSAGE('关闭?',/Question)
    IF status EQ 'No' THEN RETURN
    ;销毁指针
    ; PTR_FREE, pState
    WIDGET_CONTROL, event.TOP,/Destroy
    RETURN;
  ENDIF
  ;根据系统的uname进行判断点击的组件
  uName = WIDGET_INFO(event.ID,/uName)
  ;
  CASE uname OF
    ;打开文件
    'open': BEGIN
      files = DIALOG_PICKFILE(/MULTIPLE_FILES, $
        title = !SYS_Title+' 打开文件', $
        path = (*pState).ORIROOT)
      IF N_ELEMENTS(files) EQ 0 THEN RETURN
      ;设置显示文件
      WIDGET_CONTROL, (*pState).WLIST, set_value = files
      (*pState).INPUTFILES = PTR_NEW(files)
      (*pState).ORIROOT = FILE_DIRNAME(files[0])
      ;重置进度条进度
      IDLITWDPROGRESSBAR_SETVALUE,(*pState).PRSBAR,0
      
    END
    ;退出
    'exit': BEGIN
      status = DIALOG_MESSAGE('关闭?',$
        title = !SYS_Title, $
        /Question)
      IF status EQ 'No' THEN RETURN
      WIDGET_CONTROL, event.TOP,/Destroy
    END
    ;关于
    'about': BEGIN
      void = DIALOG_MESSAGE(!SYS_Title+' V1.0'+STRING(13b)+'欢迎使用，问题讨论请去bbs.esrichina-bj.cn！' ,/information)
    END
    ;
    ;路径选择按钮
    'filepathsele': BEGIN
      WIDGET_CONTROL, event.ID,get_value = value
      WIDGET_CONTROL,(*pState).WSELE, Sensitive= value
      WIDGET_CONTROL,(*pState).OUTPATH, Sensitive= value
    END
    ;选择输出路径
    'selePath' : BEGIN
      outroot = DIALOG_PICKFILE(/dire,title = !SYS_Title)
      WIDGET_CONTROL,(*pState).OUTPATH,set_value = outRoot
    END
    
    ;功能执行
    'execute': BEGIN
      ;获取选择的方法
      WIDGET_CONTROL,(*pState).BGROUP, get_Value = mValue
      IF PTR_VALID((*pState).INPUTFILES) EQ 0 THEN RETURN
      ;初始化ENVI
      ENVI, /restore_base_save_files
      ENVI_BATCH_INIT,/NO_Status_Window
      
      ;获取文件名
      files = *((*pState).INPUTFILES)
      per = 100./N_ELEMENTS(files)
      ;判断是否需要选择路径
      IF mValue NE 0 THEN BEGIN
        ;构建输出文件名
        WIDGET_CONTROL, (*pState).OUTPATH,get_value= outfiledir
        IF (outfiledir[0] EQ ' ') THEN  outfiledir = DIALOG_PICKFILE(/dire, title =!SYS_Title+' 输出路径')
      ENDIF  ELSE outfiledir = FILE_DIRNAME(files[0])
      
      FOR i=0,N_ELEMENTS(files)-1 DO BEGIN
        ;构建输出文件名
        fileName = FILE_BASENAME(files[i])
        pointPos = STRPOS(fileName,'.')
        ;查找文件名中点的位置
        IF pointPos[0] NE -1 THEN BEGIN
          fileName= STRMID(fileName,0,pointPos)
        ENDIF
        out_name = outfiledir+PATH_SEP()+fileName+'.tiff'
        
        ENVI_OPEN_FILE, files[i], r_fid=fid
        IF (fid EQ -1) THEN BEGIN
          tmp = DIALOG_MESSAGE(files[i]+'文件读取错误',$
            title = !sys_title, /error)
          CONTINUE
        ENDIF
        ;文件信息
        ENVI_FILE_QUERY, fid, dims=dims, nb=nb,bnames = bnames
        ;设置tiff文件输出参数
        ;如果波段小于3个
        IF nb LE 3 THEN bandList = INDGEN(nb)ELSE $
          bandList = [3,2,1]
        ;调用ENVI功能函数另存数据
        ENVI_OUTPUT_TO_EXTERNAL_FORMAT,fid = fid,dims = dims, out_name=out_name,pos = bandList, $
          out_bname=bnames[bandlist],/TIFF
        ;输出完成
        ENVI_FILE_MNG, id=fid, /remove
        ;设置进度条
        IDLITWDPROGRESSBAR_SETVALUE,(*pState).PRSBAR,(i+1)*per
      ENDFOR
      void = DIALOG_MESSAGE('处理完成 ',title = !sys_title,/infor)
      ;关闭ENVI二次开发模式
      ENVI_BATCH_EXIT
    END
    ELSE:
  ENDCASE
END
;
;--------------------------
;ENVI二次开发批处理模版
PRO ENVI_BATCH_TEMPLATE
  ;
  COMPILE_OPT idl2
  ;初始化组件大小
  sz = [600,400]
  ;设置系统变量，可方便修改系统标题
  DEFSYSV,'!SYS_Title','ENVI批处理模版'
  ;创建界面的代码
  tlb = WIDGET_BASE(MBAR= mBar, $
    /COLUMN , $
    title = !SYS_Title, $
    /Tlb_Kill_Request_Events, $
    tlb_frame_attr = 1, $
    Map = 0)
  ;创建菜单
  fMenu = WIDGET_BUTTON(mBar, value ='文件',/Menu)
  wButton = WIDGET_BUTTON(fMenu,value ='打开数据文件', $
    uName = 'open')
  fExit = WIDGET_BUTTON(fMenu, value = '退出', $
    uName = 'exit',/Sep)
  eMenu = WIDGET_BUTTON(mBar,value ='功能',/Menu)
  wButton = WIDGET_BUTTON(eMenu,$
    value ='运行批处理', $
    uName = 'execute')
  hMenu =  WIDGET_BUTTON(mBar, value ='帮助',/Menu)
  hHelp = WIDGET_BUTTON(hmenu, value = '关于', $
    uName = 'about',/Sep)
  ;上面的输入base
  wInputBase = WIDGET_BASE(tlb, $
    xSize =sz[0], $
    /Frame, $
    /Align_Center,$
    /Column)
    
    
  wLabel= WIDGET_LABEL(wInputBase, $
    value ='文件列表')
  wList = WIDGET_LIST(wInputBase, $
    YSize = sz[1]/(2*15),$
    XSize = sz[0]/8)
    
  ;输出路径设置
  wLabel= WIDGET_LABEL(tlb, $
    value ='输出参数设置')
    
  ;输出参数控制界面
  wSetBase = WIDGET_BASE(tlb, $
    xSize =sz[0], $
    /Row)
  values = ['源文件路径', $
    '另选择路径']
  bgroup = CW_BGROUP(wSetBase, values, $
    /ROW, /EXCLUSIVE, $
    /No_Release, $
    SET_VALUE=1, $
    uName = 'filepathsele', $
    /FRAME)
  outPath = WIDGET_TEXT(wSetBase, $
    value =' ', $
    xSize =30, $
    /Editable, $
    uName = 'outroot')
  wSele = WIDGET_BUTTON(wSetBase, $
    value ='选择路径', $
    uName ='selePath')
  ;
  ;执行按钮base
  wExecuteBase = WIDGET_BASE(tlb,$
    /align_center,$
    /row)
  wButton = WIDGET_BUTTON(wExecuteBase, $
    ysize =40,$
    value ='打开数据文件', $
    uName = 'open')    
  wButton = WIDGET_BUTTON(wExecuteBase,$
    value ='运行批处理', $    
    uName = 'execute')
  ;状态栏，仅显示进度条
  wStatus = WIDGET_BASE(tlb,/align_right)
  prsbar = IDLITWDPROGRESSBAR( wExecuteBase ,$
    title ='进度', $
    CANCEL =0)
  ;结构体传递参数
  state = {wButton:wButton, $
    tlb : tlb, $
    oriRoot: '', $
    outPath: outPath, $
    wSele : wSele, $
    bgroup : bgroup , $
    inputFiles : PTR_NEW(), $
    prsbar : prsbar , $
    wList : WLIST }
    
  pState = PTR_NEW(state,/no_copy)
  ;操作界面居中
  CENTERTLB,tlb
  ;
  WIDGET_CONTROL, tlb,/Realize,/map,set_uValue = pState
  XMANAGER,'ENVI_Batch_Template',tlb,/No_Block,$
    cleanup ='ENVI_Batch_Template_Cleanup'
END
