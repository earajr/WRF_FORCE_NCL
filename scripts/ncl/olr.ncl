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
  olr = wrf_user_getvar(a,"OLR",-1)          ; qv
  ntimes = dimsizes(olr(:,0,0))

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

;==========resources for t2 plot
     dres@cnLevelSelectionMode  = "ExplicitLevels"
     dres@cnLevels              = fspan(160,280,11)
     dres@lbOrientation         = "Vertical"
     dres@pmLabelBarOrthogonalPosF = -0.02    ; move labelbar closer to plot
     cmap_olr              = read_colormap_file("BlAqGrYeOrReVi200")
     dres@cnFillOn              = True           ; turn on contour fill
     dres@cnFillPalette  = cmap_olr

;---Set map resources based on projection on WRF output file
     map_res = wrf_map_resources(a,map_res)
     map_res@mpFillOn                    = False
     map_res@mpOutlineOn                 = True
     map_res@mpDataBaseVersion           = "MediumRes"
     map_res@mpOutlineDrawOrder          = "PostDraw"
     map_res@mpPerimLineColor            = "Black"
     map_res@mpNationalLineColor         = "White"
     map_res@mpLimbLineColor             = "White"
     map_res@mpGridLineColor             = "White"
     map_res@mpGeophysicalLineColor      = "White"
     map_res@mpNationalLineThicknessF    = 3.0
     map_res@mpGeophysicalLineThicknessF = 3.0


; =========== loop over time

  do nt=0,ntimes-1

     wks = gsn_open_wks("png",dest+"olr_"+dom+"_"+times(nt))

     map_res@tiMainString                = times(nt)
     map_res@gsnLeftString = "TOA outgoing long-wave radiation (W m~S~-2~N~)"
     map_res@gsnLeftStringFontHeightF = 0.015
     map_res@gsnRightStringFontHeightF = 0.015


; ================creat map
     map = gsn_csm_map(wks,map_res)

;---Create the olr plot
    olrplot = gsn_csm_contour(wks,olr(nt,:,:),dres)

;---Overlay the t2 plot on the map
     overlay(map,olrplot)

;---Drawing the plots now
  
     draw(map)
;========frame creates new page
     frame(wks)

;==========end of pressure level loop

end do

end
