pro LST
  ;运用单窗和单通道算法从TM反演地表温度
  ;****************打开TM数据文件并设置相关大气参数**************
  ;打开TM数据
  fn=dialog_pickfile(title='选择TM数据', get_path=work_dir)
  cd, work_dir
  envi_open_file, fn, r_fid=fid
  envi_file_query, fid, ns=ns, nl=nl, nb=nb, dims=dims, $
    data_type=data_type, interleave=interleave, offset=offset
  map_info=envi_get_map_info(fid=fid)
  
  ;设定大气参数
  w=2.49  ;大气水汽含量，单位g.cm-2
  T0=21+273.15  ;近地表气温，单位为K
  
  ;*************************辐射定标与亮温计算*************************
  b6=envi_get_data(fid=fid, dims=dims, pos=5)
  L=0.055158*b6+1.2378 ;辐射定标
  Tb=1260.56/alog(1+607.76/L) ;亮温计算
  
  ;************************计算比辐射率*******************************

  ;计算NDVI
  b3=envi_get_data(fid=fid, dims=dims, pos=2)
  b4=envi_get_data(fid=fid, dims=dims, pos=3)
  NDVI=(float(b4)-b3)/(float(b4)+b3)
  ;计算MNDVI
  b2=envi_get_data(fid=fid, dims=dims, pos=1)
  b5=envi_get_data(fid=fid, dims=dims, pos=4)
  MNDVI=(float(b2)-b5)/(float(b2)+b5)
  ;计算比辐射率
  Emiss=cal_emiss(NDVI, MNDVI)
  ;删除中间变量，节约内存
  b2=!null
  b3=!null
  b4=!null
  b5=!null
  NDVI=!null
  MNDVI=!null
  
  ;************************运用单通道算法计算地表温度**********************
  
  ;调用cal_LST_sc计算地表温度
  LST_result=cal_LST_sc(Tb, L, w, Emiss)
  ;保存结果
  o_fn=dialog_pickfile(title='单通道算法计算结果保存为')
  envi_write_envi_file, LST_result, out_name=o_fn, /no_copy, $
    ns=ns, nl=nl, nb=1, data_type=4, interleave=interleave, $
    offset=offset, map_info=map_info
    
  ;***********************运用单窗算法计算地表温度**************************
  
  ;调用cal_LST_mw计算地表温度
  LST_result=cal_LST_mw(Tb, T0, w, Emiss)
  ;保存结果
  o_fn=dialog_pickfile(title='单窗道算法计算结果保存为')
  envi_write_envi_file, LST_result, out_name=o_fn, /no_copy, $
    ns=ns, nl=nl, nb=1, data_type=4, interleave=interleave, $
    offset=offset, map_info=map_info
    
end

;##############################################################################

function cal_Emiss, NDVI, MNDVI
;计算比辐射率
;参数NDVI和MNDVI分别为归一化植被指数及改进归一化水体指数

  result=1.0094+0.047*alog(NDVI)
  
  ;NDVI<0.157
  w=where(NDVI lt 0.157, count)
  if count gt 0 then result[w]=0.923
  
  ;NDVI>0.727
  w=where(NDVI gt 0.727, count)
  if count gt 0 then result[w]=0.994
  
  ;水体
  w=where(MNDVI gt 0, count)
  if count gt 0 then result[w]=0.995
  
  return, result
  
end

;###############################################################################
function cal_LST_sc, Tb, L, w, Emiss
;基于单通道算法计算地表温度
;参数Tb, L, w, Emiss分别为亮温、辐亮度、水汽含量和地表比辐射率
;两个经验常数
  c1=1.19104E8
  c2=14387.7
;大气水汽相关函数
  x1=0.14714D*w^2-0.15583*w+1.1234
  x2=-1.1836D*w^2-0.37607*w-0.52894
  x3=-0.04554D*w^2+1.8719*w-0.39071
;计算地表温度
  Y=(Tb^2)/(c2*L*(11.457^4*L/c1+1/11.457))
  Z=-Y*L+Tb
  Result=Y*((x1*L+x2)/Emiss+x3)+Z
  return, float(result)
  
end

;###############################################################################
function cal_LST_mw, Tb, T0, w, Emiss

;基于单窗算法计算地表温度
;参数Tb, T0, w, Emiss分别为亮温、近地表气温、水汽含量和地表比辐射率
;两个经验常数
  a=-67.35535
  b=0.458608
  Trans=1.031412-0.11536D*w  ;计算大气透过率
  Ta=16.011+0.91118*T0       ;计算大气平均作用温度
;计算地表温度
  C=Trans*Emiss
  D=(1-Trans)*(1+Trans*(1-Emiss))
  result=(a*(1-C-D)+(b*(1-C-D)+C+D)*Tb-D*Ta)/C
  return, float(result)
  
end