pro envi_HDF_projection
 COMPILE_OPT IDL2
    ENVI, /RESTORE_BASE_SAVE_FILES
    ENVI_BATCH_INIT, LOG_FILE='BATCH.LOG'
    PRINT, 'START : ',SYSTIME()
   
    ROOT_DIR = 'F:\MODIS10_before\'
    FNS = FILE_SEARCH(ROOT_DIR,'*.HDF',COUNT = COUNT)
    PRINT, 'There ara totally', COUNT,' images.'
    IF COUNT EQ 0 THEN RETURN
    o_proj = ENVI_PROJ_CREATE(/geographic)
    FOR i=0, COUNT-1 DO BEGIN
    FileName = FNS[i]
    envi_open_file, FileName , r_fid=fid
    if (fid eq -1) then begin
      envi_batch_exit
      return
    endif
    envi_file_query, fid[0], dims=dims, nb=nb
    pos  = lindgen(nb)
    A= strpos(FileName,'.')
    out_name = STRMID(FILENAME,A+1,8)+'_Snow_FSC_SAD'
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