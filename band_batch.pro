;author:shao dong hang
;date:2016-1-27
pro band_batch
        compile_opt idl2
        envi,/restore_base_save_files
        envi_batch_init,log_file='batch.txt'
    
        ROOT_DIR = 'C:\Users\sdh\Desktop\1\'
        imgpath = 'C:\Users\sdh\Desktop\1\result\'
        FNS = FILE_SEARCH(ROOT_DIR,'*.tif',COUNT = COUNT)
        PRINT, 'There ara totally', COUNT,' images.'
        for i=0,COUNT-1 do begin
        fn = FNS[i]    
        ENVI_OPEN_FILE, fn, r_fid=fid
        IF (fid EQ -1) THEN BEGIN
          tmp = DIALOG_MESSAGE(fn +'文件读取错误',$
            title = !sys_title, /error)
          CONTINUE
        ENDIF
        ;文件信息
        ENVI_FILE_QUERY, fid, dims=dims, nb=nb,bnames = bnames,DATA_TYPE = dt,$
          ns = ns, nl = nl
        startTime = systime(1)
        for curBand =0,nb-1 do begin
        
          file=FILE_BASENAME(fn)
          filetime=strpos(file,'wrf',/reverse_search)
          filename=strmid(file,filetime,11)
        
          pos  = curBand
          map_info = envi_get_map_info(fid=fid) 
          out_name = imgpath+filename+'_band'+StrTrim(curBand+1,2)+'.tif'
          openw,lun,out_name,/get
          writeu,lun,envi_get_data(fid=fid, dims=dims, pos=pos)
          free_lun,lun
          ENVI_SETUP_HEAD, fname=out_name, $
          ns=ns, nl=nl, nb=1, $
          interleave=0, data_type=dt, $
          offset=0, /write,$
          MAP_INFO = MAP_INFO
        endfor
        print,'writeU time',systime(1)-startTime
       
        ;输出完成
        ENVI_FILE_MNG, id=fid, /remove

      ENDFOR
end