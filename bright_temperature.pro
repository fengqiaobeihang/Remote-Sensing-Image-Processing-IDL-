;+
;该功能把HDF5数据中的波段1、2、3、4、6、7、8、9,10,11,12,13,14,15,16,17,18,19转换成反射率
;便进行 反演
;-
  PRO RADIATION_CORRECTION,modisname,outname
    COMPILE_OPT idl2
    ENVI, /RESTORE_BASE_SAVE_FILES
    ENVI_BATCH_INIT, LOG_FILE = 'batch_log.txt'
    ;路径名
    modisname='D:\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080603_0356_proj_lon+099.000_lat+038.50.hdf'
    outname='D:\fy-mersi\fushedingbiao.img'
    ;科学数据读取
    ref250=READ_DATASET(modisname,'EV_250_RefSB');读取band1,2,3,4,5
    ref1000=READ_DATASET(modisname,'EV_1KM_RefSB');读取band6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
    ;科学数据合成(剔除第5波段，保留其余19个波段，合成新的数据)
    ENVI_WRITE_ENVI_FILE,ref250[*,*,0],r_fid=fid_ref250_1,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref250[*,*,1],r_fid=fid_ref250_2,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref250[*,*,2],r_fid=fid_ref250_3,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref250[*,*,3],r_fid=fid_ref250_4,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,0],r_fid=fid_ref1000_6,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,1],r_fid=fid_ref1000_7,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,2],r_fid=fid_ref1000_8,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,3],r_fid=fid_ref1000_9,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,4],r_fid=fid_ref1000_10,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,5],r_fid=fid_ref1000_11,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,6],r_fid=fid_ref1000_12,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,7],r_fid=fid_ref1000_13,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,8],r_fid=fid_ref1000_14,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,9],r_fid=fid_ref1000_15,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,10],r_fid=fid_ref1000_16,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,11],r_fid=fid_ref1000_17,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,12],r_fid=fid_ref1000_18,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,13],r_fid=fid_ref1000_19,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,ref1000[*,*,14],r_fid=fid_ref1000_20,/IN_MEMORY
    ;传入HDF5文件波段数据以及数据集索引和对应数据集属性索引（以0开始）  
    ;EV_250_RefSB数据集反射率
    r_fid_ref250_1=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref250_1)
    r_fid_ref250_2=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref250_2)
    r_fid_ref250_3=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref250_3)
    r_fid_ref250_4=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref250_4)
    ;EV_1KM_RefSB数据集反射率
    r_fid_ref1000_6=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_6)
    r_fid_ref1000_7=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_7)
    r_fid_ref1000_8=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_8)
    r_fid_ref1000_9=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_9)
    r_fid_ref1000_10=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_10)
    r_fid_ref1000_11=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_11)
    r_fid_ref1000_12=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_12)
    r_fid_ref1000_13=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_13)
    r_fid_ref1000_14=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_14)
    r_fid_ref1000_15=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_15)
    r_fid_ref1000_16=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_16)
    r_fid_ref1000_17=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_17)
    r_fid_ref1000_18=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_18)
    r_fid_ref1000_19=REFLECT_RADIANCE_CALCULATE(modisname,fid_ref1000_19)
    ENVI_FILE_QUERY, r_fid_ref250_1,dims=dims
    ;将所有科学数据合成一个图像
    OUT_BNAME=['1KM Reflectance (band1) [250 Aggr]','1KM Reflectance (band2) [250 Aggr]',$
      '1KM Reflectance (band3) [250 Aggr]','1KM Reflectance (band4) [250 Aggr]','1KM Reflectance (band6)',$
      '1KM Reflectance (band7)','1KM Reflectance (band8)','1KM Reflectance (band9)','1KM Reflectance (band10)',$
      '1KM Reflectance (band11)','1KM Reflectance (band12)','1KM Reflectance (band13)','1KM Reflectance (band14)',$
      '1KM Reflectance (band15)','1KM Reflectance (band16)','1KM Reflectance (band17)','1KM Reflectance (band18)',$
      '1KM Reflectance (band19)','1KM Reflectance (band20)']
    ENVI_DOIT, 'cf_doit',fid=[r_fid_ref250_1,r_fid_ref250_2,r_fid_ref250_3,r_fid_ref250_4,r_fid_ref1000_6,r_fid_ref1000_7,$
      r_fid_ref1000_8,r_fid_ref1000_9,r_fid_ref1000_10,r_fid_ref1000_11,r_fid_ref1000_12,r_fid_ref1000_13,r_fid_ref1000_14,$
      r_fid_ref1000_15,r_fid_ref1000_16,r_fid_ref1000_17,r_fid_ref1000_18,r_fid_ref1000_19,r_fid_ref1000_20], $
      pos=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], dims=dims, OUT_BNAME=OUT_BNAME,$
      remove=0,r_fid=data_fid,out_name=outname
;    ENVI_BATCH_EXIT
  END
  FUNCTION READ_DATASET,filename,dataset
    sd_id = H5F_open(filename)
    data=H5D_READ(sd_id)
    H5D_CLOSE,sd_id
    RETURN,data
  END
  
  FUNCTION REFLECT_RADIANCE_CALCULATE,modisname,fid
    COMPILE_OPT idl2
    ;选择数据集
    sd_id = H5F_open(modisname)
    ENVI_FILE_QUERY, fid, dims=dims
    t_fid = [fid]
    pos = [0]
    ;表达式
    ENVI_DOIT, 'math_doit', $
      fid=t_fid, pos=pos, dims=dims,$
      exp=exp,r_fid=r_fid, /IN_MEMORY
    ENVI_FILE_MNG, id=fid, /remove
    RETURN,r_fid
  END
   ;辐射定标
   ;首先需要使用H5F文件操作函数打开文件ID，再读取数据数组
   ;//打开文件，读取波段数据
   varname='EV_RefSB'
   hdfid=H5F_OPEN(file)
   dataset_id3=H5D_OPEN(hdfid,varname)
   band=H5D_read(dataset_id3)
   ;MERSI辐射定标需要读取VIS_Cal_Coeff中对应通道的3个系数和太阳高度角数据集
   ;打开文件，读取定标系数VIS_Cal_Coeff中对应通道的3个系数，θ为太阳天顶角
   dataset_id2=H5F_OPEN(file)
   id=H5A_OPEN_NAME(dataset_id2,'RefSB_Cal_Coefficients')
   RefSB_Cal_Coefficients=H5A_READ(id)
   ;MERSI定标系数是一个扫描带一套系数，定标时需要逐扫描带计算
   ;k0,k1,k2为定标系数
   ;公式：pcos(θ)B =[ k0 + k1*DN+ k2*(DN^2)]/100
   band(*,*,j-4)=VIR_Cal_Coeff[j*3]+band(*,*,j-4)*VIR_Cal_Coeff[j*3+1]+VIR_Cal_Coeff[j*3+2]*band(*,*,j-4)*band(*,*,j-4)