;+
; ;**********************************************************
; Author: shaodonghang
; NAME:
; PARAMETERS:
;  1、NcPath
;  2、EnviPath
; Write by :
;    2016-4-23 
;;MODIFICATION HISTORY:
;;   Modified  :
;***********************************************************
;-
PRO  NCDATA2ENVI, NcDirectory = NcDirectory, ENVIDirectory = ENVIDirectory

  ;**************************************************************************
  ;
  ; 1) Initialize the Common variables
  ;
  ;**************************************************************************
  ;just for Test
  NcDirectory     = 'I:\snow_data\'
  ENVIDirectory   = 'I:\snow_data\output\'

  ;**************************************************************************
  ;
  ; 2) Get the files to be convert
  ;
  ;**************************************************************************

  NCFilePaths = FILE_SEARCH(NcDirectory,'*.nc', COUNT = nCount, /TEST_READ, /FULLY_QUALIFY_PATH)
  IF(nCount LE 0) THEN RETURN

  PRINT,'Procedure begins at ' + STRING(SYSTIME(/UTC))

  FOR i=0, nCount-1 DO BEGIN
    ;Open Nc File
    NID         = NCDF_OPEN(NCFilePaths[i], /nowrite )
    ;Inquire about this file; returns structure
    File_Info   = NCDF_INQUIRE(NID)
    ;define the dimensions of this file
    NS = 0L
    NL = 0L
    NB = 0L
    ;**************************************************************************
    ; 1) read dim info
    ;**************************************************************************
    FOR dimid=0, FILE_INFO.NDIMS -1 DO BEGIN
      NCDF_DIMINQ, NID, Dimid, Name, Size
      SWITCH Name OF
        "lon": BEGIN
          NS = Size
          BREAK
        END
        "lat": BEGIN
          NL = Size
          BREAK
        END
        "time": BEGIN
          NB = Size
          BREAK
        END
        ELSE: BEGIN
          PRINT, 'There is no Dim'
        END
      ENDSWITCH
    ENDFOR
    ;**************************************************************************
    ; 2) read data  info
    ;**************************************************************************
    ;define proj request
    StartX             = 0.0;
    StartY             = 0.0;
    EndX               = 0.0;
    EndY               = 0.0;
    GridSize           = 0.0;
    ndepth             = FLTARR(NB)
    FOR Varid=0, FILE_INFO.NVARS-1 DO BEGIN
      IsWRITE  = 1;
      ; inquire about the variable; returns structure
      VAR  =  NCDF_VARINQ( NID, Varid )
      ;read data
      dataID = NCDF_VARID(NID, VAR.NAME)
      NCDF_VARGET, NID, dataID, Data
      SWITCH VAR.NAME OF
        "lon": BEGIN
          StartX   = Data[0];
          nData    = N_ELEMENTS(Data)
          EndX     = Data(nData-1)
          IsWRITE  = 0
          BREAK
        END
        "lat": BEGIN
          StartY   = Data[0];
          nData    = N_ELEMENTS(Data)
          EndY     = Data(nData-1)
          IsWRITE  = 0
          BREAK
        END
        "time": BEGIN
          ndepth   = Data
          IsWRITE  = 0
          BREAK
        END
      ENDSWITCH
      ;**************************************************************************
      ;1) IF No project then Creat project
      ;**************************************************************************
      ; Projection
      ; GridSize = 0  illustrate  iMap is null
      IF (GridSize EQ 0) AND IsWRITE THEN BEGIN
        GridSize  = (ROUND(EndX)-ROUND(StartX)) / FLOAT(NS)
        ; start point
        iProj     = ENVI_PROJ_CREATE(/GEOGRAPHIC)
        ; Create the map information
        ps        = [GridSize, GridSize]
        mc        = [0D, 0D, StartX, EndY]
        Datum     = 'WGS-84'
        Units     = ENVI_TRANSLATE_PROJECTION_UNITS ('Degrees')
        iMap      = ENVI_MAP_INFO_CREATE(/GEOGRAPHIC,MC=MC,PS=PS,PROJ=iProj,UNITS=Units)
      ENDIF
      ;**************************************************************************
      ; 2) Creat Envi File
      ;**************************************************************************
      IF IsWRITE THEN BEGIN
        OutFilePath = ENVIDirectory + VAR.NAME+'.tif'
        OPENW, HData, OutFilePath, /GET_LUN
        WRITEU, HData,REVERSE(Data,2)
        FREE_LUN, HData
        DATA_TYPE = 4
        DataType  = VAR.DATATYPE
        SWITCH VAR.DATATYPE OF
          "BYTE": BEGIN
            DATA_TYPE    = 1
            BREAK
          END
          "CHAR": BEGIN
            DATA_TYPE    = 1
            BREAK
          END
          "INT": BEGIN
            DATA_TYPE    = 2
            BREAK
          END
          "LONG": BEGIN
            DATA_TYPE    = 3
            BREAK
          END
          "FLOAT": BEGIN
            DATA_TYPE    = 4
            BREAK
          END
          "DOUBLE": BEGIN
            DATA_TYPE    = 5
            BREAK
          END
        ENDSWITCH
        ; Edit the envi header file
        ENVI_SETUP_HEAD,FNAME=OutFilePath,NS=NS,NL=NL,NB=NB,INTERLEAVE=0,$
          DATA_TYPE=DATA_TYPE,OFFSET=0,MAP_INFO=iMap,BNAMES=[VAR.NAME],/WRITE,$
          /OPEN,R_FID=Data_FID
        ;**************************************************************************
        ; 3) read all attributes update Herder file
        ;**************************************************************************
        ;Set the header value
        ENVI_ASSIGN_HEADER_VALUE, FID=Data_FID, KEYWORD ='Author',  VALUE = "SDH"
        ENVI_ASSIGN_HEADER_VALUE, FID=Data_FID, KEYWORD ='Soil Depth',  VALUE = ndepth, PRECISION=5
        FOR VarAttID =0, VAR.NATTS -1 DO BEGIN
          AttName = NCDF_ATTNAME( NID, Varid, VarAttID )
          NCDF_ATTGET, NID, varid, AttName, AttValue
          ENVI_ASSIGN_HEADER_VALUE, FID=Data_FID, KEYWORD = AttName,  VALUE = STRING(AttValue)
        ENDFOR
        ;Write the values to the file header
        ENVI_WRITE_FILE_HEADER, Data_FID
        ;remove  file
        ENVI_FILE_MNG, ID=Data_FID, /REMOVE
      ENDIF
    ENDFOR
  ENDFOR
  PRINT, 'Procedure ends at ' + SYSTIME(/UTC)
END