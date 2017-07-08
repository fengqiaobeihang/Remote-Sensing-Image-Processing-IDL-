;定标
;+
;ENVI二次开发功能代码
;描述：
;定标
;调用方法：
; cal_Calibration, 'c:\temp\can_tmr.img','c:\temp\result.img',[[2,2,2,2,2,2],[1,1,1,1,1,1]]
;注意事项：
; gainoffset参数与波段个数一一对应
;-
Pro cal_calibration, infile, outFile, gainOffset,wl = wv;(可选关键字，wv是定标后单位)
  COMPILE_OPT idl2
  CATCH, Error_status
  errorshow = 'Sorry to see the error,'+ $
    ' please send the error Information to "dongyq@esrichina-bj.cn"'
  IF Error_status NE 0 THEN BEGIN
    tmp = DIALOG_MESSAGE(errorshow+STRING(13b)+$
      !ERROR_STATE.MSG,/error,title = '错误提示!')
    return
  ENDIF
 
  ;获取ENVI的配置参数
  cfg = envi_get_configuration_values()
  tmppath = cfg.DEFAULT_TMP_DIRECTORY
  ;是否设置了输出文件名
  IF N_ELEMENTS(outFile) EQ 0 THEN out_name=tmppath+PATH_SEP()+'void.tmp'
 
  ENVI_OPEN_FILE,infile,R_fid= fid
  ;获取信息
  ENVI_FILE_QUERY, FID, $
    dims = dims, $
    BNAMES = BNAMEs, $
    NB = NB
   
  ;定标功能
  ENVI_DOIT,'gainoff_doit', fid=fid, pos=LINDGEN(nb), dims=dims, out_name=outFile, $
    gain=1./gainOffset[*,0], offset=gainOffset[*,1], r_fid=r_fid, in_memory=0,$
    OUT_DT = 4
   
  ENVI_FILE_QUERY, r_fid, $
    dims = dims, $
    DATA_TYPE = 4, $
    INTERLEAVE = INTERLEAVE, $
    NB = NB, $
    NL = NL, $
    NS=NS ,$
    OFFSET = OFFSET
   
  map_info = ENVI_GET_MAP_INFO(fid=r_fid)
 
  ;先关掉文件
  ENVI_FILE_MNG, id = fid,/Remove
  ENVI_FILE_MNG, id = r_fid,/Remove
 
  ;再写入头文件
  ENVI_SETUP_HEAD, $
    DATA_TYPE = DATA_TYPE, $
    BNAMES = '定标后：'+BNAMES, $
    DESCRIP = '定标公式 y=x/gain+offset', $
    FNAME=outFile,$
    INTERLEAVE = INTERLEAVE, $
    MAP_INFO = map_info, $
    wl = wv, $
    NB = NB, $
    NL = NL, $
    NS=NS ,$
    OFFSET = OFFSET,$
    /Write
END