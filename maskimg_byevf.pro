;+
;Description:
;Mask Raster data by Evf file.
;shaodonghang
;-

PRO maskimg_byevf
  COMPILE_OPT idl2
  
  ENVI,/RESTORE_BASE_SAVE_FILES
  ;initialize ENVI in batch mode:
  ENVI_BATCH_INIT
  
  fileextension='img'
  ;选择数据文件夹
  folder=ENVI_PICKFILE(TITLE='Select image Data Folder',/DIRECTORY)
  ;选择evf
  evfname=DIALOG_PICKFILE(title='Select Evf ')
  
  IF (folder EQ '') THEN RETURN
  ;查找数据
  imagefiles=FILE_SEARCH(folder,'*.'+fileextension,/FOLD_CASE,COUNT=count);这里的fold_case需要查询
  IF (count EQ 0) THEN BEGIN
    void=DIALOG_MESSAGE(['Unable to locate image tile datasets in the selected folder :',$
      '',folder])
    !QUIET=quietInit
    RETURN
  ENDIF
  ;输出文件夹
  outFolder=ENVI_PICKFILE(TITLE='Select Folder For Output',/DIRECTORY)
  IF (outFolder EQ '') THEN BEGIN
    !QUIET=quietInit
    RETURN
  ENDIF
  outFolder = outFolder + PATH_SEP()
  CD, outFolder, CURRENT=current
  
  FOR i = 0 ,(count-1) DO BEGIN
    ;open dataset:
    ENVI_OPEN_FILE, imagefiles[i], R_FID=fid
    IF (fid EQ -1) THEN BEGIN
      CONTINUE
    ENDIF
    ;输出文件
    out_name=outFolder+FILE_BASENAME(imagefiles[i],fileExtension)+'.img'
    ;掩膜功能
    SPATIALSUBSET,fid,evfName,out_name
  ENDFOR
END


;基于EVF文件的掩膜
PRO SPATIALSUBSET,data_fid,evfName,out_name
  COMPILE_OPT IDL2
  ENVI_FILE_QUERY,data_fid,BNAMES= BNAMES,ns=ns,nl=nl,nb=nb
  ;打开矢量文件
  evf_id = ENVI_EVF_OPEN(evfName)
  ;获取相关信息
  ENVI_EVF_INFO, evf_id, num_recs=num_recs, $
    data_type=data_type, projection=projection, $
    layer_name=layer_name
  roi_ids = LONARR(num_recs)
  ;输出的坐标系统
  ;oproj=envi_get_projection(fid=data_fid)
  ;读取各个记录的点数
  FOR i=0,num_recs-1 DO BEGIN
    record = ENVI_EVF_READ_RECORD(evf_id, i)
    ;转换投影坐标点
    ;envi_convert_projection_coordinates, $
    ;record[0,*],record[1,*], projection, $
    ;oxmap, oymap, oproj
    ;转换为文件坐标;这里更改了oxmap, oymap
    ;原来的是   ENVI_CONVERT_FILE_COORDINATES,data_fid,xmap,ymap,record[0,*],record[1,*]
    ENVI_CONVERT_FILE_COORDINATES,data_fid,xmap,ymap,record[0,*],record[1,*]
    ;创建ROI
    roi_id = ENVI_CREATE_ROI(color=4,ns = ns , nl = nl)
    ENVI_DEFINE_ROI, roi_id, /polygon, xpts=REFORM(xMap), ypts=REFORM(yMap)
    roi_ids[i] = roi_id
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
  ENDFOR
  xMin = xMin >0
  xmax = xMax < ns-1
  yMin = yMin >0
  ymax = yMax < nl-1
  ;创建掩膜，裁剪后掩
  ENVI_MASK_DOIT,$
    AND_OR =1, $
    /IN_MEMORY, $
    ROI_IDS= roi_ids, $ ;ROI的ID
    ns = ns, nl = nl, $
    /inside, $ ;区域内或外
    r_fid = m_fid
  out_dims = [-1,xMin,xMax,yMin,yMax]
  
  ENVI_MASK_APPLY_DOIT, FID = data_fid, POS = INDGEN(nb), DIMS = out_dims, $
    M_FID = m_fid, M_POS = [0], VALUE = 0, $
    OUT_BNAME= BNAMES+' mask',IN_MEMORY=0,out_name=out_name,r_fid=r_fid
  ;掩膜文件ID移除
  ENVI_FILE_MNG, id =m_fid,/remove
  ;ENVI_FILE_MNG, id =data_fid,/remove
END
