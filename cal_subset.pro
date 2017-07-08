;裁剪
;+
;ENVI二次开发功能代码
;描述：
;基于shape矢量文件裁剪
;调用方法：
; cal_subset,infile, shapefile, resultfile
; infile:待裁剪的栅格文件
; shapefile：矢量文件
; resultfile：裁剪后存储结果
;-
PRO cal_subset,infile, shapefile, resultfile
  compile_opt idl2
 
  CATCH, Error_status
  errorshow = 'Sorry to see the error,'+ $
    ' please send the error Information to "dongyq@esrichina-bj.cn"'
  IF Error_status NE 0 THEN BEGIN
    tmp = DIALOG_MESSAGE(errorshow+STRING(13b)+$
      !ERROR_STATE.MSG,/error,title = '错误提示!')
    return
  ENDIF
 
  shapeobj = OBJ_NEW('IDLffShape', shapefile)
  ENVI_OPEN_FILE,infile,r_fid = fid
  ENVI_FILE_QUERY, fid, ns = ns, nb = nb, nl = nl, dims = dims,BNAMES = BNAMES
  shapeobj->GETPROPERTY, N_Entities = nEntities
  ;
  ; shape_type =5--多边形  8-- 多个多边形
  ;BOUNDS 边界值
  ;
  roi_ids = LONARR(nEntities>1)
  FOR i=0, nEntities-1 DO BEGIN
    entitie = shapeobj->GETENTITY(i)
    ;多边形则进行转换，否则不做任何操作
    IF (entitie.SHAPE_TYPE EQ 5)  THEN BEGIN
      record = *(entitie.VERTICES)
      ;转换为文件坐标
      ENVI_CONVERT_FILE_COORDINATES,fid,xmap,ymap,record[0,*],record[1,*]
      ;创建ROI
      roi_ids[i] = ENVI_CREATE_ROI(color=4,  $
        ns = ns ,  nl = nl)
      ENVI_DEFINE_ROI, roi_ids[i], /polygon, xpts=REFORM(xMap), ypts=REFORM(yMap)
      ;roi_ids[i] = roi_id
      ;记录XY的区间，裁剪用
      ;记录XY的区间，裁剪用
      IF i EQ 0 THEN BEGIN
        xmin = ROUND(MIN(xMap,max = xMax))
        yMin = ROUND(MIN(yMap,max = yMax))
      ENDIF ELSE BEGIN
        xmin = xMin < ROUND(MIN(xMap))
        xMax = xMax > ROUND(MAX(xMap))
        yMin = yMin < ROUND(MIN(yMap))
        yMax = yMax > ROUND(MAX(yMap))
      ENDELSE
    ENDIF
    shapeobj->DESTROYENTITY, entitie
  ENDFOR
  OBJ_DESTROY, shapeobj
  ;
  xMin = xMin >0
  xmax = xMax < ns-1
  yMin = yMin >0
  ymax = yMax < nl-1
 
  out_dims = [-1,xMin,xMax,yMin,yMax]
  ;获取ENVI的配置参数
  cfg = envi_get_configuration_values()
  tmppath = cfg.DEFAULT_TMP_DIRECTORY
 
  ;创建掩膜，裁剪后掩
  ENVI_MASK_DOIT,$
    AND_OR =1, $
    OUT_NAME = tmppath+path_sep()+'void.mask', $
    ROI_IDS= roi_ids, $ ;ROI的ID
    ns = ns, nl = nl, $
    /inside, $ ;区域内或外
    r_fid = m_fid
   
  ENVI_MASK_APPLY_DOIT, FID = fid, POS = INDGEN(nb), DIMS = out_dims, $
    M_FID = m_fid, M_POS = [0], VALUE = 0, $
    out_name = resultfile;,$
  ;out_bnames = BNAMES+"("+"subset by "+STRTRIM(FILE_BASENAME(shapefile),2)+")"
  ;掩膜文件ID移除
  ENVI_FILE_MNG, id =m_fid,/remove
 
END