function spectra_deriv, spectra
  spectra_smoothed=smooth(spectra, 3)
  return, deriv(spectra_smoothed)
end
