;+
;.img Batch conversion projection (Sinusoidal --->> UTM WGS-84 500m 47zones)
;author:shaodonghang
;convert_map_projection
;2016-4-25
forward_function ENVI_PROJ_CREATE
pro convert_projection_UTM_WGS84
  compile_opt idl2
  envi,/restore_base_save_files
  envi_batch_init,log_file='batch.txt'
  
  print,'Start time: ',systime()
  begintime = systime(1)
  
  ;选择文件夹
  Dir = 'H:\MOD09A1\MOD09A1_project\'
  filearr = file_search(Dir,'*.img',count=num)
  ;输出文件夹
  outdir = 'H:\MOD09A1\MOD09A1_reflectance\'
  
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
    out_name = outdir+file_basename(file,'.img')+'_UTM.tif'
    print,out_name

    ;With reference to the ENVI projection Settings   
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
