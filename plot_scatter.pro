;打开CSV格式的数据文件，绘制散点图。数据文件中有两列数据，第一列为观测数据，第二列为反演数据
;shaodonghang
pro plot_scatter
;读取数据绘制散点图，然后利用plot函数绘图并保存为文件
  ;读取数据
  fn=dialog_pickfile(title='选择数据文件')
  data=read_csv(fn, count=nsta)
  y=data.(0)
  y1=data.(1)
  ;绘制散点图
  minv=0.0 & maxv=50.0
  p1=plot(y, y1, xtitle='Yakou', ytitle='WRF', $
    symbol=4, /sym_filled, color='blue', sym_size=0.8, linestyle=6, $
    xrange=[0,50], yrange=[minv,maxv], xminor=5, yminor=5, $
    margin=[0.1,0.1,0.02,0.02], /buffer)
  x2=[-30,70] & y2=[-30,70]
  p2=plot(x2, y2, /overplot, /buffer)
  ;计算MAE和RMSE并作为标注添加到图形中
  R=correlate(y,y1)         ;简单相关系数
  MAE=mean(abs(y-y1))       ;平均绝对误差
  RMSE=sqrt(mean((y-y1)^2)) ;均方根误差
  print,'R=',R
  print,'MAE=',MAE
  print,'RMSE=',RMSE
  MAE_label='MAE='+string(MAE,format='(f5.2)')
  RMSE_label='RMSE='+string(RMSE,format='(f5.2)')
  R_label='R='+string(R,format='(f5.2)')
  t1=text(0.15,0.88,MAE_label,target=p1,font_size=12)
  t2=text(0.15,0.83,RMSE_label,target=p1,font_size=12)
  t3=text(0.15,0.78,R_label,target=p1,font_size=12)
  ;保存文件
  o_fn=dialog_pickfile(title='图像保存为') ;文件名要包含后缀名
  p1.save, o_fn, border=0
  p2.save, o_fn, border=0
end  