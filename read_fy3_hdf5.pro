;+
; :Description:
;    Describe the procedure.
;    Read hdf5 file of Satellite FY-3A, this procedure can only read
;    level 'L1' and 'L2' hdf5 data of FY-3A.
;
; :Params:
;    infilename : Designating path of the data to be processed.
;
; :Keywords:
;    data_level : Set FY-3A data level, 'L1' or 'L2'. data_level = 'L1' or 'L2'.
;    dset_name  : Set dataset name in the input FY-3A hdf5 file. dset_name only 
;                 accept one dataset name.
;    pos        : Same as  keyword 'POS' in ENVI.
;    r_bnames   : Use this keyword to specify the band names assigned to the data. 
;                 r_bnames is a string array (with num_bands elements) of band names.
;    ns         : Use this keyword to specify a named variable that contains the number 
;                 of samples in the file. 
;    nl         : Use this keyword to specify a named variable that contains the number 
;                 of lines in the file. 
;    nb         : Use this keyword to specify a named variable that contains the number 
;                 of bands in the file. 
;
; :Uses:
;    ; For apparent reflectance data.
;    input_filename = 'D:\water vapor inversion\FY-3A\source data\FY3A_MERSI_GBAL_L1_20090502_0305_1000M_MS.HDF'
;    output_dir = 'D:\'
;    data_level = 'L1'
;    dset_name = ['EV_1KM_RefSB']
;
;    data = read_fy3_hdf5(input_filename,data_level = data_level, $
;                           dset_name = dset_name, r_bnames = r_bnames, $
;                           ns = ns, nl = nl, nb = nb)
;
; :Author: dabin
; :Email: dabinj@gmail.com
; :Date: 2015-11-20
;-
FUNCTION read_fy3_hdf5, infilename,data_level = data_level, dset_name = dset_name, pos = pos, $
                           r_bnames = r_bnames, ns = ns, nl = nl, nb = nb
    ;To check whether the input file is a hdf5 file or not, 
    ;if not, then return 0, and exit the program. 
    IF ~H5F_IS_HDF5(infilename) THEN BEGIN
        PRINT, 'File: ' + infilename + ' is not hdf5 file!'
        RETURN, 0
    ENDIF

    IF ~KEYWORD_SET(dset_name) THEN BEGIN
        PRINT, 'Dataset name was not set!'
        RETURN, 0
    ENDIF

    ;Get information of hdf5 file
    hdf5_info = H5_PARSE(infilename)
    hdf5_info_dset_name = TAG_NAMES(hdf5_info)    
    
    ;Check whether the dataset name is included in file or not.
    idx = WHERE(hdf5_info_dset_name EQ dset_name[0], count)
    
    IF (count EQ -1) THEN BEGIN
        PRINT, 'Can not find dataset "' + dset_name + '" in file "' + infilename + '"'
        RETURN, 0
    ENDIF

    ;Open an HDF5 file and dataset in it
    file_id = H5F_OPEN(infilename)
    
    ; Read the dataset information.
    dset_info = H5_PARSE(file_id, dset_name[0])
    
    IF ~STRCMP(dset_info._type, 'DATASET', /FOLD_CASE) THEN BEGIN
        PRINT, '"' + dset_info._type + '" is not a Dataset.'
        RETURN, 0
    ENDIF  
    
    ;Check data level, this program can only process 'L1' and 'L2' data.
    IF ~STRCMP(SIZE(data_level, /TNAME), 'String', /FOLD_CASE) THEN BEGIN   ;Check type of data_level
        PRINT, 'The input parameter "data_level" must be a string!'
        RETURN, 0
    ENDIF

    ;Get dimensions of the dataset
    data_dimension = dset_info._dimensions
    ns = data_dimension[0]
    nl = data_dimension[1]
    IF (dset_info._ndimensions EQ 3) THEN BEGIN
        nb = data_dimension[2]
    ENDIF ELSE BEGIN
        nb = 1
    ENDELSE
    
    ; Allocate memory for data
    r_data = FLTARR(ns, nl, nb)
    
    CASE 1 OF
        STRCMP(data_level, 'L1', /FOLD_CASE) : BEGIN
            ;Read data according dset_name
            dset_id = H5D_OPEN(file_id, dset_name[0])
            r_data = FLOAT(H5D_READ(dset_id))
            
            CASE 1 OF
                STRCMP('EV_250_Aggr.1KM_RefSB', dset_name[0], /FOLD_CASE) : BEGIN
                    ;Get band names
                    long_name = dset_info.long_name._data
                    tmp_band_names = dset_info.band_name._data
                    band_names = STRSPLIT(tmp_band_names, ',', /EXTRACT, COUNT = band_num)
                    r_bnames = long_name + ' : band' + band_names
                    
                    attr_name = 'VIR_Cal_Coeff'
                    attr_id = H5A_OPEN_NAME(file_id, attr_name)
                    attr_vir_coeff = H5A_READ(attr_id)
                    attr_vir_coeff = REFORM(attr_vir_coeff, 3, SIZE(attr_vir_coeff, /N_ELEMENTS) / 3)
                    
                    FOR i = 0, band_num -1 DO BEGIN
                        r_data[*, *, i] = (attr_vir_coeff[1, i] * r_data[*, *, i] + attr_vir_coeff[0, i]) / 100
                    ENDFOR
                    
                    ;Close all our identifiers so we don't leak resources.
                    H5A_CLOSE, attr_id
                    H5D_CLOSE, dset_id
                    H5F_CLOSE, file_id
                    
                    IF KEYWORD_SET(pos) THEN BEGIN
                        r_bnames = r_bnames[pos]
                        nb = SIZE(pos, /N_ELEMENTS)
                        RETURN, r_data[*, *, pos]
                    ENDIF ELSE BEGIN
                        RETURN ,r_data
                    ENDELSE
                END     ;End dset_name = 'EV_250_Aggr.1KM_RefSB'.
                
                STRCMP('EV_1KM_RefSB', dset_name[0], /FOLD_CASE) : BEGIN
                    ;Get band names
                    long_name = dset_info.long_name._data
                    tmp_band_names = dset_info.band_name._data
                    b_names_arr = STRSPLIT(tmp_band_names, '~', /EXTRACT)
                    b_names_val = FIX(b_names_arr)
                    band_num = b_names_val[1] - b_names_val[0] + 1
                    band_names_val = INDGEN(band_num) + b_names_val[0]
                    band_names = STRTRIM(STRING(band_names_val), 2)
                    r_bnames = long_name + ' : band' + band_names
                    
                    attr_name = 'VIR_Cal_Coeff'
                    attr_id = H5A_OPEN_NAME(file_id, attr_name)
                    attr_vir_coeff = H5A_READ(attr_id)
                    attr_vir_coeff = REFORM(attr_vir_coeff, 3, SIZE(attr_vir_coeff, /N_ELEMENTS) / 3)
                    
                    FOR i = 0, band_num -1 DO BEGIN
                        r_data[*, *, i] = (attr_vir_coeff[1, i + 4] * r_data[*, *, i] + attr_vir_coeff[0, i + 4]) / 100
                    ENDFOR
                    
                    ;Close all our identifiers so we don't leak resources.
                    H5A_CLOSE, attr_id
                    H5D_CLOSE, dset_id
                    H5F_CLOSE, file_id
                    
                    IF KEYWORD_SET(pos) THEN BEGIN
                        r_bnames = r_bnames[pos]
                        nb = SIZE(pos, /N_ELEMENTS)
                        RETURN, r_data[*, *, pos]
                    ENDIF ELSE BEGIN
                        RETURN ,r_data
                    ENDELSE               
                END     ;End dset_name = 'EV_1KM_RefSB'.
                
                STRCMP('EV_250_Aggr.1KM_Emissive', dset_name[0], /FOLD_CASE) : BEGIN
                    r_bnames = dset_info.long_name._data
                    slope = dset_info.slope._data
                    intercept = dset_info.intercept._data
                    r_data = (r_data / slope[0] + intercept[0]) / 100
                    
                    ;Close all our identifiers so we don't leak resources.
                    H5D_CLOSE, dset_id
                    H5F_CLOSE, file_id
                    
                    RETURN, r_data
                END     ;End dset_name = 'EV_250_Aggr.1KM_Emissive'.
                
                ELSE : BEGIN
                    r_bnames = dset_info.long_name._data
                    slope = dset_info.slope._data
                    intercept = dset_info.intercept._data
                    r_data = r_data * slope[0] + intercept[0]
                    
                    ;Close all our identifiers so we don't leak resources.
                    H5D_CLOSE, dset_id
                    H5F_CLOSE, file_id
                                        
                    RETURN, r_data 
                END     ;End else.
            ENDCASE     ;End case of dset_name.
        END     ;End data_level = 'L1'.
        
        STRCMP(data_level, 'L2', /FOLD_CASE) : BEGIN
            ;Read data according dset_name
            dset_id = H5D_OPEN(file_id, dset_name[0])
            r_data = FLOAT(H5D_READ(dset_id))
            
            ;Get band names
            long_name = dset_info.long_name._data
            tmp_band_names = dset_info.band_name._data
            band_names = STRSPLIT(tmp_band_names, ',', /EXTRACT, COUNT = band_num)
            r_bnames = STRARR(nb)
            IF STRCMP(long_name, '') THEN BEGIN
                long_name = dset_name[0]
            ENDIF
            
            IF STRCMP(tmp_band_names, '') THEN BEGIN
                r_bnames[*] = long_name
            ENDIF ELSE BEGIN
                r_bnames = long_name + ' : band' + band_names
            ENDELSE
            
            slope = dset_info.slope._data
            intercept = dset_info.intercept._data
            r_data = r_data * slope[0] + intercept[0]
            
            ;Close all our identifiers so we don't leak resources.
            H5D_CLOSE, dset_id
            H5F_CLOSE, file_id
                                        
            IF KEYWORD_SET(pos) THEN BEGIN
                r_bnames = r_bnames[pos]
                nb = SIZE(pos, /N_ELEMENTS)
                RETURN, r_data[*, *, pos]
            ENDIF ELSE BEGIN
                RETURN ,r_data
            ENDELSE    
        END     ;End data_level = 'L2'.
        
        ELSE : BEGIN
            PRINT, 'Can not read "' + data_level + '" level data.'
            
            ;Close all our identifiers so we don't leak resources.
            H5F_CLOSE, file_id
            
            RETURN, 0
        END     ;End else.
    ENDCASE     ;End case of data_level.
    PRINT, 'read_fy3_hdf5 : Job Done!'
END     ;End of program.
