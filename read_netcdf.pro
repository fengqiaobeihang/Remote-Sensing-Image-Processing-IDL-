
PRO read_netcdf
;定义文件路径

MyRootDir='D:\10'


;遍历文件夹

filearr = file_search(MyRootDir,'*.nc',count=num);

FOR fileindex=0,num-1,1 DO BEGIN

nid = ncdf_open(filearr[fileindex], /nowrite )


; inquire about this file; returns structure
file_info = ncdf_inquire( nid )

; print out the dimensions of this file
FOR dimid=0, file_info.ndims -1 DO BEGIN
  ncdf_diminq, nid, dimid, name, size
  print, ' ---&gt; dimension ' + name  + ' is: ', size 
ENDFOR

FOR varid=0, file_info.nvars-1 DO BEGIN
  ; inquire about the variable; returns structure
  var = ncdf_varinq( nid, varid )
  print,var
  print,'========================'
  ;read all attributes
  FOR var_att_id=0,var.natts -1 DO BEGIN
    att_name = ncdf_attname( nid, varid, var_att_id )
    print,att_name
    ncdf_attget, nid, varid, att_name, tematt
    print,string(tematt)
  ENDFOR
ENDFOR
;read sst
sstid = ncdf_varid(nid, 'analysed_sst')
ncdf_varget, nid, sstid, sst
sst=sst*0.01+273.150
landindex=where(sst eq min(sst))
sst[landindex]=max(sst)+1
Img=image(sst,rgb_table=39,title=filearr(fileindex),grid_units=1,POSITION=[0.1,0.2,0.9,0.9])
xaxis=axis('X',LOCATION=[0,0],AXIS_RANGE=[-180,180],MINOR=0, MAJOR=19,COORD_TRANSFORM=[-180,360.0/4096.0],title='Longitude(°)')
yaxis=axis('Y',LOCATION=[0,0],AXIS_RANGE=[-90,90],MINOR=0, MAJOR=7,COORD_TRANSFORM=[-90,180.0/2048.0],title='Latitude(°)')
c1 = COLORBAR(TARGET=Img, ORIENTATION=0,TITLE='(K) ',POSITION=[0.1,0.1,0.9,0.15])

ENDFOR

END

