PRO fushedingbiao
    COMPILE_OPT IDL2
    ENVI, /RESTORE_BASE_SAVE_FILES
    ENVI_BATCH_INIT, LOG_FILE='BATCH.LOG'
    PRINT, 'START : ',SYSTIME()
    ;//打开文件，读取波段数据
    ROOT_DIR = 'F:\MODIS10_before\'
    FNS = FILE_SEARCH(ROOT_DIR,'*.HDF',COUNT = COUNT)
    PRINT, 'There ara totally', COUNT,' images.'
    OUTPUT_LOCATION = 'F:\MODIS10_later\' ;路径根据数据存储位置修改
    varname='EV_RefSB'
    hdfid=H5F_OPEN(FNS)
    dataset_id3=H5D_OPEN(hdfid,varname)
    band=H5D_READ(dataset_id3)
    ;//打开文件，读取定标系数
    dataset_id2=H5F_OPEN(FNS)
    id=H5A_OPEN_NAME(dataset_id2,"RefSB_Cal_Coefficients")
    RefSB_Cal_Coefficients=H5A_READ(id)
    for i=0, band-1 do begin
    band(*,*,i-4)=VIR_Cal_Coeff[i*3]+band(*,*,i-4)*VIR_Cal_Coeff[i*3+1]+VIR_Cal_Coeff[i*3+2]*band(*,*,i-4)*band(*,*,i-4)
endfor
end