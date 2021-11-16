;Make a Southern Hemisphere polar stereo map of Antarctica with station dots and text

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  ddir = "./"

;---start the graphics, and send to a .ps file called "map_antarctica"
  wks = gsn_open_wks("ps","stations_map_SH_long_term_regions_revised") 

  plot=new(2,graphic)
;---specify graphics settings for plot
  res = True

;  res@gsnMaximize  = True               ;maximize plot in frame
  ;res@gsnPolar = "SH"                   ;make southern hemi polar stereo
  res@mpProjection = "CylindricalEquidistant"
  res@mpMaxLatF = -10                   ;set northern lat edge of 55S
  res@mpGridLatSpacingF = 10            ;set latitude grid spacing of 10
  res@mpGridLonSpacingF = 30            ;set longitude grid spacing of 15
  res@mpMinLatF		= -90
  res@mpCenterLonF	= -180
  res@mpGridAndLimbOn	= True
  res@mpGridLineDashPattern = 7
  res@mpLimitMode = "LatLon"
;  res@mpFillOn = True                   ;turn on map fill
  res@mpOutlineOn = True                ;turn on map outlines
  res@mpFillOn = True                   ;Turn on map fill
  res@mpOceanFillColor = "LightBlue"
  res@mpDataSetName = "Earth..4"        ;Database that contains the ice shelves
  res@mpDataBaseVersion = "MediumRes"  
  res@pmTickMarkDisplayMode = "Always"
  res@tmXBLabelFontHeightF  = 0.01
  res@tmXBMinorOn	    = False
  res@gsnMajorLonSpacing    = 30
; Set the areas to fill.
  res@vpWidthF               = 0.89
  res@vpHeightF              = 0.5
  res@vpXF                   = 0.075
  res@vpYF                   = 0.99
                                
    res@mpFillAreaSpecifiers = (/"Ocean","Ice","Land"/)
  res@mpSpecifiedFillColors = (/"LightBlue","White","Gray90"/)

  lats = ispan(-60,-75,15)
  nlat = dimsizes(lats)
  lons = new(nlat,integer)
  lons = 0
  clat = (/"75S","60S"/)

  res@gsnFrame = False			;do not advance page/frame

;---does not draw because does not advance frame

  plot(0) = gsn_csm_map(wks,res)      ;create polar map
;--Specify lat,lon values for markers

  station_locs = asciiread(ddir+"stations_lat_lon_sort.txt",(/30,2/),"float")
  lat1 = station_locs(:,0)
  lon1 = station_locs(:,1)

;  lat1=(/-34,-34,-30,-31.9,-23.8,-35,-37.8,-42.8,-33.9,-27.4,-37,-42.7,-45.9,-43.5,-41.3,-44,-24.9,-28.6,-33.4,-39.6,-53,-45.6,-38.7,-34.6,-31.3,-22.9,-60.7,-17.6,-16/)

;  lon1=(/18.6,25.6,31,116,133.9,138.5,145,147.5,151.2,153.1,174.8,171,170.5,172.5,174.8,-176.6,-65.5,-65.8,-70.8,-73.1,-70.8,-69.1,-62.2,-58.5,-64.2,-43.2,-44.7,-149.6,-5.7/)

   plat1 = lat1+4.0
   plon1 = lon1+2.0

  plat=(/-37,-37,-33,-31.9,-23.8,-38.5,-34.8,-42.8,-33.9,-27.4,-34,-40,-50,-46,-40.6,-42,-27.6,-33.4,-39.6,-51,-44.6,-40.7,-34.6,-31,-22.9,-58,-22.5,-18/)

  plon=(/19.6,26.6,32,111,135.9,136,145,151,153.2,155.1,175,163.5,166.5,173.5,176,-175.6,-73.2,-78,-80.5,-69,-68,-60.2,-56.5,-62.8,-41.2,-42.2,-146,-13/)

  plat1(:24) = plat(:24)
  plon1(:24) = plon(:24)
;  plat1(26) = plat(25)
;  plon1(26) = plon(25)
  plat1(28:29) = plat(26:)
  plon1(28:29) = plon(26:)
  
;special edits
  plon1(20) = plon1(20)+2.
  plat1(23) = plat1(23)+1.
  plat1(26) = plat1(26)-2.
  plon1(25) = plon1(25) - 8.
  plon1(17) = plon1(17)+8
  plat1(17) = plat1(17)-2
;  plat1(40) = plat1(40)-1.
;  plon1(40) = plon1(40) -8.

  name1=(/"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47"/)
  name2=(/"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","18","19","20","21","23","24","25","26","27","17","28","22","29","30","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47"/)


;--specify marker settings
  mkres = True
  dum_fill=new(48,graphic)
  dum_fillt=new(48,graphic)
  dum_fillr=new(48,graphic)
  dum1_fill=new(5,graphic)
  dum_fill3=new(1,graphic)
  dum_fill4=new(5,graphic)

  dumline = new((/6/),graphic)
  mkres@gsMarkerThicknessF = 2.0      ; Twice as thick
  lres = True
  lres@gsLineColor = "blue4"
  lres@gsLineThicknessF = 3
;---draw text strings
  txres = True
  dum_txt=new(48,string)
;---set font settings
  txres@txFont = 26
  txres@txFontHeightF  = 0.012
  txres@txFontThicknessF = 1
  txres@txJust = "CenterLeft"


  txres@txFontHeightF  = 0.01

    mkres@gsMarkerIndex = 16          ; Filled dots
    mkres@gsMarkerSizeF = 6
    mkres@gsMarkerColor = "red4"

    dum_fillt = gsn_add_polymarker(wks,plot(0),lon1,lat1,mkres)
;    dumline(0) = gsn_add_polyline(wks,plot(0),(/0,360/),(/-60,-60/),lres)
    dumline(1) = gsn_add_polyline(wks,plot(0),(/163,163/),(/-60,-90/),lres)
    dumline(2) = gsn_add_polyline(wks,plot(0),(/71,71/),(/-60,-90/),lres)
    dumline(3) = gsn_add_polyline(wks,plot(0),(/250,250/),(/-60,-90/),lres)
    dumline(4) = gsn_add_polyline(wks,plot(0),(/293,293/),(/-60,-90/),lres)
    dumline(5) = gsn_add_polyline(wks,plot(0),(/346,346/),(/-60,-90/),lres)
    dum2_txt = gsn_add_text(wks,plot(0),name2(:29),plon1(:29),plat1(:29),txres)
;    dum4_txt = gsn_add_text(wks,plot(0),name1(46),plon1(46),plat1(46),txres)

;  mkres1 = mkres
;  mkres1@gsMarkerColor = "navy"
;    dum_fillr = gsn_add_polymarker(wks,plot(0),lon1(30:),lat1(30:),mkres1)
; drawNDCGrid(wks)
 gres                 = True
  gres@gsFillColor     = "black"
;  gres@tfPolyDrawOrder = "Draw"  ; this can be used for polylines, polymarkers, or polygons

;   gres@gsLineThicknessF = 2.0
;  lat = (/-55,  -75, -75, -55, -55/)
;  lon = (/270, 270, 330, 330, 270/)
;  dum = gsn_add_polyline(wks,plot(0),lon,lat,gres)



    txres@txJust	= "CenterLeft"




;    mkres@gsMarkerSizeF = 12
;  res@mpMaxLatF = -55                   ;set northern lat edge of 55S
;  res@mpGridLatSpacingF = 5            ;set latitude grid spacing of 10
;  res@mpGridLonSpacingF = 10            ;set longitude grid spacing of 15
;  res@mpMinLatF		= -75
;  res@mpMinLonF         = 270
;  res@mpMaxLonF         = 330
; Set the areas to fill.
;  res@vpWidthF               = 0.5
;  res@vpHeightF              = 0.6
;  res@vpXF                   = 0.275
;  res@vpYF                   = 0.8
;  drawNDCGrid(wks)

  txres@txFontHeightF  = 0.015


  txres@txFontHeightF  = 0.011

  mid_lat_name=(/"Cape Town","Port Elizabeth","Durban","Perth","Alice Springs","Adelaide","Melbourne","Hobart","Sydney","Brisbane","Auckland","Hokitika","Dunedin","Christchurch","Wellington","Chatham Island","Juan Fernandez","Catamarca","Santiago","Valdivia","Punta Arenas","Salta","Sarmiento","Bahia Blanca","Buenos Aires","Cordoba","Rio de Janeiro","Orcadas","Tahiti","St. Helena Island"/)

;recon_name=(/"Novolazarevskaya","Syowa","Mawson","Davis","Vostok","Casey","Dumont d'Urville","McMurdo / Scott Base","Amundsen Scott","Byrd","Rothera","Faraday","Bellingshausen","Esperanza","Marambio","Halley","Mirny"/)

;  name2=(/"31","32","33","34","36","37","38","39","40","41","42","43","44","45","46","47","35"/)
  xvals=(/0.1,0.25,0.40,0.55,0.70,0.85/)
  xvals = xvals -0.05
  ystart = 0.55
  ival = 0
  do i = 0,5
   do j = 0,4
     yval = ystart-j*0.02
  gsn_text_ndc(wks,name1(ival)+". "+mid_lat_name(ival),xvals(i),yval,txres)
   ival = ival+1
   end do
  end do
  gres@tfPolyDrawOrder = "PostDraw"

;  xvals2 = (/0.15,0.35,0.55,0.75/)
;  xvals2 = xvals2-0.05
;  ystart2 = 0.17
;  ival =0
;  do i = 0,3
;   do j=0,3
;     yval = ystart2-j*0.02
;  gsn_text_ndc(wks,name2(ival)+". "+recon_name(ival),xvals2(i),yval,txres)
;   ival = ival+1
;   end do
;  end do

;   gsn_text_ndc(wks,name2(ival)+". "+recon_name(ival),xvals2(0),yval-0.02,txres)
    
  draw(plot)   ;this draws the map with all poly markers and text

;  gsn_polyline_ndc(wks,(/0.275,0.755/),(/0.582,0.68/),gres)
;  gsn_polyline_ndc(wks,(/0.775,0.89/),(/0.582,0.68/),gres)

  txres@txFontHeightF  = 0.015
  txres@txFontColor = "blue4"
  txres@txJust = "CenterCenter"
  
  gsn_text_ndc(wks,"King Hakon VII",0.16,0.72,txres)  
  gsn_text_ndc(wks,"East Antarctica",0.37,0.72,txres)  
  gsn_text_ndc(wks,"Ross-Amundsen~C~         Seas",0.58,0.7,txres)  
  gsn_text_ndc(wks,"ABS",0.745,0.71,txres)  
  txres@txFontHeightF  = 0.014
  gsn_text_ndc(wks,"Weddell Sea",0.87,0.695,txres)  
  
  

  txres@txFontColor = "black"
  txres@txFontHeightF  = 0.02
  txres@txFontThicknessF = 1
  txres@txJust = "CenterCenter"

;  drawNDCGrid(wks) 
  gsn_text_ndc(wks,"SH Long-Term Pressure & Temperature Observation Locations",0.5,0.89,txres)
  gsn_text_ndc(wks,"with Sea Ice Sectors",0.5,0.86,txres)


  txres@txFontHeightF  = 0.02
  txres@txFontColor = "Red4"
  gsn_text_ndc(wks,"Station Names",0.5,0.58,txres)
  
  gsn_text_ndc(wks,"Additional Climate Index Data Layers",0.5,0.42,txres)


  txres@txFontHeightF  = 0.015
  txres@txFontHeightF  = 0.011
    txres@txJust	= "CenterLeft"
  txres@txFontColor = "black"

 clayers = (/"Interdecadal Pacific Oscillation (IPO)","Atlantic Multidecadal Oscillation (AMO)","Pacific Decadal Oscillation (PDO)","Southern Oscillation Index (SOI)","Nino 1+2 SST Anonamlies","Nino 3.4 SST Anomalies","Nino 3 SST Anomalies","Nino 4 SST Anomalies","Southern Annular Mode Seasonal Reconstructions"/)

  xvals2=(/0.05,0.38/)
;  xvals2 = xvals2 -0.05
  ystart = 0.39
  ival = 0
  do i = 0,1
   do j = 0,3
     yval = ystart-j*0.02
  gsn_text_ndc(wks,clayers(ival),xvals2(i),yval,txres)
   ival = ival+1
   end do
  end do

   xval3 = 0.62
   do j = 0,0
     yval = ystart-j*0.02
  gsn_text_ndc(wks,clayers(ival),xval3,yval,txres)
   ival = ival+1
   end do

;  txres@txFontColor = "Navy"
;  gsn_text_ndc(wks,"Pressure Reconstructions",0.5,0.2,txres)


  
  end

