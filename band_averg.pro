pro band_averg
  ;打开数据
  COMPILE_OPT IDL2
  ENVI, /RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT, LOG_FILE='BATCH.LOG'
  print,'Start time: ',systime()
  begintime = systime(1)
  
  ROOT_DIR = 'E:\heihefsc\2000aveg\'
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
    if i eq 0 then begin
      a=band
    endif else $
      a=a+double(band) ;计算波段的总和
  endfor
    a=a/count
  
  o_fn=dialog_pickfile(title='图像均值保存为')
  envi_write_envi_file, a, out_name=o_fn, /no_copy, $
    ns=ns, nl=nl, nb=1, data_type=4, interleave=interleave, $
    offset=offset, map_info=map_info
   
  print,'End time: ',systime()
  endtime = systime(1)
  timespan = endtime-begintime
  print,'Run Time: '+string(timespan)+' s'
  envi_batch_exit
end