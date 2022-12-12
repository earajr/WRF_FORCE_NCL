
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Plot SkewT's at a number of locations
;   In this example all interested locations are calculated in one step
;   before the plots are drawn.
;   First checks to see which locations are inside the model domain.
;   Also read in all the data at once

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
;  a = addfile("./wrfout_d01_2022-10-15_18:00:00","r")


; We generate plots, but what kind do we prefer?
  type = "png"
; type = "pdf"
; type = "ps"
; type = "ncgm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get some dimension info - so we can check to make sure
; the sounding locations are inside the model domain
  mdims = getfilevardimsizes(a,"P")
  nd = dimsizes(mdims)
  dimX = mdims(nd-1)
  dimY = mdims(nd-2)

; List of stations, and their lat/lon locations we are interested in

;  ids=(/"Heathrow", "Dublin", "Amsterdam"/) 
;  ids=(/"BelfastIntl	",\
;"StAngelo 	",\
;"BelfastCity 	",\
;"CityofDerry 	",\
;"Birmingham 	",\
;"Coventry 	",\
;"Leicester 	",\
;"Kemble 	",\
;"Turweston 	",\
;"Manchester 	",\
;"Chivenor 	",\
;"St Mawgan 	",\
;"Lyneham 	",\
;"BoscombeDown 	",\
;"Culdrose 	",\
;"StAthan 	",\
;"Yeovilton 	",\
;"Haverfordwest 	",\
;"Cardiff 	",\
;"Swansea 	",\
;"Bristol 	",\
;"Liverpool 	",\
;"Luton 		",\
;"Plymouth 	",\
;"Bournemouth 	",\
;"Southampton 	",\
;"Lasham 	",\
;"Alderney 	",\
;"Guernsey 	",\
;"Jersey 	",\
;"Shoreham 	",\
;"Biggin Hill 	",\
;"Gatwick 	",\
;"City 		",\
;"Farnborough 	",\
;"Chalgrove 	",\
;"Blackbushe 	",\
;"Heathrow 	",\
;"Southend 	",\
;"Manston 	",\
;"Brough 	",\
;"Carlisle 	",\
;"Gamston 	",\
;"Blackpool 	",\
;"Humberside 	",\
;"WalneyIsland 	",\
;"LeedsBradford  ",\
;"Warton 	",\
;"Hawarden 	",\
;"IsleOfMan 	",\
;"Newcastle     	",\
;"DurhamTValley  ",\
;"NottmEMids     ",\
;"Llanbedr 	",\
;"Ternhill 	",\
;"Shawbury 	",\
;"Woodvale 	",\
;"Kirkwall 	",\
;"Sumburgh 	",\
;"Wick 		",\
;"Dyce 		",\
;"Inverness 	",\
;"Glasgow 	",\
;"Edinburgh 	",\
;"Prestwick 	",\
;"Benbecula 	",\
;"Scatsta 	",\
;"Dundee 	",\
;"Stornoway 	",\
;"Leuchars 	",\
;"Lossiemouth 	",\
;"Cambridge 	",\
;"Conington 	",\
;"Norwich 	",\
;"Stansted 	",\
;"NorthWeald 	",\
;"SheffieldCity  ",\
;"Cranfield 	",\
;"Exeter 	",\
;"BristolFilton  ",\
;"Kidlington 	",\
;"Benson 	",\
;"Lakenheath 	",\
;"Mildenhall 	",\
;"Wattisham 	",\
;"Fairford 	",\
;"BrizeNorton 	",\
;"Odiham 	",\
;"Cosford 	",\
;"Northolt 	",\
;"Coningsby 	",\
;"Dishforth 	",\
;"Leeming 	",\
;"ChurchFenton 	",\
;"Honington 	",\
;"Cottesmore 	",\
;"Scampton 	",\
;"Wittering 	",\
;"LintonOnOuse   ",\
;"Waddington 	",\
;"Topcliffe 	",\
;"Cranwell 	",\
;"BarkstonHeath  ",\
;"Marham 	"/)
;
;  stat = (/ \
;"Belfast Intl	EGAA",\
;"St Angelo 	EGAB",\
;"Belfast City 	EGAC",\
;"City of Derry 	EGAE",\
;"Birmingham 	EGBB",\
;"Coventry 	EGBE",\
;"Leicester 	EGBG",\
;"Kemble 	EGBP",\
;"Turweston 	EGBT",\
;"Manchester 	EGCC",\
;"Chivenor 	EGDC",\
;"St Mawgan 	EGDG",\
;"Lyneham 	EGDL",\
;"Boscombe Down 	EGDM",\
;"Culdrose 	EGDR",\
;"St Athan 	EGDX",\
;"Yeovilton 	EGDY",\
;"Haverfordwest 	EGFE",\
;"Cardiff 	EGFF",\
;"Swansea 	EGFH",\
;"Bristol 	EGGD",\
;"Liverpool 	EGGP",\
;"Luton 		EGGW",\
;"Plymouth 	EGHD",\
;"Bournemouth 	EGHH",\
;"Southampton 	EGHI",\
;"Lasham 	EGHL",\
;"Alderney 	EGJA",\
;"Guernsey 	EGJB",\
;"Jersey 	EGJJ",\
;"Shoreham 	EGKA",\
;"Biggin Hill 	EGKB",\
;"Gatwick 	EGKK",\
;"City 		EGLC",\
;"Farnborough 	EGLF",\
;"Chalgrove 	EGLJ",\
;"Blackbushe 	EGLK",\
;"Heathrow 	EGLL",\
;"Southend 	EGMC",\
;"Manston 	EGMH",\
;"Brough 	EGNB",\
;"Carlisle 	EGNC",\
;"Gamston 	EGNE",\
;"Blackpool 	EGNH",\
;"Humberside 	EGNJ",\
;"Walney Island 	EGNL",\
;"Leeds Bradford EGNM",\
;"Warton 	EGNO",\
;"Hawarden 	EGNR",\
;"Isle Of Man 	EGNS",\
;"Newcastle 	EGNT",\
;"Durham T.V.    EGNV",\
;"Nottm E. M.    EGNX",\
;"Llanbedr 	EGOD",\
;"Ternhill 	EGOE",\
;"Shawbury 	EGOS",\
;"Woodvale 	EGOW",\
;"Kirkwall 	EGPA",\
;"Sumburgh 	EGPB",\
;"Wick 		EGPC",\
;"Dyce 		EGPD",\
;"Inverness 	EGPE",\
;"Glasgow 	EGPF",\
;"Edinburgh 	EGPH",\
;"Prestwick 	EGPK",\
;"Benbecula 	EGPL",\
;"Scatsta 	EGPM",\
;"Dundee 	EGPN",\
;"Stornoway 	EGPO",\
;"Leuchars 	EGQL",\
;"Lossiemouth 	EGQS",\
;"Cambridge 	EGSC",\
;"Conington 	EGSF",\
;"Norwich 	EGSH",\
;"Stansted 	EGSS",\
;"North Weald 	EGSX",\
;"Sheffield City EGSY",\
;"Cranfield 	EGTC",\
;"Exeter 	EGTE",\
;"Bristol Filton EGTG",\
;"Kidlington 	EGTK",\
;"Benson 	EGUB",\
;"Lakenheath 	EGUL",\
;"Mildenhall 	EGUN",\
;"Wattisham 	EGUW",\
;"Fairford 	EGVA",\
;"Brize Norton 	EGVN",\
;"Odiham 	EGVO",\
;"Cosford 	EGWC",\
;"Northolt 	EGWU",\
;"Coningsby 	EGXC",\
;"Dishforth 	EGXD",\
;"Leeming 	EGXE",\
;"Church Fenton 	EGXG",\
;"Honington 	EGXH",\
;"Cottesmore 	EGXJ",\
;"Scampton 	EGXP",\
;"Wittering 	EGXT",\
;"Linton On Ouse EGXU",\
;"Waddington 	EGXW",\
;"Topcliffe 	EGXZ",\
;"Cranwell 	EGYD",\
;"Barkston Heath EGYE",\
;"Marham 	EGYM"\
;             /)
;
;  lats = (/  \
;54.6575	 ,\
;54.398889,\
;54.618056,\
;55.042778,\
;52.453856,\
;52.369722,\
;52.607778,\
;51.668056,\
;52.040833,\
;53.353744,\
;51.087167,\
;50.440558,\
;51.505144,\
;51.152189,\
;50.086092,\
;51.404811,\
;51.009358,\
;51.833056,\
;51.396667,\
;51.605333,\
;51.382669,\
;53.333611,\
;51.874722,\
;50.422778,\
;50.78	 ,\
;50.950261,\
;51.187167,\
;49.706111,\
;49.434956,\
;49.207947,\
;50.835556,\
;51.330833,\
;51.148056,\
;51.505278,\
;51.275833,\
;51.676111,\
;51.323889,\
;51.4775	 ,\
;51.571389,\
;51.342222,\
;53.719667,\
;54.9375	 ,\
;53.280556,\
;53.771667,\
;53.574444,\
;54.131167,\
;53.865897,\
;53.745097,\
;53.178056,\
;54.083333,\
;55.0375	 ,\
;54.509189,\
;52.831111,\
;52.811744,\
;52.871164,\
;52.798169,\
;53.581575,\
;58.957778,\
;59.878889,\
;58.458889,\
;57.201944,\
;57.5425	 ,\
;55.871944,\
;55.95	 ,\
;55.509444,\
;57.481111,\
;60.432778,\
;56.452499,\
;58.215556,\
;56.372889,\
;57.705214,\
;52.205	 ,\
;52.468056,\
;52.675833,\
;51.885	 ,\
;51.721667,\
;53.394256,\
;52.072222,\
;50.734444,\
;51.519444,\
;51.836944,\
;51.616389,\
;52.409333,\
;52.361933,\
;52.127283,\
;51.682167,\
;51.749964,\
;51.234139,\
;52.640028,\
;51.553	 ,\
;53.093014,\
;54.137186,\
;54.292383,\
;53.834333,\
;52.342611,\
;52.735711,\
;53.307778,\
;52.612558,\
;54.048911,\
;53.166167,\
;54.205522,\
;53.03035 ,\
;52.962225,\
;52.648353\
;              /)
;
;  lons = (/  \
;-6.215833,\
;-7.651667,\
;-5.8725	 ,\
;-7.161111,\
;-1.748028,\
;-1.479722,\
;-1.031944,\
;-2.056944,\
;-1.095556,\
;-2.27495 ,\
;-4.150339,\
;-4.995408,\
;-1.993428,\
;-1.747414,\
;-5.255711,\
;-3.43575 ,\
;-2.638819,\
;-4.961111,\
;-3.343333,\
;-4.067833,\
;-2.719089,\
;-2.849722,\
;-0.368333,\
;-4.105833,\
;-1.8425	 ,\
;-1.356803,\
;-1.0335	 ,\
;-2.214722,\
;-2.601969,\
;-2.195508,\
;-0.297222,\
;0.0325	 ,\
;-0.190278,\
;0.055278 ,\
;-0.776333,\
;-1.080833,\
;-0.8475	 ,\
;-0.461389,\
;0.695556 ,\
;1.346111 ,\
;-0.566333,\
;-2.809167,\
;-0.951389,\
;-3.028611,\
;-0.350833,\
;-3.263667,\
;-1.660569,\
;-2.883061,\
;-2.977778,\
;-4.623889,\
;-1.691667,\
;-1.429406,\
;-1.328056,\
;-4.123575,\
;-2.533561,\
;-2.668042,\
;-3.055522,\
;-2.905	 ,\
;-1.295556,\
;-3.093056,\
;-2.197778,\
;-4.0475	 ,\
;-4.433056,\
;-3.3725	 ,\
;-4.586667,\
;-7.362778,\
;-1.296111,\
;-3.025833,\
;-6.331111,\
;-2.868444,\
;-3.339169,\
;0.175	 ,\
;-0.251111,\
;1.282778 ,\
;0.235	,\
;0.154167 ,\
;-1.388486,\
;-0.616667,\
;-3.413889,\
;-2.590833,\
;-1.32	,\
;-1.095833,\
;0.561	,\
;0.486406 ,\
;0.956264 ,\
;-1.790028,\
;-1.583617,\
;-0.942825,\
;-2.305578,\
;-0.418167,\
;-0.166014,\
;-1.420253,\
;-1.5354	,\
;-1.1955	,\
;0.772939 ,\
;-0.648769,\
;-0.550833,\
;-0.476453,\
;-1.252747,\
;-0.523811,\
;-1.382094,\
;-0.483242,\
;-0.561625,\
;0.550692\
;              /)

; Get ij points in model domain for all above locations
; loc(1,:) is south-north (y) and loc(0,:) is west-east (x)

  locs = wrf_user_ll_to_ij(a, stringtofloat(lons), stringtofloat(lats), True)

; Remove the data points outside our model domain
;  num_st = dimsizes(stat)
;  do ip = 0, num_st-1
;    if ( locs(0,ip) .lt. 1 .or. locs(0,ip) .gt. dimX .or. locs(1,ip) .lt. 1 .or. locs(1,ip) .gt. dimY )
;      print("Station - " + stat(ip) + " at location: "+ lats(ip) +" ; "+ lons(ip) + " is outside model domain" )
;      locs(:,ip) = -999
;      stat(ip) = " "
;    end if
;  end do

; Remove the data points outside our model domain
  if ( locs(0) .lt. 1 .or. locs(0) .gt. dimX .or. locs(1) .lt. 1 .or. locs(1) .gt. dimY )
    print("Station - " + stat(ip) + " at location: "+ lats(ip) +" ; "+ lons(ip) + " is outside model domain" )
    locs(:) = -999
    stat(ip) = " "
  end if

  stat@_FillValue = " "
  inds = ind(.not. ismissing(stat))
  ip_locs = stat(inds)

  loc1D = ndtooned(locs)
  indloc = ind(.not. ismissing(loc1D))
  loc1D_new = loc1D(indloc)
  num_st = num(.not. ismissing(locs))/2
  loc = new( (/2,num_st/), typeof(locs) )
  loc = onedtond(loc1D_new,dimsizes(loc))
  loc = loc - 1    ; location in NCL space to use as array indeses

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; What times and how many time steps are in the data set?
  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  do it = 0,ntimes-1        ; TIME LOOP

    print("Working on time: " + times(it) )

     nip = dimsizes(ip_locs)
     do ip = 0, nip-1         ; LOOP through all stations in model domain

     wks = gsn_open_wks("png",dest+"skt_"+dom+"_"+times(it)+"_"+ids(ip))

         gsn_define_colormap(wks,"WhViBlGrYeOrReWh")
  ;      Define a few skew-T plotting options
         skewtOpts          = True
         skewtOpts@DrawHeightScale   = True    ; plot height scale on side
         skewtOpts@DrawHeightScaleFt = False   ; plot height scale in km
         skewtOpts@DrawStandardAtm   = True    ; draw standard atm on plot
         skewtOpts@vpXF              = 0.12    ; controls off-set from left
         skewtOpts@vpYF              = 0.87    ; controls off-set from top
         skewtOpts@vpWidthF          = 0.75    ; controls size of plot
         skewtOpts@vpHeightF         = 0.75    ; controls size of plot
         skewtOpts@DrawFahrenheit    = False   ; use deg C scale
         skewtOpts@tiMainFontHeightF = 0.015   ; change height of main title
        ;skewtOpts@DrawColLine       = False   ; draw lines in black
         skewtOpts@DrawColAreaFill   = True    ; color on background plot
        ;skewtOpts@DrawColAreaColor  = "Green" ; final color may depend on the color table used
         skewtOpts@DrawColAreaColor  = 53      ; Light Green for WhViBlGrYeOrReWh color table
         skewtOpts@PrintOpts         = False   ; do not print options out


  ;      Get the skew-T background
         skewtOpts@tiMainString = name(ip)  + " at " + times(it)
         skewt_bkgd             = skewT_BackGround (wks, skewtOpts)
         draw (skewt_bkgd)


  ;      Draw the skew-T plot
         dataOpts           = True
         dataOpts@Parcel    = 1
         dataOpts@WspdWdir  = False  ; wind speed and dir [else: u,v]
         dataOpts@HspdHdir  = True   ; wind speed and dir [else: u,v]
         dataOpts@PlotWindH = False  ; plot wind barbs at h lvls [pibal; special]
         skewT_data = skewT_PlotData(wks, skewt_bkgd, p(it,:,loc(1,ip),loc(0,ip)), \
                                                     tc(it,:,loc(1,ip),loc(0,ip)), \
                                                     td(it,:,loc(1,ip),loc(0,ip)), \
                                                      z(it,:,loc(1,ip),loc(0,ip)), \
                                                      u(it,:,loc(1,ip),loc(0,ip)), \
                                                      v(it,:,loc(1,ip),loc(0,ip)), \
                                                      dataOpts)

  ;      Close the frame
         frame(wks)

         delete(skewtOpts)
         delete(dataOpts)
         delete(skewT_data)
         delete(skewt_bkgd)


   end do     ; END OF LOCATIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end do        ; END OF TIME LOOP

end
