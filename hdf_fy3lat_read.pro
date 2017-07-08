Pro HDF_FY3LAT_READ, FILE, Latitude,$
EXTRA=EXTRAKEYWORDS
H5_id=H5F_OPEN(D:\fy-mersi\200806\FY3A_MERSI_GBAL_L1_20080603_0356_proj_lon+099.000_lat+038.50.hdf)
If h5_id eq-1 then begin
Msg=dialog_message(‘HDF5数据错误’,/error)
Endif
Group_name=’/’
Group_id=H5G_OPEN(H5_id,group_name)
Dataset_id=H5D_OPEN(group_id,’Latitude’);EV_250_RefSB_b1
Latitude=H5D_READ(dataset_id)
H5D_CLOSE,dataset_id
H5G_CLOSE,group_id
H5F_CLOSE,H5_id
END
