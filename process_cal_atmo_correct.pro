pro Process_cal_atmo_correct
;进行辐射定标和大气校正处理
;**************打开并读入数据**************
  fn=dialog_pickfile(title='选择TM数据', get_path=work_dir)
  cd, work_dir
  envi_open_file, fn, r_fid-fid
  envi_file_query, fid, ns=ns, nl=nl, nb=nb, dims=dims,$
  interleave=interleave, offset=offset, bnames=bnames
  map_info=envi_get_map_info(fid=fid)
  
  ;************辐射定标******************
  ;读取辐射定标系数
  fn_calib=dialog_pickfile(filter='*.txt',title='定标系数文件')
  openr, lun, fn_calib, /get_lun
  data=fltarr(2,6)
  readf, lun, data
  free_lun, lun
  gain=data[0,*] ;增益值
  bias=data[1,*] ;偏移值
   
  ;逐波段读入TM数据并完成辐射定标
  L=fltarr(ns, nl, nb)
  for i=0, nb-1 do begin
    data_band=envi_get_data(fid=fid, dims=dims, pos=i)
    L[*, *, i]=gain[i]*data_band+bias[i]
  endfor
  
  ;保存辐射亮度数据
  o_fn=dialog_pickfile(title='辐射亮度数据保存为')
  envi_write_envi_file, L, out_name=o_fn, ns=ns, nl=nl, nb=nb, $
    data_type=4, interleave=interleave, offset=offset, $
    bnames=bnames, map_info=map_info
  
  ;****************大气校正******************
  ;读取6S模型输入文件
  fn_in=dialog_pickfile(filter='*.txt', title='选择6S输入参数文件')
  openr, lun, fn_in, /get_lun
  data=strarr(13)
  readf, lun, data
  free_lun, lun
  ;逐波段循环，修改波段设置并调用6S模型计算，得到各波段大气校正系数
  Ref=fltarr(ns, nl, nb)
  for i=0, nb-1 do begin
    ;修改波段参数（6S输入参数中， TM第1-5、 7波段的代码分别为25~30）
    data[8]=string(25+i, format='(i4)')
    ;将修改完的参数写入为一个txt文件作为6S输入文件
    fn_in_6S='in_band'+string(i+1, format='(i1)')+'.txt'
    openw, lun, data, format='(a)'
    free_lun, lun
    
    ;调用6S模型计算
    fn_out_6S='out_band'+string(i+1, format='(i1)')+'.txt'
    spawn, 'main <'+fn_in_6S+' >'+fn_out_6S, /hide
    
    ;读取大气校正系数
    openr, lun, fn_out_6S, /get_lun
    str_line=''
    flag=0
    while flag eq 0 do begin
    ;一直读取直到大气校正系数停止
      readf, lun, str_line
      if strpos(str_line, 'coefficients xa xb xc') ne -1 then flag=1
    endwhile
    free_lun, lun
    str_split=strsplit(str_line, ' :', /extract) ;分割字符串
    ;提取校正系数
    xa=float(str_split[5])
    xb=float(str_split[6])
    xc=float(str_split[7])
    
    ;进行大气校正，得到地表真实反射率
    y=xa*L[*, *, i]-xb
    Ref[*, *, i]=y/(1+xc*y)
    ;删除前面生成的6S模型输入和输出文件
    file_delete, fn_in_6S, fn_out_6S, /quiet
    
  endfor
  
  ;保存地表反射率数据
  o_fn=dialog_pickfile(title='地表反射率数据保存为')
  envi_write_envi_file, Ref, out_name=o_fn, /no_copy, ns=ns, $
    nl=nl, nb=nb, data_type=4, interleave=interleave, $
    offset=offset, bnames=bnames, map_info=map_info
    
end