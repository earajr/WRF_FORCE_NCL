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

  hgt = a->HGT(0,:,:)                     ; terrain, 0 is the first time step
  lat = a->XLAT(0,:,:)                    ; latitude
  lon = a->XLONG(0,:,:)                   ; longitude
  t2 = wrf_user_getvar(a,"T2",-1)          ; qv
  ntimes = dimsizes(t2(:,0,0))
  td2 = wrf_user_getvar(a,"td2",-1)          ; qv
  u10 = wrf_user_getvar(a,"U10",-1)          ; qv
  v10 = wrf_user_getvar(a,"V10",-1)          ; qv
  u10 = u10*1.94386     ; kts
  v10 = v10*1.94386     ; kts
  t2 = t2-273.15                          ; to deg C
  printVarSummary(t2)
  printMinMax(t2,0)
  printMinMax(td2,0)
  tdiff=t2-td2
  

;============interpolate onto pressure levels and convert winds to knots

     print("************************************")

;---Set some common resources
     res                       = True
     res@tfDoNDCOverlay        = True           ; IMPORTANT! for plots to look OK using WRF
     res@gsnDraw               = False          ; turn off draw
     res@gsnFrame              = False          ; turn off frame i.e. don't do new page until told
   ;  res@cnFillOn              = True           ; turn on contour fill
     res@cnLinesOn             = False          ; turn off contour lines
     res@cnLineLabelsOn        = False          ; turn off contour line labels
     res@gsnLeftString         = ""             ; turn off subtitles
     res@gsnRightString        = ""
     res@gsnCenterString       = ""
   ;  res@mpOceanFillColor                = "steelblue"
   ;  res@mpInlandWaterFillColor          = "steelblue"

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

;---Copy common resources to resource lists for terrain and qvapor plots
     dres                       = res ; qvapor
     map_res                    = res ; map
     vres                    = res

;==========resources for t2 plot
     dres@cnLevelSelectionMode  = "ExplicitLevels"
     dres@cnLevels              = fspan(0.0,4.0,21)
     dres@lbOrientation         = "Vertical"
     dres@pmLabelBarOrthogonalPosF = -0.02    ; move labelbar closer to plot
     cmap_t2              = read_colormap_file("WhiteBlueGreenYellowRed")
     dres@cnFillOn              = True           ; turn on contour fill
     dres@cnFillPalette  = cmap_t2

;==========resources for vector plot
     vres@vcRefMagnitudeF         = 8.                ; make vectors larger
     vres@vcRefLengthF            = 0.030              ; ref vec length
     vres@vcGlyphStyle            = "WindBarb"         ; select wind barbs
     vres@vcMinDistanceF          = 0.020              ; thin out windbarbs
     vres@vcMinDistanceF          = 0.03
     vres@vcRefLengthF            = 0.03
     vres@vcMinFracLengthF        = 0.2
     vres@vcLineArrowThicknessF   = 3.0
     vres@vcGlyphStyle            = "WindBarb"
     vres@vcRefAnnoOn             = False
     vres@tiMainString            = "" ; title

;---Set map resources based on projection on WRF output file
     map_res = wrf_map_resources(a,map_res)
     map_res@mpFillOn                    = False
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

; =========== loop over time

  do nt=0,ntimes-1
     wks = gsn_open_wks("png",dest+"dpd_"+dom+"_"+times(nt))

     map_res@tiMainString                = times(nt)
     map_res@gsnLeftString = "2m dew point depression (~S~o~N~C)~C~"+\
     "10m winds (knots)" 
     map_res@gsnLeftStringFontHeightF = 0.015


; ================creat map
     map = gsn_csm_map(wks,map_res)

;---Create the vector plot
    vec_plot=gsn_csm_vector(wks,u10(nt,:,:),v10(nt,:,:),vres)

;---Create the diff plot
     tdiffplot = gsn_csm_contour(wks,tdiff(nt,:,:),dres)

;---Overlay the t2 plot on the map
     overlay(map,tdiffplot)

;---Overlay the vector plot on the map
     overlay(map,vec_plot)

;---Drawing the plots now
  
     draw(map)
;========frame creates new page
     frame(wks)

;==========end of time level loop

end do

end
