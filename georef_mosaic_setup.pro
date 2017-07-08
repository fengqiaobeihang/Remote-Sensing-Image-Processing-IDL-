pro georef_mosaic_setup, fids=fids, dims=dims, out_ps=out_ps, $
  xsize=xsize, ysize=ysize, x0=x0, y0=y0, map_info=map_info
compile_opt strictarr, hidden

; some basic error checking
;
if keyword_set(dims) then $
  if n_elements(fids) ne n_elements(dims[0,*]) then dims=0
;
if n_elements(fids) lt 2 then begin
  xsize = -1
  ysize = -1
  x0 = -1
  y0 = -1
  return
endif

; if no DIMS passed in
;
nfiles = n_elements(fids)
if (keyword_set(dims) eq 0) then begin
  dims = fltarr(5, nfiles)
  for i=0, nfiles-1 do begin
    envi_file_query, fids[i], ns=ns, nl=nl
    dims[*,i] = [-1L, 0, ns-1, 0, nl-1]
  endfor
endif

; - compute the size of the output mosaic (xsize and ysize)
; - store the map coords of the UL corner of each image since you'll need it later
;
UL_corners_X = dblarr(nfiles)
UL_corners_Y = dblarr(nfiles)
east = -1e34
west = 1e34
north = -1e34
south = 1e34
for i=0,nfiles-1 do begin
  pts = [ [dims[1,i], dims[3,i]],   $ 	; UL
          [dims[2,i], dims[3,i]],   $	; UR
          [dims[1,i], dims[4,i]],   $	; LL
          [dims[2,i], dims[4,i]] ]		; LR
  envi_convert_file_coordinates, fids[i], pts[0,*], pts[1,*], xmap, ymap, /to_map
  UL_corners_X[i] = xmap[0]
  UL_corners_Y[i] = ymap[0]
  east  = east > max(xmap)
  west = west < min(xmap)
  north = north > max(ymap)
  south = south < min(ymap)
endfor
xsize = east - west
ysize = north - south
xsize_pix = round( xsize/out_ps[0] )
ysize_pix = round( ysize/out_ps[1] )

; to make things easy, create a temp image that's got a header
; that's the same as the output mosaic image
;
proj = envi_get_projection(fid=fids[0])
map_info = envi_map_info_create(proj=proj, mc=[0,0,west,north], ps=out_ps)
temp = bytarr(10,10)
envi_enter_data, temp, map_info=map_info, /no_realize, r_fid=tmp_fid

; find the x and y offsets for the images
;
x0 = lonarr(nfiles)
y0 = lonarr(nfiles)
for i=0,nfiles-1 do begin
  envi_convert_file_coordinates, tmp_fid, xpix, ypix, UL_corners_X[i], UL_corners_Y[i]
  x0[i] = xpix
  y0[i] = ypix
endfor

;print, 'fids = ', fids
;print, 'dims = ', dims
;print, 'out_ps = ', out_ps
;print, 'xsize = ', xsize
;print, 'ysize = ', ysize
;print, 'x0 = ', x0
;print, 'y0 = ', y0
;print, 'map_info = ', map_info

; delete the tmp file
;
envi_file_mng, id=tmp_fid, /remove, /no_warning

end

