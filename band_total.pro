pro band_total
  ;打开数据
  compile_opt idl2
  envi, /restore_base_save_files
  envi_batch_init, log_file='batch.log'
  print,'start time: ',systime()
  begintime = systime(1)
  
  root_dir = 'e:\heihefsc\2011fsc\'
  fns = file_search(root_dir,'*.tif',count = count)
  print, 'there ara totally', count,' images.'
  for i=0,count-1 do begin
  fn = fns[i]
  envi_open_file, fn, r_fid=fid
  envi_file_query, fid, ns=ns, nl=nl, nb=nb, dims=dims, $
    data_type=data_type, interleave=interleave, offset=offset
  map_info=envi_get_map_info(fid=fid)
  ;读取波段
  band=envi_get_data(fid=fid, dims=dims, pos=0)
  a=total(double(band)) ;计算波段的总和
  b=a-1942656D           ;减去空白部分的无效值
  c=1.16884234D          ;像元大小，单位为KM
  R=double((b*c^2)/100)
  print, R,format='(d16.4)'  ;最终结果,精确到小数点后4位
  endfor 
  
  print,'End time: ',systime()
  endtime = systime(1)
  timespan = endtime-begintime
  print,'Run Time: '+string(timespan)+' s'
  envi_batch_exit
end