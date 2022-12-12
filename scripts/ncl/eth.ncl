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
  znu = a->ZNU                            ; eta values
  eth = wrf_user_getvar(a,"eth",-1)          ; RH
  ntimes = dimsizes(eth(:,0,0,0))
  p = wrf_user_getvar(a,"pressure",-1)     ; pressure

;============ list of pressure levels. First one is a "dummy"

;  plevs=(/  850., 700., 500., 300./) 
  nlevs         = dimsizes(plevs)

; =========== loop over time levels

  do nt=0,ntimes-1

; =========== loop over pressure levels

  do nx=0,nlevs-1
     wks = gsn_open_wks("png",dest+"eth_"+dom+"_"+times(nt)+"_"+plevs(nx))


;============interpolate onto pressure levels and convert winds to knots

     eth2=wrf_user_intrp3d(eth(nt,:,:,:),p(nt,:,:,:),"h",plevs(nx),0.,False)
     printMinMax(eth2,0)

     print("************************************")
     print("Plotting at level " + plevs(nx))

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
     map_res                    = res ; map

;==========resources for rh plot
     dres@cnLevelSelectionMode  = "ExplicitLevels"
     dres@cnLevels              = fspan(280.5,350.5,41)
     dres@lbOrientation         = "Vertical"
     dres@pmLabelBarOrthogonalPosF = -0.02    ; move labelbar closer to plot
     cmap_eth              = read_colormap_file("BkBlAqGrYeOrReViWh200")
     dres@cnFillOn              = True           ; turn on contour fill     
     dres@cnFillPalette  = cmap_eth                    
;
; Get RGBA values for WhViBlGrYeOrRe color map and 
; set first color to transparent (no color)
; this is for RH 


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
     res@mpOceanFillColor                = "steelblue"
     res@mpInlandWaterFillColor          = "steelblue"

     map_res@tiMainString                = times(nt)
     map_res@gsnLeftString = eth@description + " (" + eth@units + ")" 
     map_res@gsnLeftStringFontHeightF = 0.015
     map_res@gsnRightString = plevs(nx) + " hPa level"
     map_res@gsnRightStringFontHeightF = 0.015

     res@mpOceanFillColor                = "steelblue"
     res@mpInlandWaterFillColor          = "steelblue"




; ================creat map
     map = gsn_csm_map(wks,map_res)


;---Create the rh plot
     rh_plot = gsn_csm_contour(wks,eth2,dres)

;---Overlay the rh plot on the terrain plot
     overlay(map,rh_plot)

;---Drawing the plots now
  
     draw(map)
;========frame creates new page
     frame(wks)

;==========end of pressure level loop
end do
;==========end of time level loop
end do



end
