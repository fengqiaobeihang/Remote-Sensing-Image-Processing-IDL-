;+
; :Description:
;    利用shapefile对栅格图像进行裁剪.
;
; :Syntax
;    RasterSubsetViaShapefile, Fid, shpFile=string, [pos=array],
;       [inside={0|1}], [outFile=｛string|variable}], [r_fid=variable]
;
; :Params:
;    Fid     -- 输入文件FID
;               注：可通过ENVI_OPEN_FILE、ENVI_SELECT、ENVIRasterToFID等获取
;
; :Keywords:
;    pos       -- 保留波段索引数组（可选），默认保留所有波段。
;    shpFile -- 用于裁剪的shapefile完整路径
;    inside  -- 保留shp文件外或内（可选，0或1），默认保留内部。
;                         注：设置0时，保留外部；设置1时，保留内部。
;    outFile -- 裁减结果文件路径（可选）
;                        注：如果不设置或设置为变量，则裁剪结果保存在临时目录中，outFile将保存输出文件名
;                         注：如果设置为文件路径，则裁剪结果保存在指定路径中
;    r_fid   -- 返回裁剪结果文件FID，如果范围-1，则表示裁剪失败。
;
;
; :Date: 2015年9月2日 15:33:38
;-
PRO RasterSubsetViaShapefile, Fid, shpFile=shpFile, pos=pos, $
  inside=inside, outFile=outFile, r_fid=r_fid
 
  COMPILE_OPT idl2
  ENVI, /RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT
 
  CATCH, err
  IF (err NE 0) THEN BEGIN
    CATCH, /CANCEL
    PRINT, 'ERROR: ' + !ERROR_STATE.MSG
    MESSAGE, /RESET
    RETURN
  ENDIF
 
  ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb, $
    dims=dims, fname=fname, bnames=bnames
 
  IF ~N_ELEMENTS(pos)      THEN pos     = LINDGEN(nb)
  IF ~N_ELEMENTS(inside)   THEN inside  = 1
  IF ~KEYWORD_SET(outFile) THEN outFile = envi_get_tmp()
 
  ;读取shp文件的信息
  oshp=OBJ_NEW('IDLffShape',shpFile)
  IF ~OBJ_VALID(oshp) THEN RETURN
  oshp->GETPROPERTY,n_entities=n_ent,$ ;记录个数
    Attribute_info=attr_info,$ ;属性信息，结构体， name为属性名
    ATTRIBUTE_NAMES = attr_names, $
    n_attributes=n_attr,$ ;属性个数
    Entity_type=ent_type  ;记录类型
 
  iProj = ENVI_PROJ_CREATE(/geographic)
  ;自动读取prj文件获取投影坐标系
  potPos = STRPOS(shpFile,'.',/reverse_search)  ;
  prjfile = STRMID(shpFile,0,potPos[0])+'.prj'
 
  IF FILE_TEST(prjfile) THEN BEGIN
    OPENR, lun, prjFile, /GET_LUN
    strprj = ''
    READF, lun, strprj
    FREE_LUN, lun
 
    CASE STRMID(strprj, 0,6) OF
      'GEOGCS': BEGIN
        iProj = ENVI_PROJ_CREATE(PE_COORD_SYS_STR=strprj, $
          type = 1)
      END
      'PROJCS': BEGIN
        iProj = ENVI_PROJ_CREATE(PE_COORD_SYS_STR=strprj, $
          type = 42)
      END
    ENDCASE
  ENDIF
 
  oProj = ENVI_GET_PROJECTION(fid = fid)
 
  ;然后使用ROI进行掩膜统计
  roi_ids = !NULL
  FOR i = 0, n_ent-1 DO BEGIN
    ;
    ent = oshp->GETENTITY(i, /ATTRIBUTES) ;第i条记录
 
    ;如果ent不是多边形，则继续
    IF ent.SHAPE_TYPE NE 5 THEN CONTINUE
 
    N_VERTICES=ent.N_VERTICES ;顶点个数
 
    parts=*(ent.PARTS)
 
    verts=*(ent.VERTICES)
    ; 将顶点坐标转换为输入文件的地理坐标
    ENVI_CONVERT_PROJECTION_COORDINATES,  $
      verts[0,*], verts[1,*], iProj,    $
      oXmap, oYmap, oProj
    ; 转换为文件坐标
    ENVI_CONVERT_FILE_COORDINATES,fid,    $
      xFile,yFile,oXmap,oYmap
 
    IF MIN(xFile) GE ns OR $
      MIN(yFile) GE nl OR $
      MAX(xFile) LE 0 OR $
      MAX(yFile) LE 0 THEN CONTINUE
 
    ;记录XY的区间，裁剪用
    IF i EQ 0 THEN BEGIN
      xmin = ROUND(MIN(xFile,max = xMax))
      yMin = ROUND(MIN(yFile,max = yMax))
    ENDIF ELSE BEGIN
      xmin = xMin <</SPAN> ROUND(MIN(xFile))
      xMax = xMax > ROUND(MAX(xFile))
      yMin = yMin <</SPAN> ROUND(MIN(yFile))
      yMax = yMax > ROUND(MAX(yFile))
    ENDELSE
 
    ;创建ROI
    N_Parts = N_ELEMENTS(Parts)
 
    FOR j=0, N_Parts-1 DO BEGIN
      roi_id = ENVI_CREATE_ROI(color=i,     $
        ns = ns ,  nl = nl)
      IF j EQ N_Parts-1 THEN BEGIN
        tmpFileX = xFile[Parts[j]:*]
        tmpFileY = yFile[Parts[j]:*]
      ENDIF ELSE BEGIN
        tmpFileX = xFile[Parts[j]:Parts[j+1]-1]
        tmpFileY = yFile[Parts[j]:Parts[j+1]-1]
      ENDELSE
 
      ENVI_DEFINE_ROI, roi_id, /polygon,    $
        xpts=REFORM(tmpFileX), ypts=REFORM(tmpFileY)
 
      ;如果有的ROI像元数为0，则不保存
      ENVI_GET_ROI_INFORMATION, roi_id, NPTS=npts
      IF npts EQ 0 THEN CONTINUE
 
      roi_ids = [roi_ids, roi_id]
    ENDFOR
  ENDFOR
 
  ;创建掩膜，裁剪后掩
  ENVI_MASK_DOIT,         $
    AND_OR = 2,           $
    IN_MEMORY=0,          $
    ROI_IDS= roi_ids,     $ ;ROI的ID
    ns = ns, nl = nl,     $
    inside=inside,        $ ;区域内或外
    r_fid = m_fid,        $
    out_name = envi_get_tmp()
 
  CASE inside OF
    0: out_dims=dims
    1: BEGIN
      ;进行掩膜 ---即不规则裁剪
      ;out_dims必须round，否则报错
      xMin = xMin >0
      xMax = ROUND(xMax) < (ns-1)
      yMin = yMin >0
      yMax = ROUND(yMax) < (nl-1)
      out_dims = [-1,xMin,xMax,yMin,yMax]
    END
  ENDCASE
 
  ENVI_MASK_APPLY_DOIT, FID = fid,      $
    POS = POS,                          $
    DIMS = out_dims,                    $
    M_FID = m_fid, M_POS = [0],         $
    VALUE = 0, r_fid = r_fid,           $
    OUT_NAME = outFile
 
  ; 掩膜文件ID移除
  ENVI_FILE_MNG, ID = m_fid,/REMOVE,/DELETE
 
  OBJ_DESTROY,oshp
END