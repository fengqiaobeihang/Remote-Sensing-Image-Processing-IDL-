PRO HDF5
  ;
  COMPILE_OPT idl2
  ENVI,/RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT
  ;
  hdf = 'D:\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080603_0356_proj_lon+099.000_lat+038.50.hdf'
  is_h5 = H5F_IS_HDF5(hdf)
  IF is_h5 EQ 0 THEN RETURN
  ;h5_list,hdf
  hdf_id = H5F_OPEN(hdf)
  group= '/bands'
  elements_num = H5G_GET_NMEMBERS(hdf_id,group)
  band_g_id = H5G_OPEN(hdf_id,group)
 
  ;
  outpath = 'D:\fy-mersi\hdf_test.hdf'
  if file_test(outpath) then file_delete,outpath
  sd_id=HDF_SD_START(outpath,/CREATE)
 
  ;进度条
  str=['Outpath='+outpath,'Reading and writing']
  ENVI_REPORT_INIT, str, title="Processing...",base=base ,/INTERRUPT
  ENVI_REPORT_INC, base, elements_num
  FOR index = 0L, elements_num-1 DO BEGIN
    ;更新进度条
    ENVI_REPORT_STAT,base, index, elements_num
    ;
    item_Name = H5G_GET_MEMBER_NAME(hdf_id,group,index)
    item_id = H5D_OPEN(band_g_id,item_Name)
    ;item_type_code  = H5D_GET_TYPE(item_id)
    ;item_type = H5T_IDLTYPE(item_type_code)
    item_data = H5D_READ(item_id)
    ;print,item_Name,typename(item_data)
    ;help,item_data
    WRITE_HDF,sd_id,item_Name,item_data,typename(item_data)
    h5d_close,item_id
  ENDFOR
  ;close
  h5g_close,band_g_id
  h5f_close,hdf_id
  HDF_SD_END,sd_id
  envi_report_init,base=base,/finish
  void = dialog_message('Processing completed!',/info)
  ;  print, members
  ;envi_batch_exit
END
 
;writehdf的pro：
 
 
PRO WRITE_HDF,sd_id,data_set_name,data,datatype
  ;add dataset into hdf file
  ;sd_id: hdf identifer;data_set_name: the name you will add
  ;datatype:the data type
  sds_id = 1
  dims = SIZE(data,/dimensions)
  ;  datatype = '/'+datatype
  CASE (datatype) OF
    'LONG': BEGIN
      sds_id=HDF_SD_CREATE(sd_id,data_set_name,dims[*,*],/long)
    END
    'FLOAT':BEGIN
    sds_id=HDF_SD_CREATE(sd_id,data_set_name,dims[*,*],/float)
  END
  ELSE: BEGIN
    sds_id=HDF_SD_CREATE(sd_id,data_set_name,dims[*,*],/DFNT_UINT32)
  END
ENDCASE
HDF_SD_ADDDATA, sds_id, REFORM(data[*,*])
HDF_SD_SETINFO,sds_id,Label = data_set_name
HDF_SD_ENDACCESS,sds_id
;
END;