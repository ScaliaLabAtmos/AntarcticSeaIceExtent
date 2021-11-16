;Make a Southern Hemisphere polar stereo map of Antarctica with station dots and text

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  ddir = "./"

;---start the graphics, and send to a .ps file called "map_antarctica"
  system("/bin/rm -f sea_ice_low_freq_region_revised.ps")
  wks = gsn_open_wks("ps","sea_ice_low_freq_region_revised_final") 

  plot=new(1,graphic)
;---specify graphics settings for plot
  res = True

;  res@gsnMaximize  = True               ;maximize plot in frame
  res@gsnPolar = "SH"                   ;make southern hemi polar stereo
;  res@mpProjection = "stereographic"
  res@mpMaxLatF = -55                  ;set northern lat edge of 55S
  res@mpGridLatSpacingF = 10            ;set latitude grid spacing of 10
  res@mpGridLonSpacingF = 90            ;set longitude grid spacing of 15
  res@mpMinLatF		= -90
  res@mpCenterLonF	= 0
  res@mpGridAndLimbOn	= True
  res@mpGridLineDashPattern = 7
;  res@mpLimitMode = "LatLon"
;  res@mpFillOn = True                   ;turn on map fill
;  res@mpOutlineOn = True                ;turn on map outlines
  res@mpFillOn = True                   ;Turn on map fill
  res@mpOceanFillColor = "LightBlue"
  res@mpDataSetName = "Earth..4"        ;Database that contains the ice shelves
  res@mpDataBaseVersion = "MediumRes"  
;  res@pmTickMarkDisplayMode = "Always"
;  res@tmXBLabelFontHeightF  = 0.01
;  res@tmXBMinorOn	    = False
 ; res@gsnMajorLonSpacing    = 30
; Set the areas to fill.
  res@vpWidthF               = 0.28
  res@vpHeightF              = 0.28
  res@vpXF                   = 0.45
  res@vpYF                   = 0.65
  res@gsnPolarLabelFontHeightF     = 0.013
                                  
    res@mpFillAreaSpecifiers = (/"Ocean","Ice","Land"/)
  res@mpSpecifiedFillColors = (/"LightBlue","White","Gray40"/)

  lats = ispan(-60,-75,15)
  nlat = dimsizes(lats)
  lons = new(nlat,integer)
  lons = 0
  clat = (/"75S","60S"/)

  res@gsnFrame = False			;do not advance page/frame

;---does not draw because does not advance frame
 res@mpPerimOn = False
  plot = gsn_csm_map(wks,res)      ;create polar map

  dumline = new((/6/),graphic)
  lres = True
  lres@gsLineColor = "blue4"
  lres@gsLineThicknessF = 4
 
;---draw text strings

;  drawNDCGrid(wks)

    dumline(1) = gsn_add_polyline(wks,plot,(/163,163/),(/-55,-90/),lres)
    dumline(2) = gsn_add_polyline(wks,plot,(/71,71/),(/-55,-90/),lres)
    dumline(3) = gsn_add_polyline(wks,plot,(/250,250/),(/-55,-90/),lres)
    dumline(4) = gsn_add_polyline(wks,plot,(/293,293/),(/-55,-90/),lres)
    dumline(5) = gsn_add_polyline(wks,plot,(/346,346/),(/-55,-90/),lres)

    draw(plot)

ddir2 = "~/OneDrive - Ohio University/sea_ice_recon/extent_recon_sum2021/recons_v4/seas_recon/code_updates/output_data/"
cseas = (/"DJF","MAM","JJA","SON"/)
creg =  (/"Ross","Bellingshausen-Amundsen_Sea","Weddell","King_Hakon","East_Antarctica","totalsie"/)
ctitle = (/"Ross-Amundsen","Amundsen-Bellingshausen","Weddell","King Hakon","East Antarctica","Total"/)
cout =  (/"Ross","Bellingshausen_Amundsen","Weddell","King_Hakon","East_Antarctica","Total"/)
;delim = "	"
delim = " "
CE = new((/5/),"float")
RE = CE
calr = CE
valr = CE
  ydata = new((/5,3,116/),"float")
  uci = new((/5,116/),"float")
   uci = -999.9
   uci@_FillValue = -999.9
  lci = uci
  ydata = -999.9
nens = CE
do isect = 0,4

do iseas = 2,2
  stat_all = asciiread(ddir2+"master/"+creg(isect)+"_recon_master_stats_"+cseas(iseas)+".txt",-1,"string")


  CE_all = stringtofloat(str_get_field(stat_all(2:),9,delim))
  RE_all = stringtofloat(str_get_field(stat_all(2:),8,delim))
  calr_all = stringtofloat(str_get_field(stat_all(2:),5,delim))
  valr_all = stringtofloat(str_get_field(stat_all(2:),6,delim))

;   print(CE_all)
;   exit

   best_check = str_get_field(stat_all(2:),10,delim)

   max_ind = ind(best_check.eq."yes")
  
   RE(isect) = RE_all(max_ind)
   valr(isect) = valr_all(max_ind)
   calr(isect) = calr_all(max_ind)
   CE(isect) = CE_all(max_ind)




   bf_recon = asciiread(ddir2+"best_fit_recons/best_fit_recons_"+creg(isect)+"_"+cseas(iseas)+".txt",-1,"string")
    
;   ydata(iseas,0,:)   = stringtofloat(str_get_field(bf_recon(1:),2,delim))   
   ydata(isect,2,:)  =  stringtofloat(str_get_field(bf_recon(1:),3,delim))   

;   bf_lci = stringtofloat(str_get_field(bf_recon(1:),4,delim))
;   bf_uci = stringtofloat(str_get_field(bf_recon(1:),5,delim))
   ens_recon_file = "../../code_updates/output_data/ens_recons/"+creg(isect)+"_recon_ensembles_"+cseas(iseas)+".txt"
   ncols = numAsciiCol(ens_recon_file)
   nrow = numAsciiRow(ens_recon_file)
   ens_recon = asciiread(ens_recon_file,(/nrow,ncols/),"float")
   nens(isect) = ncols-1.
   ydata(isect,0,:) = ens_recon(:,max_ind+1)
;   printVarSummary(ens_recon)
;   print(ens_recon(:,0))

   ens_mean = dim_avg(ens_recon(:,1:))
   ens_std = dim_stddev(ens_recon(:,1:))
   ydata(isect,1,:) = ens_mean

  ydata@_FillValue = -999.9  

  ydata=where(ydata.lt.-900,ydata@_FillValue,ydata)

   resid = ydata(isect,0,:) - ydata(isect,2,:)
   std_resid = dim_stddev(resid)
   bf_lci = ydata(isect,0,:) - 1.96*std_resid
   bf_uci = ydata(isect,0,:) + 1.96*std_resid
   ens_mean = dim_avg(ens_recon(:,1:))
   ens_std = dim_stddev(ens_recon(:,1:))
   ydata(isect,1,:) = ens_mean
   print("number of rows in ensembles..."+nens(isect))
;   if(iseas.eq.0)then
;   ydata(0,:,:112) = ydata(iseas,:,1:113)
;   ydata(0,:,113) = ydata@_FillValue
;   ydata(0,2,73) = ydata@_FillValue
;   end if

  uci_mean = ens_mean+1.96*ens_std
  lci_mean = ens_mean-(1.96*ens_std)


  do i = 0,115
  val1 = (/uci_mean(i),bf_uci(i)/)
   uci(isect,i) = max(val1)
  val2 = (/lci_mean(i),bf_lci(i)/)
   lci(isect,i) = min(val2) 
  end do
   delete([/ens_recon,bf_recon/])
;exit

   delete([/CE_all,RE_all,calr_all,valr_all,stat_all,max_ind,best_check/])
end do

  lci = where(lci.lt.0,0,lci)

  ydata=where(ydata.lt.0,0,ydata)

end do ;sector
;  uci(0,:112) = uci(0,1:113)
;  lci(0,:112) = lci(0,1:113)
;  uci(0,113) = uci@_FillValue
;  lci(0,113) = lci@_FillValue


ydata_smth = runave(ydata,11,0)
uci_smth = runave(uci,11,0)
lci_smth = runave(lci,11,0)
ydata_all = new((/5,6,116/),"float")
ydata_all(:,:2,:) = ydata
ydata_all(:,3:,:) = ydata_smth


;   printVarSummary(recon_mean)
;   printVarSummary(recon_std)
;   exit

;Section 6: plotting of reconstruction timeseries
;******************************************************************************

plot1 = new(1,graphic)
dum=new(4,graphic)
dum1=new(4,graphic)
dum2=new(4,graphic)
dum3=new(4,graphic)

res1 = True

res1@gsnYRefLine = 0.0
  res1@gsnDraw            = True             ; don't draw yet
  res1@gsnFrame           = False             ; don't advance frame yet
 ; res1@gsnMaximize        = True 

  res1@vpHeightF 	 = 0.15              ; change aspect ratio of plot
  res1@vpWidthF 	         = 0.32

  res1@trXMinF	         = 1905              ; set x-axis minimum
  res1@trXMaxF            = 2020		     ; set x-axis max

  res1@tmYMajorGrid	 = True		     
  res1@tmYMajorGridThicknessF = 1.0	     ; properties for y-grid
  res1@tmYMajorGridLineDashPattern = 2.0
  res1@tmXMajorGrid	 = True		     
  res1@tmXMajorGridThicknessF = 1.0	     ; properties for y-grid
  res1@tmXMajorGridLineDashPattern = 2.0
;  res1@tiYAxisString	 = "Sea Ice Extent (x10^6 km^2)"      ; add a axis title
    res1@tiYAxisString	 = ""      ; add a axis title    
;    res1@tiXAxisString	 = "Year"     	     		 ; add a axis title
      res1@tiXAxisString	 = ""     	     		 ; add a axis title    
  res1@tiXAxisFontHeightF = 0.01           		 ; change axis title font heights
  res1@tiYAxisFontHeightF = 0.01           		 ; change axis title font heights
  res1@xyMonoLineColor    = "False"           ; want colored lines
  res1@xyDashPatterns	 = 0.      ; make all lines solid
  res1@tmXTOn            = False

  res1@xyLineThicknesses = (/1,1,2,3,3,5/)
  res1@xyLineColors       = (/"Red","Blue","Black","Red","Blue","Black"/) ; colors chosen
  xdata = ispan(1905,2020,1)

;  res1@vpWidthF               = 0.75
;  res1@vpHeightF              = 0.5

;locations for map centered on 180
;  px = (/0.57,0.65,0.6,0.1,0.07/)
;  py = (/0.85,0.6,0.32,0.30,0.84/)
;  clab = (/"b)","c)","d)","e)","a)"/)
  
;locations for map centered on 0
  px = (/0.07,0.07,0.07,0.65,0.65/)
  py = (/0.30,0.58,0.85,0.83,0.34/)
  clab = (/"d)","c)","a)","b)","e)"/)

  txres               = True
  txres@txJust        = "CenterLeft"
  txres@txFontColor   = "black"
  txres@txFontHeightF = 0.008
  txres@txPerimColor = "transparent"
  txres@txBackgroundFillColor = "white"  


  do isect = 0,4
    res1@tiMainString = clab(isect)+" "+ctitle(isect)
    res1@tiMainJust = "CenterLeft"
    res1@tiMainPosition = "Left"
    res1@tiMainOffsetYF = -0.01
  res1@vpXF                   = px(isect)
  res1@vpYF                   = py(isect)

  if(dim_min(lci(isect,:)).le.0.5)then
  ymin = 0.
  else
  ymin = dim_min(lci(isect,:)) - .1
  end if

  ymax = dim_max(uci(isect,:)) + .3
  yrange = ymax - ymin
  ytop = ymax - 0.08*yrange
  ymid = ymax - 0.18*yrange
  ylow = ymin + 0.1*yrange
;  printVarSummary(ydata)
  
  res1@trYMinF  = ymin
  res1@trYMaxF  = ymax

  plot1 = gsn_csm_xy(wks,xdata,ydata_all(isect,:,:),res1)
  plot1 = fill_xy2(wks,plot1,xdata,uci(isect,:),lci(isect,:),"gray","gray")

   correl = escorc(ydata_smth(isect,0,:),ydata_smth(isect,1,:))
   correl1 = escorc(ydata_smth(isect,0,:),ydata_smth(isect,2,:))
   correl2 = escorc(ydata_smth(isect,1,:),ydata_smth(isect,2,:))
  tx1=gsn_add_text(wks,plot1,"cal r: "+sprintf("%5.3f",calr(isect)),1910,ytop,txres)
  tx2=gsn_add_text(wks,plot1,"val r: "+sprintf("%5.3f",valr(isect)),1938,ytop,txres)
  tx3=gsn_add_text(wks,plot1,"RE: "+sprintf("%5.3f",RE(isect)),1966,ytop,txres)
  tx4=gsn_add_text(wks,plot1,"CE: "+sprintf("%5.3f",CE(isect)),1994,ytop,txres)
  tx5=gsn_add_text(wks,plot1,"correl: "+sprintf("%5.3f",correl),1910,ymid,txres)
  tx6=gsn_add_text(wks,plot1,"11-yr correls: ",1910,ylow,txres)
    txres@txFontColor   = "red"
  tx7=gsn_add_text(wks,plot1,sprintf("%5.3f",correl1),1935,ylow,txres)
    txres@txFontColor   = "blue"
  tx8=gsn_add_text(wks,plot1,sprintf("%5.3f",correl2),1950,ylow,txres)
  txres@txFontColor   = "black"
  tx9=gsn_add_text(wks,plot1,"# ens mem: "+sprintf("%3.0f",nens(isect)),1990,ymid,txres)
  draw(plot1)
; end do


  delete(plot1)
  delete([/tx1,tx2,tx3,tx4,tx5,tx6,tx7,tx8,tx9/])
;  overlay(plot,plot1(isect))
  end do


  dxres               = True                      ; text mods desired
;  if(isect.eq.1)then 
  dxres@txFontHeightF = 0.018                     ; font smaller. default big
;  else
;  dxres@txFontHeightF = 0.02                     ; font smaller. default big
;  end if
  dxres@txJust        = "CenterCenter"
  dxres@txFont        = "helvetica-bold"

  gsn_text_ndc(wks,"JJA Sea Ice Extent Sector Reconstructions, 1905-2020",0.5,0.9,dxres)


;  dxres               = True                      ; text mods desired
;  dxres@txFontHeightF = 0.015                     ; font smaller. default big
;  dxres@txJust        = "CenterLeft"
;  dxres@txFont        = "helvetica-bold"



;  gsn_text_ndc(wks,"a) DJF",0.1,0.85,dxres)
;  gsn_text_ndc(wks,"b) MAM",0.6,0.85,dxres)
;  gsn_text_ndc(wks,"c) JJA",0.1,0.51,dxres)
;  gsn_text_ndc(wks,"d) SON",0.6,0.51,dxres)

wnres = True
wnres@gsLineThicknessF = 3.0
  wnres@gsLineColor     = "Red"
  gsn_polyline_ndc(wks,(/0.16,0.26/),(/0.07,0.07/),wnres)
  wnres@gsLineColor     = "Black"
  gsn_polyline_ndc(wks,(/0.55,0.65/),(/0.07,0.07/),wnres)
  wnres@gsLineColor     = "Blue"
  gsn_polyline_ndc(wks,(/0.16,0.26/),(/0.04,0.04/),wnres)

wnres@gsLineThicknessF = 2.0

;arrow code
;gsn_polyline_ndc(wks,(/0.15,0.3/),(/0.63,0.55/),wnres)
;gsn_polyline_ndc(wks,(/0.15,0.17/),(/0.63,0.63/),wnres)
;gsn_polyline_ndc(wks,(/0.15,0.16/),(/0.63,0.61/),wnres)

  
;gsn_polyline_ndc(wks,(/0.42,0.56/),(/0.57,0.65/),wnres)
;gsn_polyline_ndc(wks,(/0.56,0.55/),(/0.65,0.63/),wnres)
;gsn_polyline_ndc(wks,(/0.56,0.54/),(/0.65,0.65/),wnres)


;gsn_polyline_ndc(wks,(/0.5,0.58/),(/0.5,0.53/),wnres)
;gsn_polyline_ndc(wks,(/0.58,0.57/),(/0.53,0.51/),wnres)
;gsn_polyline_ndc(wks,(/0.58,0.56/),(/0.53,0.54/),wnres)


;gsn_polyline_ndc(wks,(/0.48,0.75/),(/0.41,0.35/),wnres)
;gsn_polyline_ndc(wks,(/0.75,0.74/),(/0.35,0.34/),wnres)
;gsn_polyline_ndc(wks,(/0.75,0.74/),(/0.35,0.36/),wnres)


;gsn_polyline_ndc(wks,(/0.35,0.29/),(/0.4,0.32/),wnres)
;gsn_polyline_ndc(wks,(/0.29,0.29/),(/0.34,0.32/),wnres)
;gsn_polyline_ndc(wks,(/0.31,0.29/),(/0.33,0.32/),wnres)

  
  
  
  pxres               = True                      ; text mods desired
  pxres@txFontHeightF = 0.015                     ; font smaller. default big
  pxres@txJust        = "CenterLeft" 
 gsn_text_ndc(wks,"Best Fit Reconstruction",0.28,0.07,pxres)
 gsn_text_ndc(wks,"Observed Sea Ice Extent",0.67,0.07,pxres)
 gsn_text_ndc(wks,"Ensemble Mean Reconstruction",0.28,0.04,pxres)


;  drawNDCGrid(wks)
   yloc = 0.81



    
;  draw(plot1)
  frame(wks)

  
  end

