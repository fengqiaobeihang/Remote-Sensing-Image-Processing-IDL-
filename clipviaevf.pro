PRO ClipViaEvf
compile_opt idl2
  ENVI, /RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT, LOG_FILE='batch.txt'
;打开栅格数据
  cd,'F:\LAI\prodata\';待裁剪数据存放路径
  RawFiles = FILE_Search("*.img");裁剪数据格式，凡是ENVI识别的格式皆可以
  FileCount = N_ELEMENTS(RawFiles)
  IF FileCount EQ 0 THEN RETURN
  outdir ='F:\LAI\maskdata\';裁剪后数据存放路径
FOR NX =0,FileCount -1 DO BEGIN
 
     FileName = RawFiles[NX]
     envi_open_file, FileName , r_fid=fid 
 
  if (fid eq -1) then begin 
    envi_batch_exit 
    return 
  endif 
  PRINT, 'fid=',fid
;获取相关信息
ENVI_FILE_QUERY,fid,DIMS=dims,NS=ns,NL=nl,NB=nb, BNAMES= BNAMES
  t_fid=LONARR(nb)+fid
  pos=LINDGEN(nb)
  indexstr = strpos(FileName,".img")
  out_name =outdir+ strmid(FileName,0,indexstr) + ".img"
 
;打开矢量文件
  evf_file ='heihemask.evf';在此需要设置shapefile文件的文件名
  evf_id=ENVI_EVF_OPEN(evf_file)
 
;获取相关信息
ENVI_EVF_INFO, evf_id, num_recs=num_recs, $
data_type=data_type, projection=projection, $
layer_name=layer_name
roi_ids = LONARR(num_recs)
;读取各个记录的点数
FOR i=0,num_recs-1 DO BEGIN
record = ENVI_EVF_READ_RECORD(evf_id, i)
;转换为文件坐标
ENVI_CONVERT_FILE_COORDINATES,fid,xmap,ymap,record[0,*],record[1,*]
;创建ROI
roi_id = ENVI_CREATE_ROI(color=4,  $
ns = ns ,  nl = nl)
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
yMin=yMin-3
ymax = yMax < nl-1
ymax=ymax+5;
;创建掩膜，裁剪后掩
ENVI_MASK_DOIT,$
AND_OR =1, $
/IN_MEMORY, $
ROI_IDS= roi_ids, $ ;ROI的ID
ns = ns, nl = nl, $
/inside, $ ;区域内或外
r_fid = m_fid
out_dims = [-1,xMin,xMax,yMin,yMax]
 ENVI_MASK_APPLY_DOIT, FID = fid, POS = INDGEN(nb), DIMS = out_dims, $
M_FID = m_fid, M_POS = [0], VALUE = -10, $
out_name = out_name, R_FID = r_fid
;掩膜文件ID移除
  ENVI_FILE_MNG, id =m_fid,/remove
   ENDFOR
  
  ENVI_BATCH_EXIT
END