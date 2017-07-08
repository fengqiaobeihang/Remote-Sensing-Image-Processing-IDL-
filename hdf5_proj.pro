;+
;.HDF5批量转换投影
;convert_map_projection
;shaodonghang
;-
forward_function ENVI_PROJ_CREATE
pro HDF5_proj
  compile_opt idl2
  envi,/restore_base_save_files
  envi_batch_init,log_file='batch.txt'
  
  print,'Start time: ',systime()
  begintime = systime(1)
  
  ;选择文件夹
  Dir = 'D:\fy-mersi\200806\'
  filearr = file_search(Dir,'*.hdf',count=num)
  ;输出文件夹
  outdir ='D:\fy-mersi\pro_data\'
  for i=0,num-1 do begin
    file = filearr[i]
    hd_id=h5f_open(filearr[i])           ;打开hdf5文件
    fieldname='20bands_L1B_DN_values' ;数据集名称
    sd_id=h5d_open(hd_id,fieldname)
    
    ENVI_OPEN_FILE,file,r_fid=fid
    if (fid eq -1) then begin
      envi_batch_exit
      return
    endif

    envi_file_query,fid,dims=dims,nb=nb
    ;定义投影参数
    units = envi_translate_projection_units('Meters')
    datum = 'D_WGS_1984'
    name = 'Lambert_Azimuthal_Equal_Area'
    params=[6370997,6370997,38.5,99.0,0,0]
    o_proj = envi_proj_create(type=11,name=name,datum=datum,units=units,params=params)
    o_pixel_size = [1000,1000]
    pos = lindgen(nb)
    out_name = outdir + file_basename(file,'.hdf')+'.img'
    ;filetime=strpos(file,'A',/reverse_search)
    ;STRPUT,file,'-',18
    ;out_name =outdir + STRMID(file,filetime,20)+'.img'
    print,out_name

    ;参照ENVI中的设置定义  
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