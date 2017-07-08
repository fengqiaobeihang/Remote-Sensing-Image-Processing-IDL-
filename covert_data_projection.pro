pro Covert_data_projection
;读取文件，转为Albers投影
  ;打开ENVI文件
  fn=dialog_pickfile(title='选择ENVI文件')
  envi_open_file, fn, r_fid=fid
  envi_file_query, fid, ns=ns, nl=nl, nb=nb, dims=dims
  
  ;定义Albers投影
  params=[6378245, 6356863, 0, 105, 0, 0, 25, 47]
  name='Albers_105'
  o_proj=envi_proj_create(type=9, name=name, params=params)
  
  ;投影转换
  pos=lindgen(nb);波段列表
  o_ps=[500,500];输出文件的空间分辨率
  grid=[50,50];设置控制点数目
  o_fn=dialog_pickfile(title='投影结果保存为')
  envi_convert_file_map_projection,fid=fid,r_fid=fid_out,$
    o_proj=o_proj,dims=dims,pos=pos,out_name=o_fn,background=0,$
    o_pixel_size=o_ps,grid=grid,warp_method=2,/zero_edge,$
    resampling=1
end