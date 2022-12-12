
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Plot SkewT's at a number of locations
;   In this example all interested locations are calculated in one step
;   before the plots are drawn.
;   First checks to see which locations are inside the model domain.
;   Also read in all the data at once

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get some dimension info - so we can check to make sure
; the sounding locations are inside the model domain
  mdims = getfilevardimsizes(a,"P")
  nd = dimsizes(mdims)
  dimX = mdims(nd-1)
  dimY = mdims(nd-2)

; List of stations, and their lat/lon locations we are interested in

; ids=(/"Reykjavik"/)
;
; lats = (/64.141/)
;
; lons = (/-21.883/)

; Get ij points in model domain for all above locations
; loc(1,:) is south-north (y) and loc(0,:) is west-east (x)
  locs = wrf_user_ll_to_ij(a, stringtofloat(lons), stringtofloat(lats), True)
  mx = locs(0) - 1
  ny = locs(1) - 1

; Remove the data points outside our model domain

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need        
    tc  = wrf_user_getvar(a,"tc",-1)         ; T in C
    td  = wrf_user_getvar(a,"td",-1)         ; dew point temperature
    p   = wrf_user_getvar(a, "pressure",-1)  ; grid point pressure
    z   = wrf_user_getvar(a, "z",-1)         ; grid point height
    uvm = wrf_user_getvar(a,"uvmet",-1)      ; umet and vmet averaged to mass points
					     ; This is a 4D array where
					     ; uvm(0,:,:,:) is umet, and
					     ; uvm(1,:,:,:) is vmet, and
					     ; This function rotate winds to earth coord.
  ; extract u and v from uvm array, and turn wind into kts
    u   = uvm(0,:,:,:,:)*1.94386 
    v   = uvm(1,:,:,:,:)*1.94386
    w = wrf_user_getvar(a,"wa",-1)
    rh= wrf_user_getvar(a,"rh",-1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; What times and how many time steps are in the data set?
  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  do it = 0,ntimes-1        ; TIME LOOP

    print("Working on time: " + times(it) )

  Meta = [/ids+" sounding "+times(it)/]
  varHead = [/"     P      HGT     T     TDEW       U      V       W     RH"/]
  untHead = [/"    mb       m      C       C      kts    kts      m/s     &"/]


       p_at_loc=p(it,0:49,ny,mx)
       z_at_loc=z(it,0:49,ny,mx)
       tc_at_loc=tc(it,0:49,ny,mx)
       td_at_loc=td(it,0:49,ny,mx)
       u_at_loc=u(it,0:49,ny,mx)
       v_at_loc=v(it,0:49,ny,mx)
       w_at_loc=w(it,0:49,ny,mx)
       rh_at_loc=rh(it,0:49,ny,mx)

       varList = [/p_at_loc,z_at_loc,tc_at_loc,td_at_loc,u_at_loc,v_at_loc,w_at_loc,rh_at_loc/]
	         txtName = dest+ids+"_"+dom+"_"+times(it)+".dat"    
		 txtPath = txtName
	         write_table(txtPath, "w", Meta, "%s")   ; "w" => create or overwrite
	         write_table(txtPath, "a", varHead, "%s")   ; "a" => append
	         write_table(txtPath, "a", untHead, "%s")   ; "a" => append
	         write_table(txtPath, "a", varList, "%7.0f%7.0f%7.1f%7.1f%7.1f%7.1f%7.2f%7.1f")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end do        ; END OF TIME LOOP

end
