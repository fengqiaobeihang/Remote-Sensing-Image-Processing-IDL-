;MODIS产品以HDF格式存储，针对其批量处理（感兴趣数据提取，重投影）方法有几种：MRT，HEGT。
;这里介绍IDL基于MTCK工具的批处理方法，虽然它不是运行速度最快的，但是最简单有效的。
;以MODIS积雪产品MOD10A1为例：
;MOD10A1 积雪反照率 面积比例 提取
pro MOD10A1_snow_albedo
  compile_opt idl2
  envi,/restore_base_save_files
  envi_batch_init,log_file='batch.log'
  
  PRINT, '开始处理数据 : ',SYSTIME()
  
  ;选择需要批处理文件所在的文件夹
  inpath    = Dialog_pickfile(/directory,title='Select MOD010A1 files inputpath')
  
  cd, inpath                           ; this is very important 
  filenames = file_search('*.hdf')
  n = N_elements(filenames)
  
  ;选择处理后文件另存的文件夹位置
  outpath = Dialog_pickfile(/directory,title='Select MOD10A1 files outpath')
  
  ;导出FSC,SAD
  FOR i = 0, n-1  DO BEGIN
    
    MOD10A1filename = inpath+filenames[i]
    
    filename = filenames[i]
    out_name = STRMID(filename,0,23)+'_Snow_FSC_SAD'
    
    grid_name  = 'MOD_Grid_Snow_500m'
    sd_names   = ['Snow_Albedo_Daily_Tile','Fractional_Snow_Cover']

    ;Output method schema is:
    ;0 = Standard, 1 = Reprojected, 2 = Standard and reprojected
    OUT_METHOD = 0

    nan_fill = float('NaN')
    
   ;这里调用了MTCK
    convert_modis_data, in_file=MOD10A1filename,out_path=OUTPATH,$
      out_root=out_name,gd_name=grid_name,sd_names=sd_names,$
      out_method=OUT_METHOD,background=nan_fill,/no_msg

  ENDFOR

  PRINT, '处理完成 : ', SYSTIME()
  
  envi_batch_exit
  
end
