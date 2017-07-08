;+
;.img批量转换投影 (Sinusoidal --->> UTM WGS-84 500m 47zones)
;convert_map_projection
;shaodonghang
;-
forward_function ENVI_PROJ_CREATE
pro cpb
  compile_opt idl2
  envi,/restore_base_save_files
  envi_batch_init,log_file='batch.txt'
  
  print,'Start time: ',systime()
  begintime = systime(1)
  
  ;选择文件夹
  Dir = 'D:\LATTIFF\'
  filearr = file_search(Dir,'*.tif',count=num)
  ;输出文件夹
  outdir = 'D:\Batch transfer projection\‘  
  
  ;定义投影参数
  units = envi_translate_projection_units('Meters')
  datum = 'WGS-84'
  o_proj = envi_proj_create(/UTM,zone=47,datum=datum,units=units)
  o_pixel_size = [500,500]
  
  for i=0,num-1 do begin
    file = filearr[i]
    
    ENVI_OPEN_FILE,file,r_fid=fid
    if (fid eq -1) then begin
      envi_batch_exit
      return
    endif

    envi_file_query,fid,dims=dims,nb=nb

    pos = lindgen(nb)
    out_name = outdir+file_basename(file,'.tif')+'_UTM.img'
    print,out_name

    ;关于这个怎么设置，自己在ENVI下做一个数据试试就知道了    
       envi_convert_file_map_projection,fid=fid,pos=pos,dims=dims,o_proj=o_proj,$
      o_pixel_size=o_pixel_size,grid=[25,25],out_name=out_name,warp_method=2,$
      resampling=0,background=0,/zero_edge
    
    envi_file_mng,id=fid,/REMOVE
    
    print,i
  endfor

  print,'End time: ',systime()
  endtime = systime(1)
  timespan = endtime-begintime
  print,'Run Time: '+string(timespan)+' s'
  envi_batch_exit
  
end
