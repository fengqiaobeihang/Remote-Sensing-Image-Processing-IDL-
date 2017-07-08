pro Process_cal
;进行辐射定标
;*********打开并读入TM数据***********
  fn=dialog_pickfile(title='选择TM数据', get_path=work_dir)
  cd, work_dir
  envi_open_file, fn, r_fid=fid
  envi_file_query, fid, ns=ns, nl=nl, nb=nb, dims=dims, $
    interleave=interleave, offset=offset, bnames=bnames
  map_info=envi_get_map_info(fid=fid)
  
  ;辐射定标
  ;读取辐射定标系数
  fn_calib=dialog_pickfile(filter='*.txt', title='定标系数文件')
  openr, lun, fn_calib, /get_lun
  data=fltarr(2,6)
  readf, lun, data
  free_lun, lun
  gain=data[0,*] ;增益值
  bias=data[1,*] ;偏移值
  
  ;逐波段读入TM数据并完成辐射定标
  L=fltarr(ns,nl,nb)
  for i=0, nb-1 do begin
    data_band=envi_get_data(fid=fid, dims=dims, pos=i)
    L[*, *, i]=gain[i]*data_band+bias[i]
  endfor
  
  ;保存辐射亮度数据
  o_fn=dialog_pickfile(title='辐射亮度数据保存为')
  envi_write_envi_file, L, out_name=o_fn, ns=ns, nl=nl, nb=nb, $
    data_type=4, interleave=interleave, offset=offset, $
    bnames=bnames, map_info=map_info

end