  pro CESHI
      MyRootDir='F:\data0'


      ;遍历文件夹

      filearr = file_search(MyRootDir,'*.nc',count=num);
      if (num eq 0) then begin
        void=dialog_message(['Unable to locate image tile datasets in the selected folder :',$
        '',folder])
        !quiet=quietInit
        return
      endif
      
      for fileindex=0,num-1,1 do begin

      nid = ncdf_open(filearr[fileindex], /nowrite )


      ; inquire about this file; returns structure
      file_info = ncdf_inquire( nid ) 
          
      latid = ncdf_varid(nid, 'LAT')  ;lat
      ncdf_varget, nid, latid, lat
      lonid = ncdf_varid(nid, 'LONG')  ;lon
      ncdf_varget, nid, lonid, lon
      GLWid = ncdf_varid(nid, 'GLW')  ;lon
      ncdf_varget, nid, GLWid, GLW
      
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
      out_name=outfolder+file_basename(filearr[i],'.img')+'_nc.img'
      endfor
      ps = [1000, 1000]
      lat0=max(lat)
      lon0=min(lon)
      mc = [0.5D, 0.5D,lon0, lat0]
      params=[6370997, 6370997, 100, 45, 0, 0, 0]
      units = ENVI_TRANSLATE_PROJECTION_UNITS('Meters')
      map_info = ENVI_MAP_INFO_CREATE(/geographic,type=4,$
        mc=mc, ps=ps,params=params,units=units,datum='WGS-84')
      ENVI_WRITE_ENVI_FILE, LAT, out_name=out_name, $
        map_info=map_info
      ENVI_WRITE_ENVI_FILE, LONG, out_name=out_name, $
        map_info=map_info
      ENVI_WRITE_ENVI_FILE, GLW, out_name=out_name, $
        map_info=map_info
      endfor
END