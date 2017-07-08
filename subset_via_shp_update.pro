;idl 批量裁剪代码
PRO Subset_via_shp_update

  COMPILE_OPT idl2

  ENVI,/restore_base_save_files

  envi_batch_init,LOG_FILE='batch.log'

  ;打开要裁剪的图像

  image_dir='C:\Users\lhy\Desktop\气象数据\' ;根据文件存放的目录进行相应修改

  image_files=file_search(image_dir,'*.tif',count=numfiles)  ;根据相应的文件格式修改过滤条件

    

  for i=0,numfiles-1 do begin

    image_file=image_files[i]

    print,image_file

    if strlen(image_file) eq 0 then return

   

    ENVI_OPEN_FILE, image_file, r_fid=fid, /no_interactive_query, /no_realize

    IF fid EQ -1 THEN  RETURN

    ENVI_FILE_QUERY, fid, file_type=file_type, nl=nl, ns=ns,dims=dims,nb=nb

   

    ;打开shape文件

    ;shapefile = DIALOG_PICKFILE(title='choose the SHP file:',filter='*.shp')

    shapefile=file_search(image_dir,'*.shp')

   

    if strlen(shapefile) eq 0 then return

    oshp = OBJ_NEW('IDLffshape',shapefile)

    oshp->Getproperty,n_entities=n_ent,Attribute_info=attr_info,$

      n_attributes=n_attr,Entity_type=ent_type

     

    roi_shp = LONARR(n_ent)

    FOR ishp = 0,n_ent-1 DO BEGIN

      entitie = oshp->Getentity(ishp)

     

      IF entitie.shape_type EQ 5 THEN BEGIN

        record = *(entitie.vertices)

       

        ;转换文件坐标

        ENVI_CONVERT_FILE_COORDINATES,fid,xmap,ymap,record[0,*],record[1,*]

        ;创建ROI

        roi_shp[ishp] = ENVI_CREATE_ROI(ns=ns,nl=nl)

        ENVI_DEFINE_ROI,roi_shp[ishp],/polygon,xpts=REFORM(xmap),ypts=REFORM(ymap)

        ;记录X,Y的区间，裁剪用

        IF ishp EQ 0 THEN BEGIN

          xMin = ROUND(MIN(xMap,max = xMax))

          yMin = ROUND(MIN(yMap,max = yMax))

         

        ENDIF ELSE BEGIN

          xMin = xMin < ROUND(MIN(xMap))

          xMax = xMax > ROUND(MAX(xMap))

          yMin = yMin < ROUND(MIN(yMap))

          yMax = yMax > ROUND(MAX(yMap))

        ENDELSE

      ENDIF

     

      oshp->Destroyentity,entitie

    ENDFOR;ishp

    xMin = xMin >0

    xMax = xMax < ns-1

    yMin = yMin >0

    yMax = yMax < nl-1

   

   

    ;判断输出文件路径，在原文件名基础上输出

    outfiledir=file_dirname(image_file,/MARK_DIRECTORY)

    out_name = outfiledir +'\' +file_baseName(image_file,'.tif')+'_roi.img

   

    out_dims = [-1,xMin,xMax,yMin,yMax]

    pos = INDGEN(nb)

   

    ENVI_DOIT,'ENVI_SUBSET_VIA_ROI_DOIT',background=0,fid=fid,dims=out_dims,out_name=out_name,$

      ns = ns, nl = nl,pos=pos,roi_ids=roi_shp

     

    endfor 

     

    tmp = DIALOG_MESSAGE('裁切结束!',/info)

    envi_batch_exit

  END