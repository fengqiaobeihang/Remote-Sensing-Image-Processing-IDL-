;MOD09A1 太阳天顶角、观测天顶角、相对方位角提取
;shaodonghang
PRO MOD09A1_reflectance
    COMPILE_OPT IDL2
    ENVI, /RESTORE_BASE_SAVE_FILES
    ENVI_BATCH_INIT, LOG_FILE='BATCH.LOG'
    PRINT, 'START : ',SYSTIME()
   
    ROOT_DIR = 'H:\MOD09A1\MOD09A1_PRO\'
    FNS = FILE_SEARCH(ROOT_DIR,'*.HDF',COUNT = COUNT)
    PRINT, 'There ara totally', COUNT,' images.'
   
    OUTPUT_LOCATION = 'H:\MOD09A1\MOD09A1_reflectance\' ;路径根据数据存储位置修改
    GRID_NAME = 'MOD_Grid_500m_Surface_Reflectance'
    SD_NAMES = ['sur_refl_b01','sur_refl_b02','sur_refl_b03','sur_refl_b04',$
    'sur_refl_b05','sur_refl_b06','sur_refl_b07','sur_refl_szen','sur_refl_vzen','sur_refl_raz'] ;提取数据类型
    ;OUTPUT_METHOD = 1  ;REPROJECTED
    OUTPUT_METHOD = 0 ;Standard
   
    ;投影转换设定
    UNITS = ENVI_TRANSLATE_PROJECTION_UNITS('Meters')
    OUTPUT_PROJECTION = ENVI_PROJ_CREATE(/UTM,ZONE=47,UNITS=UNITS)
    OUTPUT_PS_X = 500
    OUTPUT_PS_Y = 500
   
    INTERPOLATION_METHOD = 8 ;TRIANGULATION WITH NEAREST NEIGHBOR
   
    ;调用MTCK
    FOR i = 0, COUNT-1  DO BEGIN
        FILENAME = FNS[i]
        A = STRPOS(FILENAME,'.')
        ;OUTPUT_ROOT_NAME = 'NIR_'+ STRMID(FILENAME,A+1,8)STRMID(filename,0,23)(FILENAME,A+1,8)
        OUTPUT_ROOT_NAME = STRMID(FILENAME,A+1,8)
        CONVERT_MODIS_DATA, IN_FILE = FILENAME, $
            OUT_PATH = OUTPUT_LOCATION, OUT_ROOT=OUTPUT_ROOT_NAME, $
            /HIGHER_PRODUCT, /GRID, GD_NAME=GRID_NAME,SD_NAMES = SD_NAMES, $
            OUT_METHOD = OUTPUT_METHOD, OUT_PROJ = OUTPUT_PROJECTION, $
            OUT_PS_X = OUTPUT_PS_X, OUT_PS_Y = OUTPUT_PS_Y, $
            NUM_X_PTS = 50, $
            NUM_Y_PTS=50, $;INTERP_METHOD = INTERPOLATION_METHOD, $
            BACKGROUND='0', FILL_REPLACE_VALUE='0',$
            R_FID_ARRAY=R_FID_ARRAY, R_FNAME_ARRAY=R_FNAME_ARRAY, /NO_MSG
      
    ENDFOR
    PRINT, 'END : ', SYSTIME()
    ENVI_BATCH_EXIT
   
END