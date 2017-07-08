pro enviprojection  
  COMPILE_OPT IDL2  
  envi, /restore_base_save_files  
  envi_batch_init, log_file='batch.txt'  
  cd,'F:\MODIS10_before'  
  HDFFiles = FILE_Search("*.HDF")  
  FileCount = N_ELEMENTS(HDFFiles)  
  IF FileCount EQ 0 THEN RETURN  
  o_proj = ENVI_PROJ_CREATE(/geographic)  
  FOR NX =0,FileCount -1 DO BEGIN  
    FileName = HDFFiles[NX]  
    envi_open_file, FileName , r_fid=fid  
    if (fid eq -1) then begin  
      envi_batch_exit  
      return  
    endif  
    envi_file_query, fid[0], dims=dims, nb=nb  
    pos  = lindgen(nb)  
    indexstr = strpos( STRUPCASE(FileName),".HDF")  
    out_name = strmid(FileName,0,indexstr) + "_Geo.raw"  
    o_pixel_size = [1000,1000]  ;  
    envi_convert_file_map_projection, fid=fid, $  
      pos=pos, dims=dims, o_proj=o_proj, $  
      o_pixel_size=o_pixel_size, grid=[10,10], $  
      out_name=out_name, warp_method=0, $  
      resampling=0, background=0  
    ENVI_FILE_MNG,id = fid,/remove  
  ENDFOR  
  envi_batch_exit  
end  
