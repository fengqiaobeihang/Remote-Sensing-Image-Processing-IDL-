pro TM_enhance2, TM_data
  img=TM_data[*, *, 2:4]
  sz=size(img)
  ns=sz[1] & nl=sz[2]
  result=bytarr(3, ns, nl)
  for i=0, 2 do begin
    result[i, *, *]=stretch_2PCT(img[*, *, 2-i])
  endfor
  o_fn=dialog_pickfile(title='结果图像保存为：')
  write_image, o_fn+'.png', 'png', result, /order
  end
function stretch_2PCT, img
  ht=histogram(img, nbins=255, locations=locations)
  ht_acc=total(ht, /cumulative)/n_elements(img)
  w1=where(ht_acc gt 0.02)
  minV_enhance=locations[w1[0]-1]
  w2=where(ht_acc ge 0.98)
  maxV_enhance=locations[w2[0]]
  return, bytscl(img, min=minV_enhance, max=maxV_enhance)
end