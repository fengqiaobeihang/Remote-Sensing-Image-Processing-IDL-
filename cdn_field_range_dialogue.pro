pro cdn_field_range_dialogue, info

pro_name = 'cdn_field_range_dialogue'
@getinfo

widget_control, /hourglass
subset_name = info.vfield.name_sel
subset_name = subset_name(0)
subset_name=info.vfield.name_sel + $
    '[' + strcompress(string(info.subset.count)) +']'

widget_control, info.widgets.current_file, get_value=filename   
the_vdata_name=info.vdata.name_sel
vdata_ref=info.vdata.ref
the_name = info.vfield.name_sel
the_index = info.vfield.indices_sel

nlayer = info.hdf5.nlayer
current_data_name = ''
for j = 1, nlayer do begin
    if strlen(info.hdf5.name_string[j]) gt 0 then begin
  current_data_name = current_data_name + '/' + info.hdf5.name_string[j]
    endif
endfor
current_data_name = current_data_name + '/' + the_vdata_name

if info.show_attr gt 0 then begin
  get_data_attr,filename,current_data_name, the_index, 2, info
  if info.show_attr eq 2 then return
endif

;  Open a HDF5 file
fileid = open_hdf5_file(filename)
if fileid eq -1 then begin
    result=dialog_message('Problem open HDF5 file!',$
        title='View HDF Warning!')
    return
endif

;  Open the dataset
dataset_id = H5D_OPEN(fileid, current_data_name)

the_result = get_cdn_field_type(dataset_id, the_index, the_types, sds_rank, $
    sds_dims)

;  Get the dataspace id
dataspace_id = H5D_GET_SPACE(dataset_id)

;  Get the dimension sizes and rank for record
rec_rank = H5S_GET_SIMPLE_EXTENT_NDIMS(dataspace_id)

rec_dims = H5S_GET_SIMPLE_EXTENT_DIMS(dataspace_id, MAX_DIMENSIONS=max_dims)

if sds_rank gt 0 then begin
    sds_rank = sds_rank + rec_rank
    sds_dims = [sds_dims, rec_dims]
endif else begin
    sds_rank = rec_rank
    sds_dims = [rec_dims]
endelse

;if info.rangetype.type eq 2 then begin
;    read_vdata_multiple_files, filename, the_vdata_name, vdata_ref, the_name, $
; the_index, the_order, the_types, the_result, info
;    return
;endif

sds_dims = reverse(sds_dims)
info.sds.rank = sds_rank
info.sds.dims = sds_dims
info.sds.type = the_types

print,'dataset name = ',current_data_name
print,'field_name = ',info.vfield.name_sel
print,'rank = ',sds_rank
print,'dimension = ',sds_dims
print,'sds_type = ', the_types

unit_list = [the_result]
if the_result ne 'BAD' then info.unitname = ', '+unit_list[0] else info.unitname = ''
info = redefine_info( info, unit_list, 7)

close_hdf5_dataspace, dataspace_id
H5D_CLOSE, dataset_id
H5F_CLOSE, fileid
end