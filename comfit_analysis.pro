pro comfit_analysis
;进行几何模型拟合y=a0*x^a1+a2
  x=findgen(20)
  noise=randomu(seed, 20)*5
  y=4.6*x^0.7+10+noise
  ;进行曲线拟合
  a=[4, 0.5, 8];定义函数各系数的初值
  coeffs=comfit(x, y, a, /Geometric, imax=100, yfit=y_fitted)
  ;给出拟合方程
  str_a=string(coeffs[0], format='(f4.2)')
  str_b=string(coeffs[1], format='(f4.2)')
  str_c=string(coeffs[2], format='(f5.2)')
  print, '方程为：', 'y='+str_a+'*x^'+str_b+'+'+str_c
  ;绘制y与y拟合值之间的散点图
  p1=plot(y, y_fitted, xtitle='y', ytitle="y'", /buffer, $
    dimensions=[600, 500], symbol=24, color='blue', sym_size=0.8, $
    linestyle=6, margin=[0.1, 0.1, 0.02, 0.02])
  p2=plot([10, 50], [10, 50], /current, /overplot)
  MAE=mean(abs(y-y_fitted))
  RMSE=sqrt(mean((y-y_fitted)^2))
  str_MAE='MAE='+string(MAE, format='(f5.2)')
  str_RMSE='RMSE='+string(RMSE, format='(f5.2)')
  t1=text(0.15, 0.88, str_MAE, target=p1)
  t2=text(0.15, 0.83, str_RMSE, target=p1)
  o_fn='Scatter_y_y.emf'
  p1.save, o_fn, border=40
  p2.save, o_fn, border=40
end  