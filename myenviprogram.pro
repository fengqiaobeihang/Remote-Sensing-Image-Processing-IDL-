pro hdf5_myENVIProgram
 compile_opt idl2
 on_error, 2
 
 ; General error handler
 Catch, error
 if (error ne 0) then begin
   Catch, /CANCEL
   if obj_valid(envi) then $
     envi.ReportError, "Error: " + !error_state.msg
   message, /RESET
   return
 endif
 
 envi=ENVI(/CURRENT)
 
 batchfiles = ["C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080603_0356_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080604_0340_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080605_0325_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080608_0428_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080612_0428_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080613_0409_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080614_0351_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080617_0434_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080618_0416_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080619_0357_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080620_0338_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080623_0422_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080624_0403_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080625_0344_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080628_0428_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080629_0409_proj_lon+099.000_lat+038.50.hdf", $
               "C:\Users\lhy\Desktop\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080630_0350_proj_lon+099.000_lat+038.50.hdf"]
 
 foreach file, batchfiles do begin
 
    rasterloop = envi.OpenRaster(file)
    rasterloop_fid = ENVIRasterToFID(rasterLoop)
    envi_file_query, rasterloop_fid, DIMS=rasterloop_dims, NB=rasterloop_nb, BNAMES=rasterloop_bnames, FNAME=rasterloop_fname
 
    ; Convert from its current map projection to a specified output projection.
    projection = envi_proj_create(TYPE=42, PE_COORD_SYS_STR='PROJCS["hao",GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Lambert_Azimuthal_Equal_Area"],PARAMETER["False_Easting",0.00000000],PARAMETER["False_Northing",0.00000000],PARAMETER["Central_Meridian",99.000000],PARAMETER["Latitude_Of_Origin",38.500000],UNIT["Meter",1.0]]')
    envi_convert_file_map_projection, FID=rasterloop_fid, DIMS=rasterloop_dims, POS=Lindgen(rasterloop_nb), $
             O_PROJ=projection, WARP_METHOD=2, RESAMPLING=0, /ZERO_EDGE, $
             OUT_BNAME='Reproject ('+rasterloop_bnames+')', $
             R_FID=reproj02_fid, OUT_NAME=envi.getTemporaryFilename()
    
 endforeach
 
 end