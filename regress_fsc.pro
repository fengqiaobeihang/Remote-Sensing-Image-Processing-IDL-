;温度与积雪覆盖率的回归分析
;shaodonghang
;2015-12-29
pro regress_FSC
;读取数据，进行回归分析，并绘制散点图
  ;读取数据
  fn=dialog_pickfile(title='选择数据文件：', get_path=work_dir)
  cd, work_dir
  data=read_csv(fn, count=nl)
  x=data.(0)
  y=data.(1)
  a=regress(x, y, const=b, correlation=r, yfit=y_estimated)
  ;绘制x与y之间的散点图
  p1=plot(x, y, xtitle='x', ytitle='y', dimensions=[600, 500], $
    /buffer, symbol=4, /sym_filled, color='blue', sym_size=1.2, $
    linestyle=6, xrange=[-30, 30], yrange[-30, 70], xminor=5, $
    yminor=5, margin=[0.1, 0.1, 0.02, 0.02])
  x1=min(x) & x2=max(x)
  y1=a[0]*x1+b & y2=a[0]*x2+b
  p2=plot([x1, x2], [y1, y2], /current, /overplot)
  str_equation='y='+string(a[0], format='(f5.2)')+'*x+'+ $
    string(b, format='(f5.2)')
  str_correlation='r='+string(r, format='(f6.4)')
  t1=text(0.15, 0.88, str_equation, target=p1)
  t2=text(0.15, 0.83, str_correlation, target=p1)
  o_fn='Scatter_x_y.emf'
  p1.save, o_fn, border=40
  p2.save, o_fn, border=40
;绘制y与y'之间的散点图
  p1=plot(y, y_estimated, xtitle='y', ytitle="y'", $
    dimension=[600, 500], /buffer, symbol=24, color='red', $
    sym_size=0.8, linestyle=6, xrange=[0, 50], yrange[0, 50], $
    xminor=5, yminor=5, margin=[0.1, 0.1, 0.02, 0.02])
  p2=plot([0, 50], [0, 50], /current, /overplot)
  MAE=mean(abs(y-y_estimated))
  RMSE=sqrt(mean((y-y_estimated)^2))
  str_MAE='MAE='+string(MAE, format='(f5.2)')
  str_RMSE='RMSE='+string(RMSE, format='(f5.2)')
  t1=text(0.15, 0.88, str_MAE, target=p1)
  t2=text(0.15, 0.83, str_RMSE, target=p1)
  o_fn='Scatter_y_y.emf'
  p1.save, o_fn, border=40
  p2.save, o_fn, border=40
end