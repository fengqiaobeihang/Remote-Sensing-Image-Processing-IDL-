;+
;Project:基于ART模型的积雪反照率反演
;author:shaodonghang
;date:2016/3/22
;-
pro ART_albedo_model
    ;打开数据
    COMPILE_OPT IDL2
    ENVI, /RESTORE_BASE_SAVE_FILES
    ENVI_BATCH_INIT, LOG_FILE='BATCH.LOG'
    print,'Start time: ',systime()
    begintime = systime(1)
    filename=dialog_pickfile(title='选择MOD09GA反射率数据')
;  ROOT_DIR = 'E:\heihefsc\2011FSC\'
;  FNS = FILE_SEARCH(ROOT_DIR,'*.tif',COUNT = COUNT)
;  PRINT, 'There ara totally', COUNT,' images.'
;  ;循环文件
;  for i=0,COUNT-1 do begin
;    fn = FNS[i]
;    envi_open_file, fn, r_fid=fid
;    envi_file_query, fid, ns=ns, nl=nl, nb=nb, dims=dims, $
;      data_type=data_type, interleave=interleave, offset=offset
;    map_info=envi_get_map_info(fid=fid)
;    ;读取波段
;    for j=0, nb-1 do begin
;    band=envi_get_data(fid=fid, dims=dims, pos=i)
;    if j eq 0 then begin
;      a=band
;    endif else $
;      a=a+double(band)   ;计算波段的总和，744个波段
;    endfor
;      a=a/nb             ;计算单个文件所有波段的均值
;    b=mean(double(a))      ;总波段所有像元的均值
;    print, b, format='(d6.2)'
;  endfor
;########################################################################
    ;主程序;提取反射率数据集
    band1=READ_DATASET(filename,'sur_refl_b01_1') 
    band2=READ_DATASET(filename,'sur_refl_b02_1') 
    band3=READ_DATASET(filename,'sur_refl_b03_1')
    band4=READ_DATASET(filename,'sur_refl_b04_1')
    band5=READ_DATASET(filename,'sur_refl_b05_1')
    band6=READ_DATASET(filename,'sur_refl_b06_1')
    band7=READ_DATASET(filename,'sur_refl_b07_1')
    
    ENVI_WRITE_ENVI_FILE,band1[*,*],r_fid=fid_B1,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,band2[*,*],r_fid=fid_B2,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,band3[*,*],r_fid=fid_B3,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,band4[*,*],r_fid=fid_B4,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,band5[*,*],r_fid=fid_B5,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,band6[*,*],r_fid=fid_B6,/IN_MEMORY
    ENVI_WRITE_ENVI_FILE,band7[*,*],r_fid=fid_B7,/IN_MEMORY
      
    ;ENVI_FILE_QUERY,fid_sez,dims=sezdims
    ;DN*Scale
    fid_B1_c=ANGLE_CALCULATE(fid_B1)
    fid_B2_c=ANGLE_CALCULATE(fid_B2)
    fid_B3_c=ANGLE_CALCULATE(fid_B3)
    fid_B4_c=ANGLE_CALCULATE(fid_B4)
    fid_B5_c=ANGLE_CALCULATE(fid_B5)
    fid_B6_c=ANGLE_CALCULATE(fid_B6)
    fid_B7_c=ANGLE_CALCULATE(fid_B7)
    ;ART
    AL1=SNOW_BRDF(angle1,angle2,angle3,angle4,fid_B1_c)
    AL2=SNOW_BRDF(angle1,angle2,angle3,angle4,fid_B2_c)
    AL3=SNOW_BRDF(angle1,angle2,angle3,angle4,fid_B3_c)
    AL4=SNOW_BRDF(angle1,angle2,angle3,angle4,fid_B4_c)
    AL5=SNOW_BRDF(angle1,angle2,angle3,angle4,fid_B5_c)
    AL6=SNOW_BRDF(angle1,angle2,angle3,angle4,fid_B6_c)
    AL7=SNOW_BRDF(angle1,angle2,angle3,angle4,fid_B7_c)
    
    ALBEDO=-0.0093+0.157*AL1+0.2789*AL2+0.3829*AL3+0.1131*AL5+0.069*AL7 ;窄波段反照率向宽波段反照率转换
    ;保存反照率结果
    o_fn=dialog_pickfile(title='反照率结果保存为')
    ENVI_WRITE_ENVI_FILE, ALBEDO, OUT_NAME=o_fn, /NO_COPY, $
      NS=NS, NL=NL, NB=1, DATA_TYPE=4, INTERLEAVE=INTERLEAVE, $
      OFFSET=OFFSET, MAP_INFO=MAP_INFO
;########################################################################
    ;snow BRDF
  FUNCTION SNOW_BRDF,angle1,angle2,angle3,angle4,R
    angle5=abs(angle3-angle4) ;相对方位角
    
    A=1.247D
    B=1.186D
    C=5.157D
    u0=cos(angle1*!DTOR)  ;!DTOR为角度到弧度的转化系数π/180
    u=cos(angle2*!DTOR)   ;angle1,angle2,angle3 分别为太阳高度角、观测天顶角、相对方位角


    ;
    ;cos(a*3.14/180)
    s0=sin(angle1*!DTOR)
    s=sin(angle2*!DTOR)
    s1=cos(angle5*!DTOR)
    ;
    ;
    angle6=acos(-u*u0+s*s0*s1)

    P=11.1*exp(-0.087*angle6*!DTOR)+1.1*exp(-0.014*angle6*!DTOR);P为散射相函数

    R0=(A+B*(u+u0)+C*u*u0+P)/4*(u+u0)

    K0=1.0*3/7*(1+2*u0);K0和K1为逃离函数

    K1=1.0*3/7*(1+2*u)

    Rs=(R/R0)^(R0/K0*K1)            ;Rs为积雪光谱白空反照率
    Rp=Rs^K0                        ;Rp为积雪光谱黑空反照率
    f=0.3D                          ;f为天空散射光因子
    result=(1-f)*Rp+f*Rs            ;result位积雪光谱反照率，f为天空散射光因子，取地表反照率产品中的0.3
    RETURN,result
  END       
    ;窄波段反照率向宽波段反照率转换，A=-0.0093+0.157a1+0.2789a2+0.3829a3+0.1131a5+0.069a7
;############################################################################
    ;HDF数据读取
    FUNCTION READ_DATASET,filename,dataset
      SD_id = HDF_SD_START(filename)
      index = HDF_SD_NAMETOINDEX(SD_id,dataset)
      sds_id= HDF_SD_SELECT(SD_id,index)
      HDF_SD_GETINFO,sds_id,DIMS=dim
      HDF_SD_GETDATA,sds_id,data
      HDF_SD_ENDACCESS,sds_id
      RETURN,data
    END
;############################################################################
    ;角度数据提取
;    FUNCTION  ANGLE_DATA,filename
;     COMPILE_OPT idl2
     ;角度信息读取
     solarzenith=READ_DATASET(filename,'SolarZenith_1')
     sensorzenith=READ_DATASET(filename,'SensorZenith_1')
     solarazimuth=READ_DATASET(filename,'SolarAzimuth_1')
     sensorazimuth=READ_DATASET(filename,'SensorAzimuth_1')
     ;;;=======================================================================
     ;;;  角度信息合成
     ;;;======================================================================
      ENVI_WRITE_ENVI_FILE,solarzenith[*,*],r_fid=fid_soz,/IN_MEMORY
      ENVI_WRITE_ENVI_FILE,sensorzenith[*,*],r_fid=fid_sez,/IN_MEMORY
      ENVI_WRITE_ENVI_FILE,solarazimuth[*,*],r_fid=fid_soa,/IN_MEMORY
      ENVI_WRITE_ENVI_FILE,sensorazimuth[*,*],r_fid=fid_sea,/IN_MEMORY
      
      ;ENVI_FILE_QUERY,fid_sez,dims=sezdims
  
      fid_soz_c=ANGLE_CALCULATE(fid_soz)
      fid_sez_c=ANGLE_CALCULATE(fid_sez)
      fid_soa_c=ANGLE_CALCULATE(fid_soa)
      fid_sea_c=ANGLE_CALCULATE(fid_sea)
      
      angle1=MODIS_RESIZE(fid_soz_c)
      angle2=MODIS_RESIZE(fid_sez_c)
      angle3=MODIS_RESIZE(fid_soa_c)
      angle4=MODIS_RESIZE(fid_sea_c)
;     ;将四个有用信息的图像合成一个图像，便于后续的几何校正工作
;   ENVI_DOIT, 'cf_doit',fid=[fid_sez_c,fid_sea_c,fid_soz_c,fid_soa_c], $
;     pos=[0,0,0,0], dims=sezdims, $
;     remove=0,r_fid=info_fid ,/in_memory
     ;将四个单独的几何信息文件释放
;      ENVI_FILE_MNG, id=fid_sez, /remove
;      ENVI_FILE_MNG, id=fid_sea, /remove
;      ENVI_FILE_MNG, id=fid_soz, /remove
;      ENVI_FILE_MNG, id=fid_soa, /remove
;      angle_fid= MODIS_RESIZE(info_fid)
;   
;      RETURN,angle_fid
;   END   
;###############################################################################
  ;角度计算DN*Scale
   FUNCTION ANGLE_CALCULATE,fid
     COMPILE_OPT idl2
   
     ENVI_FILE_QUERY, fid, dims=dims
     t_fid = [fid]
     pos = [0]
     ;表达式
     exp='b1*0.0100'
     ENVI_DOIT, 'math_doit', $
     fid=t_fid, pos=pos, dims=dims,$
     exp=exp,r_fid=r_fid, /IN_MEMORY
     ENVI_FILE_MNG, id=fid, /remove
     RETURN,r_fid
   END
;##############################################################################
  ;角度数据重采样，从1000m采样到500m
    FUNCTION MODIS_RESIZE,fid
     COMPILE_OPT IDL2
     ; Open the input file
     IF (fid EQ -1) THEN BEGIN
     RETURN,-1
     ENDIF
     ENVI_FILE_QUERY, fid, dims=dims, nb=nb
     pos = LINDGEN(nb)
     out_name = 'testimg'
     ;把数据集重采样成1354*2030
     ENVI_DOIT, 'resize_doit', $
     fid=fid, pos=pos, dims=dims, $
     interp=1, rfact=[.20015,.2], $
     out_name=out_name, r_fid=r_fid
     RETURN,r_fid
    END
  ;计算运行时间
  print,'End time: ',systime()
  endtime = systime(1)
  timespan = endtime-begintime
  print,'Run Time: '+string(timespan)+' s'
  envi_batch_exit
END
