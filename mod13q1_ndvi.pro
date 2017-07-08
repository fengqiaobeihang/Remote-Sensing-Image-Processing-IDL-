;+
;MOD13Q1  NDVI提取
;shaodonghang
;-
pro MOD13Q1_NDVI
  compile_opt idl2
  envi,/restore_base_save_files
  envi_batch_init,log_file='batch.log'

  PRINT, '开始处理数据 : ',SYSTIME()
  
  ;选择需要批处理文件所在的文件夹
  inpath= Dialog_pickfile(/directory,title='Select MOD13Q1 files inputpath')
  
  cd, inpath                           ; this is very important 
  filenames = file_search('*.hdf')
  n = N_elements(filenames)
  
  ;选择处理后文件另存的文件夹位置
  outpath = Dialog_pickfile(/directory,title='Select MOD13Q1 files outpath')
  
  ;导出NDVI
  FOR i = 0, n-1  DO BEGIN
    
    MOD13Q1filename = inpath+filenames[i]
    
    filename = filenames[i]
    out_name = STRMID(filename,0,41)+'_250m_16_days_NDVI'
    
    grid_name  = 'MODIS_Grid_16DAY_250m_500m_VI'
    sd_names   = ['250m 16 days NDVI']

    ;Output method schema is:
    ;0 = Standard, 1 = Reprojected, 2 = Standard and reprojected
    OUT_METHOD = 0

    nan_fill = float('NaN')
    
    ;这里调用了MTCK
    convert_modis_data, in_file=MOD13Q1filename,out_path=OUTPATH,$
          out_root=out_name,gd_name=grid_name,sd_names=sd_names,$
          out_method=OUT_METHOD,background=nan_fill,/no_msg

  ENDFOR

  PRINT, '处理完成 : ', SYSTIME()
  
  envi_batch_exit
  
end