pro test
  ;打开TM数据
  fn=dialog_pickfile(title='选择TM数据',get_path=work_dir)
  cd, work_dir
  envi_open_file, fn, r_fid=fid
  envi_file_query, fid, ns=ns, nl=nl, nb=nb, dims=dims, $
    data_type=data_type, interleave=interleave, offset=offset
  map_info=envi_get_map_info(fid=fid)
  ;读取波段
  R=envi_get_data(fid=fid, dims=dims, pos=0)
  ;窄波段反照率向宽波段反照率转换
  a=(0.356*R+0.130*R+0.373*R+0.085*R+0.072*R-0.0018)/10000.0
  ;保存计算结果
  o_fn=dialog_pickfile(title='宽波段反照率保存为')
  envi_write_envi_file, a, out_name=o_fn, /no_copy, $
    ns=ns, nl=nl, nb=1, data_type=4, interleave=interleave, $
    offset=offset, map_info=map_info
end
