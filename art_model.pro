;+
;project:ART积雪反照率模型
;author:shaodonghang
;date:2016-3-22
;-
pro ART_MODEL
    ;根据MOD09GA反射率和角度计算反照率
    ;打开反射率及角度数据
    fn_reflectance=dialog_pickfile(title='选择反射率数据', get_path=work_dir)
    cd, work_dir
    fn_angle=dialog_pickfile(title='选择角度数据')
    
    ;读入数据
    envi_open_file, fn_reflectance, r_fid=fid_reflectance
    envi_open_file, fn_angle, r_fid=fid_angle
    envi_file_query,fid_reflectance,ns=ns,nl=nl,nb=nb,dims=dims,$
      data_type=data_type,interleave=interleave,offset=offset
    map_info=envi_get_map_info(fid=fid_reflectance)
    
    ;for i=0, nb-1 do begin
      ;读取反射率数据
      ref_b1=envi_get_data(fid=fid_reflectance,dims=dims,pos=0)
      ref_b2=envi_get_data(fid=fid_reflectance,dims=dims,pos=1)
      ref_b3=envi_get_data(fid=fid_reflectance,dims=dims,pos=2)
      ref_b4=envi_get_data(fid=fid_reflectance,dims=dims,pos=3)
      ref_b5=envi_get_data(fid=fid_reflectance,dims=dims,pos=4)
      ref_b6=envi_get_data(fid=fid_reflectance,dims=dims,pos=5)
      ref_b7=envi_get_data(fid=fid_reflectance,dims=dims,pos=6)
      ;读取角度数据
      angle1=envi_get_data(fid=fid_angle,dims=dims,pos=0)
      angle2=envi_get_data(fid=fid_angle,dims=dims,pos=1)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
      angle3=envi_get_data(fid=fid_angle,dims=dims,pos=2)
      angle4=envi_get_data(fid=fid_angle,dims=dims,pos=3)
    
      ;调用ART_BRDF函数计算Albedo
      Albedo_result_b1=ART_BRDF(angle1,angle2,angle3,angle4,ref_b1)
      Albedo_result_b2=ART_BRDF(angle1,angle2,angle3,angle4,ref_b2)
      Albedo_result_b3=ART_BRDF(angle1,angle2,angle3,angle4,ref_b3)
      Albedo_result_b4=ART_BRDF(angle1,angle2,angle3,angle4,ref_b4)
      Albedo_result_b5=ART_BRDF(angle1,angle2,angle3,angle4,ref_b5)
      Albedo_result_b6=ART_BRDF(angle1,angle2,angle3,angle4,ref_b6)
      Albedo_result_b7=ART_BRDF(angle1,angle2,angle3,angle4,ref_b7)
      
    ;endfor
    ;窄波段反照率向宽波段反照率转换;;窄波段反照率向宽波段反照率转换，A=-0.0093+0.157a1+0.2789a2+0.3829a3+0.1131a5+0.069a7
    ALBEDO=-0.0093+0.157*Albedo_result_b1+0.2789*Albedo_result_b2+0.3829*Albedo_result_b3+0.1131*Albedo_result_b5+0.069*Albedo_result_b7
    ;保存反照率结果
;    file=FILE_BASENAME(fn)
;    filetime=strpos(file,'A+1',/reverse_search)
;    filename=strmid(file,filetime,9)   
;    out_name = imgpath+filename+'_Albedo'+StrTrim(i+1,2)+'.tif'
    o_fn=dialog_pickfile(title='反照率结果保存为')
    ENVI_WRITE_ENVI_FILE, ALBEDO, OUT_NAME=o_fn, /NO_COPY, $
      NS=NS, NL=NL, NB=1, DATA_TYPE=4, INTERLEAVE=INTERLEAVE, $
      OFFSET=OFFSET, MAP_INFO=MAP_INFO
END
    ;snow BRDF
FUNCTION ART_BRDF,angle1,angle2,angle3,angle4,data
    
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

    Rs=(data/R0)^(R0/K0*K1)         ;Rs为积雪光谱白空反照率
    Rp=Rs^K0                        ;Rp为积雪光谱黑空反照率
    f=0.3D                          ;f为天空散射光因子
    result=(1-f)*Rp+f*Rs            ;result位积雪光谱反照率，f为天空散射光因子，取地表反照率产品MOD43中的0.3
    RETURN,result
END       


    