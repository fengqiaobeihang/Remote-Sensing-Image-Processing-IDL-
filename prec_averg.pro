pro prec_averg
  ;打开数据
  COMPILE_OPT IDL2
  ENVI, /RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT, LOG_FILE='BATCH.LOG'
  print,'Start time: ',systime()
  begintime = systime(1)
  
  ROOT_DIR = 'F:\NETCDF\UHB\'
  FNS = FILE_SEARCH(ROOT_DIR,'*.tif',COUNT = COUNT)
  PRINT, 'There ara totally', COUNT,' images.'
  ;循环文件
  for i=0,COUNT-1 do begin
    fn = FNS[i]
    envi_open_file, fn, r_fid=fid
    envi_file_query, fid, ns=ns, nl=nl, nb=nb, dims=dims, $
      data_type=data_type, interleave=interleave, offset=offset
    map_info=envi_get_map_info(fid=fid)
    ;读取波段
    for j=0, nb-1 do begin
    band=envi_get_data(fid=fid, dims=dims, pos=i)
    if j eq 0 then begin
      a=band
    endif else $
      a=a+double(band)   ;计算波段的总和，744个波段
    endfor
      a=a/nb             ;计算单个文件所有波段的均值
  b=mean(double(a))      ;总波段所有像元的均值
  print, b, format='(d6.2)'
  endfor
  print,'End time: ',systime()
  endtime = systime(1)
  timespan = endtime-begintime
  print,'Run Time: '+string(timespan)+' s'
  envi_batch_exit
end
