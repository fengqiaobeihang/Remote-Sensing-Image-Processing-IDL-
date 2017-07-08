;+
;.HDF5批量辐射定标
;Radiometric Calibration
;shaodonghang
;-
forward_function ENVI_PROJ_CREATE
pro HDF5_radio
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
    ;r_data = FLOAT(H5D_READ(sd_id))
    ENVI_OPEN_FILE,file,r_fid=sd_id;ns=ns,nl=nl,nb=nb,dims=dims,$
      ;interleave=interleave,offset=offset
    
    
    r_data = fltarr(ns, nl, nb)
    ;辐射定标
    attr_name = 'RefSBCoefficients'
    attr_id = H5A_OPEN_NAME(hd_id, attr_name)
    attr_vir_coeff = H5A_READ(attr_id)
    attr_vir_coeff = REFORM(attr_vir_coeff, 3, SIZE(attr_vir_coeff, /N_ELEMENTS) / 3)
                    
    FOR i = 0, band_num -1 DO BEGIN
      r_data[*, *, i] = (attr_vir_coeff[1, i] * r_data[*, *, i] + attr_vir_coeff[0, i]) / 100
    ENDFOR
    
    ENVI_OPEN_FILE,file,r_fid=fid
    if (fid eq -1) then begin
      envi_batch_exit
      return
    endif
    out_name = outdir + file_basename(file,'.hdf')+'.img'
    print,out_name
    envi_file_query,fid,dims=dims,ns=ns,nl=nl,nb=nb
    envi_write_envi_file, file,out_name=out_name,/no_copy,$
      ns=ns, nl=nl,nb=nb,data_type=data_type,interleave=0,offset=0
    
    envi_file_mng,id=fid,/REMOVE
    
    print,i
  endfor

  print,'End time: ',systime()
  endtime = systime(1)
  timespan = endtime-begintime
  print,'Run Time: '+string(timespan)+' s'
  envi_batch_exit
  
end