;基于evf数据批量裁剪遥感影像（img）
pro  sub_img_evf
  compile_opt idl2
  envi,/restore_base_save_files
  envi_batch_init,log_file='batch.txt'
  
  print,'Start Time: ',systime()
  
  ;选择数据文件夹
  folder = envi_pickfile(title='Select image data folder',/directory)
  ;选择evf
  evfname = dialog_pickfile(title='Selevt Evf',FILTER='.evf')
  if (folder eq '') then return
  
  ;查找数据
  imagefiles = file_search(folder,'*.img',count=count)
  if (count eq 0) then begin
    void = dialog_message(['Unable to locate image tile datasets in the selected folder :',$
      '',folder])
    !Quiet=quietinit
    return
  endif
  
  ;输出文件夹
  outfolder = envi_pickfile(title='Select Folder For Output',/directory)
  if (outfolder eq '') then begin
    !QUIET = quietinit
    return
  endif
  
  outfolder=outfolder+path_sep()
  cd,outfolder,current=current
  
  for i=0,count-1 do begin
    envi_open_file,imagefiles[i],r_fid=fid
    if (fid eq -1) then begin
      continue
    endif
    ;输出文件,需要加上后缀，否则得不到对应的头文件
    out_name=outfolder+file_basename(imagefiles[i],'.img')+'_babaohe.img'
    ;掩膜功能
    spatialsubset,fid,evfname,out_name
  endfor
  
  print, 'End Time: ', systime()
  
end
;基于evf文件掩膜,裁剪的边界与被裁减的影像一定要具有相同的投影,否则这一Routine永远不能正常使用
pro spatialsubset,data_fid,evfname,out_name
  compile_opt idl2
  
  ;获取栅格文件信息
  envi_file_query,data_fid,bnames=bnames,ns=ns,nl=nl,nb=nb
  ;打开矢量文件
  evf_id = envi_evf_open(evfname)
  ;获取矢量文件相关信息
  envi_evf_info,evf_id,num_recs=num_recs,data_type=data_type,projection=projection,$
    layer_name=layer_name
  roi_ids = lonarr(num_recs)
  
  ;输出的坐标系统
  ;  oproj=envi_get_projection(fid=data_fid)
  ;读取各个及记录的点数
  for i=0,num_recs-1 do begin
    record = envi_evf_read_record(evf_id,i)
    ;转换投影坐标点
    ;envi_convert_projection_coordinates,record[0,*],record[1,*],projection,$
    ; oxmap,oymap,oproj
    ;转换为文件坐标，这里更改了oxmap,oymap
    ;原来的是envi_convert_file_coordinates,data_fid,xmap,ymap,record[0,*],record[1,*]
    envi_convert_file_coordinates,data_fid,xmap,ymap,record[0,*],record[1,*]
    
    ;创建ROI
    roi_id=envi_create_roi(color=4,ns=ns,nl=nl)
    envi_define_roi,roi_id,/polygon,xpts=reform(xmap),ypts=reform(ymap)
    roi_ids[i] = roi_id
    
    ;记录XY的区间，裁剪用
    if i eq 0 then begin
      xmin = round(min(xmap,max=xmax))
      ymin = round(min(ymap,max=ymax))
    endif else begin
      xmin = xmin < round(min(xmap))
      xmax = xmax > round(max(xmap))
      ymin = ymin < round(min(ymap))
      ymax = ymax > round(max(ymap))
    endelse
    
  endfor
  
  xmin = xmin > 0
  xmax = xmax < ns-1
  ymin = ymin > 0
  ymax = ymax < nl-1
  
  ;创建掩膜，裁剪后掩膜
  envi_mask_doit,and_or=1,/in_memory,roi_ids=roi_ids,ns=ns,nl=nl,$
    /inside,r_fid=m_fid
  
  out_dims = [-1,xmin,xmax,ymin,ymax]
  
  envi_mask_apply_doit,fid=data_fid,pos=indgen(nb),dims=out_dims,$
    m_fid=m_fid,m_pos=[0],value=0,out_bname=bnames+' mask',in_memory=0,$
    out_name=out_name,r_fid=r_fid

  ;掩膜文件移除
  envi_file_mng,id=m_fid,/remove
  
end
