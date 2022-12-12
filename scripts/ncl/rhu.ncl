;----------------------------------------------------------------------
; 
;----------------------------------------------------------------------
;
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;----------------------------------------------------------------------

begin


;=============== turn off warning messages! uncomment this if things are going wonky
err = NhlGetErrorObjectId()
setvalues err
  "errLevel" : "Fatal"          ; only report Fatal errors
end setvalues


;========= Open file 
;  a = addfile("wrfout_d01_2022-10-15_18:00:00.nc","r")
  times = wrf_user_list_times(a)           ; time as character strings                       


;========= select PNG file format. 


;========Read variables 

  print("Reading")
  hgt = a->HGT(0,:,:)                     ; terrain, 0 is the first time step
  lat = a->XLAT(0,:,:)                    ; latitude
  lon = a->XLONG(0,:,:)                   ; longitude
  znu = a->ZNU                            ; eta values
  rh = wrf_user_getvar(a,"rh",-1)          ; RH
  ntimes = dimsizes(rh(:,0,0,0))
  p = wrf_user_getvar(a,"pressure",-1)     ; pressure
  u  = wrf_user_getvar(a,"ua",-1)          ; u averaged to mass points
  v  = wrf_user_getvar(a,"va",-1)          ; v averaged to mass points
  print("Finished reading")

;============ list of pressure levels. First one is a "dummy"

;  plevs=(/  850., 700., 500., 300./) 
  nlevs         = dimsizes(plevs)

; =========== loop over time

  do nt=0,ntimes-1
; =========== loop over pressure levels

  do nx=0,nlevs-1
     wks = gsn_open_wks("png",dest+"rhu_"+dom+"_"+times(nt)+"_"+plevs(nx))

;============interpolate onto pressure levels and convert winds to knots

     print("Interpolating")
     rh2=wrf_user_intrp3d(rh(nt,:,:,:),p(nt,:,:,:),"h",plevs(nx),0.,False)
     u2  = wrf_user_intrp3d( u(nt,:,:,:),p(nt,:,:,:),"h",plevs(nx),0.,False)
     v2  = wrf_user_intrp3d( v(nt,:,:,:),p(nt,:,:,:),"h",plevs(nx),0.,False)
     u2 = u2*1.94386     ; kts
     v2 = v2*1.94386     ; kts

     print("************************************")
     print("Plotting at level " + plevs(nx)+times(nt))

;---Set some common resources
     res                       = True
     res@tfDoNDCOverlay        = True           ; IMPORTANT! for plots to look OK using WRF
     res@gsnDraw               = False          ; turn off draw
     res@gsnFrame              = False          ; turn off frame i.e. don't do new page until told
     res@cnFillOn              = True           ; turn on contour fill
     res@cnLinesOn             = False          ; turn off contour lines
     res@cnLineLabelsOn        = False          ; turn off contour line labels
     res@gsnLeftString         = ""             ; turn off subtitles
     res@gsnRightString        = ""
     res@gsnCenterString       = ""
     res@mpOceanFillColor                = "steelblue"
     res@mpInlandWaterFillColor          = "steelblue"

;---labelbar stuff
     res@lbLabelFontHeightF       = 0.015

;
; Setting these four resources is necessary to keep
; the plot from running off the frame.
;
; The plot size will be slightly adjusted internally to
; keep the aspect ratio of the map.
;
     res@vpXF                  = 0.08
     res@vpYF                  = 0.88
     res@vpWidthF              = 0.80
     res@vpHeightF             = 0.60

;---Necessary to put data on map correctly.
     res@sfXArray              = lon
     res@sfYArray              = lat
     res@gsnAddCyclic          = False

;---Copy common resources to resource lists for terrain and rh plots
     dres                       = res ; rh
     vres                       = res ; vectors
     map_res                    = res ; map

;==========resources for rh plot
     dres@cnLevelSelectionMode  = "ExplicitLevels"
     dres@cnLevels              = ispan(40,100,5)
     dres@lbOrientation         = "Vertical"
     dres@pmLabelBarOrthogonalPosF = -0.02    ; move labelbar closer to plot
;
; Get RGBA values for WhViBlGrYeOrRe color map and 
; set first color to transparent (no color)
; this is for RH 

     cmap_rh              = read_colormap_file("GMT_gray")
;     cmap_rh              = read_colormap_file("WhiteGreen")
     cmap_rh(0,3)         = 0.0    ; first color fully transparent
     dres@cnFillPalette  = cmap_rh
     dres@cnFillOpacityF = 0.9


;==========resources for vector plot
   ;  vres@vcRefMagnitudeF         = 10.                ; make vectors larger
   ;  vres@vcRefLengthF            = 0.06              ; ref vec length
   ;  vres@vcGlyphStyle            = "WindBarb"         ; select wind barbs
   ;  vres@vcMinDistanceF          = 0.020              ; thin out windbarbs
   ;  vres@vcMinDistanceF          = 0.020
   ;  vres@vcRefLengthF            = 0.020
   ;  vres@vcMinFracLengthF        = 0.2
   ;  vres@vcLineArrowThicknessF   = 3.0
   ;  vres@vcGlyphStyle            = "WindBarb"
   ;  vres@vcRefAnnoOn             = False
   ;  vres@tiMainString            = "" ; title

  vres@vcMinDistanceF   = 0.04
  vres@vcRefLengthF     = 0.04  
  vres@vcMinFracLengthF = 0.4
  vres@vcGlyphStyle     = "WindBarb"
  vres@vcRefAnnoOn      = False
  vres@vcLineArrowThicknessF   = 3.0

;---Set map resources based on projection on WRF output file
     map_res = wrf_map_resources(a,map_res)
     map_res@mpFillOn                    = True
     map_res@mpOutlineOn                 = True
     map_res@mpDataBaseVersion           = "MediumRes"
     map_res@mpOutlineDrawOrder          = "PostDraw"
     map_res@mpPerimLineColor            = "Black"
     map_res@mpNationalLineColor         = "Black"
     map_res@mpLimbLineColor             = "Black"
     map_res@mpGridLineColor             = "Black"
     map_res@mpGeophysicalLineColor      = "Black"
     map_res@mpNationalLineThicknessF    = 3.0
     map_res@mpGeophysicalLineThicknessF = 3.0
     map_res@mpLandFillColor             = "tan"

     map_res@tiMainString                = times(nt)
     map_res@gsnLeftString = rh@description + " (" + rh@units + ")~C~" + \
                          "Wind (knots)"
     map_res@gsnLeftStringFontHeightF = 0.015
     map_res@gsnRightString = plevs(nx) + " hPa level"
     map_res@gsnRightStringFontHeightF = 0.015

     res@mpOceanFillColor                = "steelblue"
     res@mpInlandWaterFillColor          = "steelblue"



; ================creat map
     map = gsn_csm_map(wks,map_res)


;---Create the rh plot
     rh_plot = gsn_csm_contour(wks,rh2,dres)

;---Overlay the rh plot on the terrain plot
     overlay(map,rh_plot)

;---Create the vector plot
    vec_plot=gsn_csm_vector(wks,u2,v2,vres)
;---Overlay the vector plot on the map plot
    overlay(map,vec_plot)

;---Drawing the plots now
  
     draw(map)
;========frame creates new page
     frame(wks)

;==========end of pressure level loop
end do

;==========end of time loop
end do


end
