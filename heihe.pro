pro heihe
      
      file='F:\data0\wrfout_heihe_2008-01-01.nc'
      nid = ncdf_open(file, /nowrite )
      ; print out the dimensions of this file
      file_info = ncdf_inquire( nid )
      FOR dimid=0, file_info.ndims -1 DO BEGIN
        ncdf_diminq, nid, dimid, name, size
        print, ' ---&gt; dimension ' + name  + ' is: ', size 
      ENDFOR

      FOR varid=0, file_info.nvars-1 DO BEGIN
      ; inquire about the variable; returns structure
        var = ncdf_varinq( nid, varid )
        print,var
        print,'========================'
      ;read all attributes
      FOR var_att_id=0,var.natts -1 DO BEGIN
         att_name = ncdf_attname( nid, varid, var_att_id )
         print,att_name
         ncdf_attget, nid, varid, att_name, tematt
         print,string(tematt)
      ENDFOR
      ENDFOR
      ;latid = ncdf_varid(nid, 'LAT')  ;lat
      ;ncdf_varget, nid, latid, lat
      ;lonid = ncdf_varid(nid, 'LONG')  ;lon
      ;ncdf_varget, nid, lonid, lon
      ;GLWid = ncdf_varid(nid, 'GLW')  ;lon
      ;ncdf_varget, nid, GLWid, GLW
      ;
      ; Set the pixel size and map tie point
      ;
      ps = [0.05, 0.05]
      lat0=max(lat)
      lon0=min(lon)
      mc = [0.5D, 0.5D,lon0, lat0]
      units = ENVI_TRANSLATE_PROJECTION_UNITS('Degrees')
      map_info = ENVI_MAP_INFO_CREATE(/geographic, $
        mc=mc, ps=ps, units=units)
      o_fn=dialog_pickfile(title='结果保存为')+'.img'
       ENVI_WRITE_ENVI_FILE, att_name, out_name=o_fn, $
        map_info=map_info
end