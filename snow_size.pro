;计算粒径
pro snow_size
  ;打开数据
  fn=dialog_pickfile(title='选择数据',get_path=work_dir)
  cd, work_dir
  envi_open_file, fn, r_fid=fid
  envi_file_query, fid, ns=ns, nl=nl, nb=nb, dims=dims, $
    data_type=data_type, interleave=interleave, offset=offset
  map_info=envi_get_map_info(fid=fid)
  ;读取波段DN值
  R=envi_get_data(fid=fid, dims=dims, pos=0)
  ;计算积雪粒径
  pi=3.141592654D
  x=double(2.82E-05)
  y=double(1.03E+00);y是波长
  a=4*pi*x/y
  b0=3.62D
  u=cos(28*3.141592654/180)
  v=cos(15*3.141592654/180)
  s=sin(15*3.141592654/180)
  s0=sin(28*3.141592654/180)
  cs=acos((-v*u+s*s0*cos(25*3.141592654/180))*3.141592654/180)
  p=11.1*exp(-0.087*cs)+1.1*exp(-0.014*cs)
  A=1.247D
  B=1.186D
  C=5.157D
  R0=(A+B*(u+v)+C*u*v+p)/4*(u+v)
  h0=1.0*3/7*(1+2*u)
  h1=1.0*3/7*(1+2*v)
  f=h0*h1/R0
  d=alog(R/R0)*alog(R/R0)/(a*b0^2*f^2)
  ;保存计算结果
  o_fn=dialog_pickfile(title='雪粒径结果保存为')
  envi_write_envi_file, d, out_name=o_fn, /no_copy, $
    ns=ns, nl=nl, nb=1, data_type=4, interleave=interleave, $
    offset=offset, map_info=map_info
end
