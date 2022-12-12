
; Example series of plotting meteograms with WRF ARW model data
; First let's just get and plot t2 at a point
; Add some info to the plot
; Add slp to the plot

; CURRENTLY THIS WILL NOT WORK AS MULTIPLE FILES ARE NEEDED TO BE READ IN INSTEAD OF A SINGLE FILE.

;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***********************************************
begin
;***********************************************

;a = addfile("./wrfout_d01_2022-10-15_18:00:00.nc","r")

  t2    = wrf_user_getvar(a,"T2",-1)    ; get t2 for all times
  t2 = t2-273.15 ; convert to degrees C
  slp   = wrf_user_getvar(a,"slp",-1)   ; get slp for all times
  u10 = wrf_user_getvar(a,"U10",-1)
  v10 = wrf_user_getvar(a,"V10",-1)
  u10 = u10*1.94386   ;u wind speed in knots
  v10 = v10*1.94386   ;v wind speed in knots
  u10 = u10 *0.5144   ;u wind speed in m/s
  v10 = v10 *0.5144   ;v wind speed in m/s
  
  speed=sqrt(u10*u10 + v10*v10)
  loc = wrf_user_ll_to_ij(a,  -17.961606, 63.773607, True) ; Efri-Vik
  mx = loc(0) - 1
  ny = loc(1) - 1
  print("mx"+mx+ny)


  t2_point  = t2(:,ny,mx)               ; extract a time series at a point
  slp_point  = slp(:,ny,mx)  
  u_point  = u10(:,ny,mx)
  v_point  = v10(:,ny,mx)
  u_point_int=floattointeger(u_point)
  v_point_int=floattointeger(v_point)
  speed_point  = speed(:,ny,mx)  
  dir_point  = wind_direction(u_point_int,v_point_int,0)
;  print(sprintf("%7.2f",u_point))
;  print(sprintf("%7.2f",v_point))
  print(sprintf("%7.2f",u_point_int))
  print(sprintf("%7.2f",v_point_int))
  print(sprintf("%7.2f",dir_point))

  taus = (/0., 1., 2., 3., 4., 5., 6., 7., 8., 9., 10., 11., 12., 13., 14., 15., 16., 17., 18., 19., 20., 21., 22., 23., 24., 25., 26., 27., 28., 29., 30., 31., 32., 33., 34., 35., 36., 37., 38., 39., 40., 41., 42., 43., 44., 45., 46., 47., 48., 49., 50., 51., 52., 53., 54., 55., 56., 57., 58., 59., 60., 61., 62., 63., 64., 65., 66., 67., 68., 69., 70., 71.,  72./)       ; create a time reference

; get time information and strip out the day and hour
  times_in_file = a->Times
  print("times"+times_in_file)
  dims = dimsizes(times_in_file)
  times = new(dims(0),string)
  do i=0,dims(0)-1
    times(i) = chartostring(times_in_file(i,8:12))
  end do
  print("times"+times)

  wks = gsn_open_wks("png","met_d02_efri-vik")    ; open a workstation


;-----------------------------------------------------------------------

  res = True                            ; Set basic resources both will use
  res@vpXF            = 0.15            ; The left side of the box location
  res@vpWidthF        = 0.80            ; The Width of the plot box
  res@vpHeightF       = 0.1            ; The height of the plot box
  res@tmXBMode       = "Explicit"       ; Define own tick mark labels.
  res@tmXBValues     = taus             ; location of explicit labels
  res@tmXBLabels     = times            ; labels are the locations
  res@tmXTOn         = False            ; turn off the top tick marks
  res@xyLineThicknesses = 5             ; increase line thickness
  res@gsnDraw         = False           ; Don't draw individual plot.
  res@gsnFrame        = False           ; Don't advance frame.
  res@tmXBLabelAngleF      = 90.
  

  slp_res = res
  slp_res@vpYF            = 0.90        ; The top side of the plot box loc
  slp_res@xyLineColor    =  "red"       ; set line color
 slp_res@tiMainString      = "Efri-Vik Iceland" ; title
slp_res@tmXTOn        =True
;slp_res@tmXBOn        =False
slp_res@tmXBLabelDeltaF = 1.5
slp_res@tmYLValues = (/1000,925,850,700,600,500,400,300,250/)
  slp_res@tiYAxisString  = "SLP (hPa)"
slp_res@tmLabelAutoStride=True



  t2_res = res
  t2_res@vpYF            = 0.70         ; The top side of the plot box loc
  t2_res@xyLineColor    =  "blue"       ; set line color
t2_res@tmXBLabelDeltaF = 1.5
  t2_res@tiYAxisString  = "2m temp (deg. C)"
t2_res@tmLabelAutoStride=True

  speed_res = res
  speed_res@vpYF            = 0.50         ; The top side of the plot box loc
  speed_res@xyLineColor    =  "green"       ; set line color
  speed_res@tiYAxisString  = "10m speed (m/s)"
speed_res@tmXBLabelDeltaF = 1.5
speed_res@tmLabelAutoStride=True

  dir_res = res
  dir_res@vpYF            = 0.30         ; The top side of the plot box loc
  dir_res@xyLineColor    =  "black"       ; set line color
  dir_res@tiYAxisString  = "10m wind dirn"
dir_res@tmXBLabelDeltaF = 1.5
dir_res@tmLabelAutoStride=True

  slp_plot  = gsn_csm_xy(wks,taus,slp_point,slp_res)
  t2_plot  = gsn_csm_xy(wks,taus,t2_point,t2_res)
  speed_plot  = gsn_csm_xy(wks,taus,speed_point,speed_res)
  dir_plot  = gsn_csm_xy(wks,taus,dir_point,dir_res)
  draw(slp_plot) 
  draw(t2_plot) 
  draw(speed_plot) 
  draw(dir_plot) 

  frame(wks)                            ; now frame the plot   

;-----------------------------------------------------------------------

end


