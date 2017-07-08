pro read_txt
   fn=dialog_pickfile(title='open txt')
   nl=file_lines(fn)
   data=fltarr(1,nl)
   openr,lun,fn,/get_lun
   readf,lun,data
   fn_data=data*720   ;1,3,5,7,8,10,12为744；4,6,9,11为720；2为672
   o_fn=dialog_pickfile(title='DN值保存为')
   openw,lun,o_fn,/get_lun
   printf,lun,fn_data
   free_lun,lun
end