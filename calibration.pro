function Calibration, TM_data
  gain=[0.762824, 1.442510, 1.03988, 0.872588, 0.119882, 0.065294]
  bias=[-1.52, -2.84, -1.17, -1.51, -0.37, -0.15]
  sz=size(TM_data)
  result=make_array(size=sz, /float)
  nb=sz[3]
  for i=0, nb-1 do begin
    result[*, *, i]=TM_data[*, *, i]*gain[i]+bias[i]
  endfor
  return, result
end