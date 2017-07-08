;FY-3 MERSI 数据辐射定标
;author：邵东航
;//打开文件，读取波段数据
forward_function ENVI_PROJ_CREATE   
pro HDF5_RADIATION
   COMPILE_OPT IDL2
   ENVI, /RESTORE_BASE_SAVE_FILES
   ENVI_BATCH_INIT, LOG_FILE='BATCH.LOG'
   PRINT, 'START : ',SYSTIME()
   
   ROOT_DIR = 'D:\fy-mersi\200806\'
   FNS = FILE_SEARCH(ROOT_DIR,'*.HDF',COUNT = COUNT)
   PRINT, 'There ara totally', COUNT,' images.'
   IF count LE 0 THEN RETURN
   FOR i = 0, COUNT-1  DO BEGIN
     varname='20bands_L1B_DN_values'
     hdfid=H5F_OPEN(FNS[i])
     dataset_id=H5D_OPEN(hdfid,varname)
     band=H5D_read(dataset_id)
     ;MERSI辐射定标需要读取VIS_Cal_Coeff中对应通道的3个系数和太阳高度角数据集
     ;打开文件，读取定标系数VIS_Cal_Coeff中对应通道的3个系数，θ为太阳天顶角
     ;dataset_id2=H5F_OPEN(FNS[i])
     ;id=H5A_OPEN_NAME(dataset_id2,'RefSB_Cal_Coefficients')
     ;RefSB_Cal_Coefficients=H5A_READ(id)
     ;MERSI定标系数是一个扫描带一套系数，定标时需要逐扫描带计算
     ;k0,k1,k2为定标系数
     ;公式：pcos(θ)B =[ k0 + k1*DN+ k2*(DN^2)]/100
     ;band(*,*,j-4)=VIR_Cal_Coeff[j*3]+band(*,*,j-4)*VIR_Cal_Coeff[j*3+1]+VIR_Cal_Coeff[j*3+2]*band(*,*,j-4)*band(*,*,j-4)
     ;定义投影参数
     units = envi_translate_projection_units('Meters')
     datum = 'D_Sphere_ARC_INFO'
     name = 'Lambert_Azimuthal_Equal_Area'
     params=[6370997,6370997,45,100,0,0]
     o_proj = envi_proj_create(type=11,name=name,datum=datum,units=units,params=params)
     o_pixel_size = [1000,1000]
     ;################################################################
     file = FNS[i]
    
     ENVI_OPEN_FILE,band,r_fid=fid
     if (fid eq -1) then begin
       envi_batch_exit
       return
     endif

     envi_file_query,fid,dims=dims,nb=nb
     ;###############################################################
     pos = lindgen(nb)
     out_name = outdir + file_basename(file,'.HDF')+'.img'
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
  ENDFOR
  PRINT, 'END : ', SYSTIME()
    
  ENVI_BATCH_EXIT
END