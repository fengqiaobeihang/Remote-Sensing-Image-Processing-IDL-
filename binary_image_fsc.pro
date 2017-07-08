;author:shao dong hang
;date:2016-1-29
pro binary_image_FSC
        compile_opt idl2
        envi,/restore_base_save_files
        envi_batch_init,log_file='batch.txt'
    
        ROOT_DIR = 'E:\测试数据\'
        imgpath = 'E:\测试数据\result\'
        FNS = FILE_SEARCH(ROOT_DIR,'*.tif',COUNT = COUNT)
        PRINT, 'There ara totally', COUNT,' images.'
        for i=0,COUNT-1 do begin
        fn = FNS[i]    
        ENVI_OPEN_FILE, fn, r_fid=fid
        IF (fid EQ -1) THEN BEGIN
          tmp = DIALOG_MESSAGE(fn +'文件读取错误',title = !sys_title, /error)
          CONTINUE
        ENDIF
        ;读取图像
        ;循环文件
        envi_file_query, fid, ns=ns, nl=nl, nb=nb, dims=dims, $
        data_type=data_type, interleave=interleave, offset=offset
        map_info=envi_get_map_info(fid=fid)
        ;读取波段
        band=envi_get_data(fid=fid, dims=dims, pos=i)
        sz=size(band)
        mt=sz[1]
        nn=sz[2]
        ratio=band[0:mt/10,0:nn/10]
        for j=0,nn-11,10 do begin
          for i=0,mt-11,10 do begin
            cband=band[i:i+9,j:j+9]
            ind=where(cband ge 200,count)
            ratio[i/10,j/10]=count/100.
          endfor
        endfor
        
        ;文件信息
        startTime = systime(1)
        
          file=FILE_BASENAME(fn)
          filetime=strpos(file,'am',/reverse_search)
          filename=strmid(file,filetime,9)
        
          map_info = envi_get_map_info(fid=fid) 
          out_name = imgpath+filename+'_FSC'+StrTrim(i+1,2)+'.tif'
          openw,lun,out_name,/get
          writeu,lun,envi_get_data(fid=fid, dims=dims, pos=ratio)
          free_lun,lun
          ENVI_SETUP_HEAD, fname=out_name, $
          ns=ns, nl=nl, nb=1, $
          interleave=0, data_type=data_type, $
          offset=0, /write,$
          MAP_INFO = MAP_INFO
        endfor
        print,'writeU time',systime(1)-startTime
       
        ;输出完成
        ENVI_FILE_MNG, id=fid, /remove


end