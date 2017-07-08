;提取研究区雪水当量产品，其投影方式为north easegrid，721*721的矩阵
pro esa_swe

  swe=fltarr(721,721);每个文件的swe

  swe_w=fltarr(721,281)

  temp=' '

  ;filename=file_search('E:\AMSR-E\AMSR_E_L3_MonthlySnow\MonthlySnow_hdf','*.hdf')I:\snow_data\AMSR-E SWE\AMSR_E_L3_MonthlySnow_V09_200206.hdf
  filename=file_search('I:\snow_data\AMSR-E SWE\','*.hdf')
  for i=0,n_elements(filename)-1 do begin
    ;for i=0,11 do begin

    file_id=hdf_sd_start(filename[i],/read);open hdf file
    swe_id=hdf_sd_select(file_id,0);open the first layer data
    hdf_sd_getdata, swe_id,swe; get swe data
    pos_oblique=strpos(filename[i],'\',/reverse_search);

    date=strmid(filename[i],pos_oblique+27,6);
    openw,w_lun,'I:\snow_data\AMSR-E SWE\output\'+date+'.txt',/get_lun

    printf,w_lun,'ncols 721'
    printf,w_lun,'nrows  281'
    printf,w_lun,'xllcorner  0'
    printf,w_lun,'yllcorner  15'
    printf,w_lun,'cellsize  0.25'
    printf,w_lun,'NODATA_value  -999'

    for k=0,280 do begin
      for j=0,720 do begin
        lon=0+j*0.25
        lat=85-k*0.25
        r=2*6371.228/25.067525*COS(lon*3.14/180)*SIN(3.14/4-(lat*3.14/180)/2)+360;row
        s=2*6371.228/25.067525*SIN(lon*3.14/180)*SIN(3.14/4-(lat*3.14/180)/2)+360;column
        swe_w(j,k)=swe(s,r)
      endfor
      printf,w_lun,swe_w(*,k), format='(721f8.2)'
    endfor

    hdf_sd_end, file_id; close hdf file
    print,filename(i)
    free_lun,w_lun
    free_lun,w_lun
  endfor
  free_lun,1
  print,'end'

end