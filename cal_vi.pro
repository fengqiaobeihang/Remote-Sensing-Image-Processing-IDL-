function cal_VI, r, nir, k1=key
  if key eq 0 then begin
    return, (float(nir)-r)/(float(nir)+r)
  endif else begin
    return, float(nir)/r
  endelse
end