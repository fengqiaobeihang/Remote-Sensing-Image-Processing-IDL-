;aspect积雪覆盖率
;author：shaodonghang
pro aspect_SCR
  ;打开数据
  COMPILE_OPT IDL2
  ENVI, /RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT, LOG_FILE='BATCH.LOG'
  print,'Start time: ',systime()
  begintime = systime(1)
  
  ROOT_DIR = 'H:\2000-2001逐月积雪面积数据\2011\west\'
  FNS = FILE_SEARCH(ROOT_DIR,'*.tif',COUNT = COUNT)
  PRINT, 'There ara totally', COUNT,' images.'
  for i=0,COUNT-1 do begin
  fn = FNS[i]
  envi_open_file, fn, r_fid=fid
  envi_file_query, fid, ns=ns, nl=nl, nb=nb, dims=dims, $
    data_type=data_type, interleave=interleave, offset=offset
  map_info=envi_get_map_info(fid=fid)
  ;读取波段
  band=envi_get_data(fid=fid, dims=dims, pos=0)
  a=total(double(band))   ;计算波段的总和
  b=3251840               ;减去空白部分的无效值east=3225088,north=3218816,north_east=3194752,north_west=3248512,south=3248384,south_east=3253632,south_west=3239808,west=3251840
  s=a-b                   ;像元总数
  d=1310                  ;east=1519,north=1568,north_east=1756,north_west=1336,south=1337,south_east=1296,south_west=1404,west=1310
  R=double(s/d)           ;积雪覆盖率
  print, R,format='(i3)'  ;最终结果,精确到小数点后4位
  endfor 
  
  print,'End time: ',systime()
  endtime = systime(1)
  timespan = endtime-begintime
  print,'Run Time: '+string(timespan)+' s'
  envi_batch_exit
end