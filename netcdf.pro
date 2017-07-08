PRO netcdf
  COMPILE_OPT idl2
  ENVI, /RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT, LOG_FILE = 'batch.log'
  
  ncpath =  'F:\data\'
  imgpath = 'F:\SHUJU'

  ncfiles = FILE_SEARCH(ncpath,'*.nc',count=count)
  PRINT,count
  IF count LE 0 THEN RETURN
  
  PRINT,'Start at '+STRING(SYSTIME(/UTC))

  FOR i=0,2 DO BEGIN
    nid = NCDF_OPEN(ncfiles[i],/nowrite)
    finfo = NCDF_INQUIRE(nid)
    ns = 0L
    nl = 0L
    nb = 0L
    ;数据维数
    FOR dimid=0,finfo.ndims-1 DO BEGIN
      NCDF_DIMINQ,nid,dimid,name,size
      
      SWITCH name OF
        "south_north":BEGIN
          nl = size
          BREAK
        END
        "west_east":BEGIN
          ns = size
          BREAK
        END
        "Time":BEGIN
          nb = size
          BREAK
        END
        ELSE:BEGIN
          PRINT,'No Dim'
        END
      ENDSWITCH
    ENDFOR
    PRINT,ns,nl,nb
    ;读取数据
    startx = 0.0
    starty = 0.0
    endx   = 0.0
    endy   = 0.0
    gridsize = 0.0
    ntime = FLTARR(nb)
    FOR varid=0,finfo.nvars-1 DO BEGIN
      iswrite = 1
      var = NCDF_VARINQ(nid,varid)
      dataid = NCDF_VARID(nid,var.name)
      NCDF_VARGET,nid,dataid,data
      SWITCH var.name OF
        "LONG":BEGIN
          startx = data[0]
          ndata  = N_ELEMENTS(data)
          endx   = data[ndata-1]
          iswrite = 0
          BREAK
        END
        "LAT":BEGIN
          starty = data[0]
          ndata  = N_ELEMENTS(data)
          endy   = data[ndata-1]
          iswrite = 0
          BREAK
        END
        "Time":BEGIN
          ntime = data
          iswrite = 0
          BREAK
        END
      ENDSWITCH
      PRINT,startx,starty
      ;创建投影
      IF (gridsize EQ 0) AND iswrite THEN BEGIN
        gridsize = (ROUND(endx)-ROUND(startx))/FLOAT(ns)
        o_pixel_size = [gridsize,gridsize]
        mc = [0D,0D,startx,endy]
      ;定义投影参数
      units = envi_translate_projection_units('Meters')
      datum = 'D_Sphere_ARC_INFO'
      name = 'Lambert_Azimuthal_Equal_Area'
      params=[6370997,6370997,45,100,0,0]
      o_proj = envi_proj_create(type=11,name=name,datum=datum,units=units,params=params)
  
      for i=0,num-1 do begin
      file = filearr[i]
    
      ENVI_OPEN_FILE,file,r_fid=fid
      if (fid eq -1) then begin
        envi_batch_exit
        return
      endif

      envi_file_query,fid,dims=dims,nb=nb

      pos = lindgen(nb)
      out_name = outdir + file_basename(file,'.tif')+'.img'
      print,out_name

      ;关于这个怎么设置，自己在ENVI下做一个数据试试就知道了    
       envi_convert_file_map_projection,fid=fid,pos=pos,dims=dims,o_proj=o_proj,$
      o_pixel_size=o_pixel_size,grid=[25,25],out_name=out_name,warp_method=2,$
      resampling=0,background=0,/zero_edge
      ENDIF
      help,data
      ;写入ENVI img格式
      IF iswrite then begin
        file=FILE_BASENAME(ncfiles[i])
        filetime=strpos(file,'wrfout',/reverse_search)
        filename=strmid(file,filetime,23)
        STRPUT,filename,'_',6
        STRPUT,filename,'_',12
        STRPUT,filename,'-',17
        STRPUT,filename,'-',20
        outfilepath=imgpath+filename+var.name
        OPENW,hdata,outfilepath,/get_lun
        WRITEU,hdata,REVERSE(data,2)
        help,REVERSE(data,2)
        FREE_LUN,hdata
        DATA_TYPE = 4
        datatype = var.datatype
        SWITCH var.datatype OF
          "BYTE":BEGIN
            data_type = 1
            BREAK
          END
          "CHAR":BEGIN
            data_type = 1
            BREAK
          END
          "FLOAT":BEGIN
            data_type = 4
            BREAK
          END
        ENDSWITCH
        ENVI_SETUP_HEAD,fname=outfilepath,ns=ns,nl=nl,nb=nb,interleave=0,$
          data_type=data_type,offset=0,map_info=imaps,bnames=[var.name],/write,$
          /open,r_fid=data_fid
        ;ENVI_WRITE_FILE_HEADER, data_FID
        ;ENVI_FILE_MNG, ID=data_FID, /REMOVE
      ENDIF
    ENDFOR
  ENDFOR
  
  PRINT,'Ends at '+SYSTIME(/UTC)
END