
;2013-12-25
PRO Course_13
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
  o_fn=dialog_pickfile(title='结果保存为')+'.img'
  ENVI_WRITE_ENVI_FILE, var_names, out_name=o_fn, $
        map_info=map_info
ENDFOR

END