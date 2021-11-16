;*********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;load "/Users/chadgoergens/shea_util_boxplot.ncl"
;*********************************************
begin
;**********************************************
; Create some data
;**********************************************

delim = " "

ddir2 = "~/OneDrive - Ohio University/sea_ice_recon/extent_recon_sum2021/recons_v4/seas_recon/code_updates/output_data/"
stats_full = new((/4,4,240/),"float") ; 4 seasons x 4 statistics x (up to 40 ensembles * 6 sectors)
stats_full = -999.99
stats_full@_FillValue = -999.99
best_stats = stats_full(:,:,:5)
printVarSummary(best_stats)
yval = new((/4,8,5/),"float")
yval1 = yval
nens = new((/4/),"float")

cseas = (/"DJF","MAM","JJA","SON"/)
creg =  (/"Ross","Bellingshausen-Amundsen_Sea","Weddell","King_Hakon","East_Antarctica","totalsie"/)

do iseas = 0,3

ival1 = 0

do isect = 0,5



  stat_all = asciiread(ddir2+"/master/"+creg(isect)+"_recon_master_stats_"+cseas(iseas)+".txt",-1,"string")


  CE_all = stringtofloat(str_get_field(stat_all(2:),9,delim))
  RE_all = stringtofloat(str_get_field(stat_all(2:),8,delim))
  calr_all = stringtofloat(str_get_field(stat_all(2:),5,delim))
  valr_all = stringtofloat(str_get_field(stat_all(2:),6,delim))

  CE_max = dim_max(CE_all)
;   print("number of rows in master stats...."+dimsizes(CE_all))
   best_check = str_get_field(stat_all(2:),10,delim)
  max_ind = ind(best_check.eq."yes")
;  max_ind = ind(CE_all.eq.CE_max)
  



  best_stats(iseas,0,isect) = calr_all(max_ind)
  best_stats(iseas,1,isect) = valr_all(max_ind)
  best_stats(iseas,2,isect) = RE_all(max_ind)
  best_stats(iseas,3,isect) = CE_all(max_ind)

  ival2= (dimsizes(CE_all) - 1) + ival1
;   print(ival1+"  "+ival2)

  stats_full(iseas,0,ival1:ival2) = calr_all
  stats_full(iseas,1,ival1:ival2) = valr_all
  stats_full(iseas,2,ival1:ival2) = RE_all
  stats_full(iseas,3,ival1:ival2) = CE_all
 
  ival1 = ival2 + 1

  delete([/CE_all,RE_all,calr_all,valr_all,stat_all,best_check/])
;  delete([/CE_all,RE_all,calr_all,valr_all,stat_all,CE_max/])
  
 end do ; sector loop

  nens(iseas) = num(.not.ismissing(stats_full(iseas,0,:)))

end do ;season loop

do iseas = 0,3

;loop to calculate box plot values based on the best reconstructions
  do istat = 0,3

    ixval = istat*2
    stat = stats_full(iseas,istat,:)
    stat1 = stat_dispersion(stat,True)   ; sets up the statistics to be true to calculate the lower & upper quartiles
   
    yval(iseas,ixval,0) = min(stat)
    yval(iseas,ixval,1) = stat1(7)
    yval(iseas,ixval,2) = dim_median(stat)
    yval(iseas,ixval,3) = stat1(11)
    yval(iseas,ixval,4) = max(stat)
    ;printVarSummary(yval(iseas,pseas,istat,0))

    bstat = best_stats(iseas,istat,:)
    bstat1 = stat_dispersion(bstat,True)   ; sets up the statistics to be true to calculate the lower & upper quartiles
   
    yval(iseas,ixval+1,0) = min(bstat)
    yval(iseas,ixval+1,1) = bstat1(7)
    yval(iseas,ixval+1,2) = dim_median(bstat)
    yval(iseas,ixval+1,3) = bstat1(11)
    yval(iseas,ixval+1,4) = max(bstat)

  end do

 end do ;season loop




   x = (/-.25,.25,.75,1.25,1.75,2.25,2.75,3.25/)	
   xtm  = (/-2,0.,1.,2.,3/)	


;**********************************************
; create plot
;**********************************************
 system("/bin/rm -f recon_boxplot_all_ens_v4_revised.ps")
  wks = gsn_open_wks("ps","recon_boxplot_all_ens_v4_revised")   
  plot = new(4,graphic)              ; create postscript file
  tplot = new(1,graphic)
  dum = new(4,graphic)
  dum1 = new(4,graphic)
  dum2 = new(4,graphic)
  dum4=new(4,graphic)

  res            = True  
  res@tmXBMode = "Explicit" 
  res@tmXBValues = xtm
  res@trXMinF = -.5
  res@trXMaxF = 3.5  
  res@tmXBLabels =  (/"Cal r","Val r","RE","CE"," "," "," "," "/) ; labels for each box
  res@tiMainFontThicknessF = 4.
  res@trYMinF = 0   ;-0.6
  res@trYMaxF = 1.0
  res@tmYLMode = "Manual"
  res@tmYLTickStartF = res@trYMinF
  res@tmYLTickEndF = res@trYMaxF
  res@tmYLTickSpacingF = 0.2
  res@tmYMajorGrid = True
  res@tmYMajorGridThicknessF = 2
  res@tmYMajorGridLineDashPattern = 2.0
  res@tmXBMajorThicknessF = 3.
  res@tmYLMinorThicknessF = 3.
  res@tmBorderThicknessF  = 3.
  res@tmXBLabelFontThicknessF = 3.0
  res@tmYLLabelFontThicknessF = 3.0

  opti           = True


  llres          = True
  lnres          = True
  pnres          = True
  pnres@gsLineDashPattern = 0
  pnres@gsLineThicknessF = 2.5
  lnres@gsLineThicknessF = 1.5
  llres@gsLineThicknessF = 3
  llres@gsLineDashPattern = 0
  lnres@gsLineDashPattern = 0

  opti@boxColors = (/"blue","red","blue","red","blue","red","blue","red"/)


  do iseas = 0,3  ;loops through variables to plot

   plot(iseas) = boxplot(wks,x,yval(iseas,:,:),opti,res,llres)
   dum(iseas) = gsn_add_polyline(wks,plot(iseas),(/0.5,0.5/),(/-1,1/),lnres)
   dum1(iseas)=  gsn_add_polyline(wks,plot(iseas),(/1.5,1.5/),(/-1,1/),lnres)
   dum2(iseas) =  gsn_add_polyline(wks,plot(iseas),(/2.5,2.5/),(/-1,1/),lnres)
   dum4(iseas)  = gsn_add_polyline(wks,plot(iseas),(/-1,4/),(/0,0/),pnres)
  end do


;***********************************************
; the function boxplot will except three different
; resource lists. In this default example, we set
; two of them to False.
;**********************************************
 ; plot(0) = boxplot(wks,x,yval(0,0,:,:),opti,res,llres)
  ; res@tiMainString = "a) DJF"
 ; plot(1) = boxplot(wks,x,yval(1,1,:,:),opti,res,llres)
  ; res@tiMainString = "b) MAM"
 ; plot(2) = boxplot(wks,x,yval(2,2,:,:),opti,res,llres)
  ; res@tiMainString = "c) JJA"
 ; plot(3) = boxplot(wks,x,yval(3,3,:,:),opti,res,llres)
  ; res@tiMainString = "d) SON" 




pnlres                  = True
  pnlres@gsnFrame       = False
  pnlres@gsnPanelBottom = 0.16  ; Leave room for legend at the bottom.
  pnlres@txString       = "Reconstruction Seasonal Skill Performance across All Ensembles"
  ; draw panel with white space added
  pnlres@gsnPanelYWhiteSpacePercent = 6.0
  pnlres@gsnPanelXWhiteSpacePercent = 3.0

gsn_panel(wks,plot,(/2,2/),pnlres)

;************************************************
; Draw text on plot using NDC coordinates.
;************************************************
  txres               = True                      ; text mods desired
  txres@txFontHeightF = 0.014                     ; font smaller. default big
  txres@txJust        = "CenterLeft"

;   drawNDCGrid(wks)

;  gsn_text_ndc(wks,"10% Network",0.285,0.10,txres)
;   gsn_text_ndc(wks,"5% Network",0.285,0.06,txres)
;    gsn_text_ndc(wks,"2.5% Network",0.625,0.10,txres)  
;     gsn_text_ndc(wks,"1% Network",0.625,0.06,txres)

    gsn_text_ndc(wks,"a) DJF",0.16,0.915,txres)
    gsn_text_ndc(wks,"b) MAM",0.52,0.915,txres)
    gsn_text_ndc(wks,"c) JJA",0.16,0.53,txres)
    gsn_text_ndc(wks,"d) SON",0.52,0.53,txres)
    


  txres@txJust        = "CenterLeft"
  txres@txFontColor   = "black"
  txres@txFontHeightF = 0.011
  txres@txPerimColor = "transparent"
  txres@txBackgroundFillColor = "white"  

   yloc = 0.63

 do iseas = 0, 3
  if(iseas.eq.0.or.iseas.eq.2)then
  xval1 = 0.21
  else
  xval1 = 0.57
  end if
  if(iseas.ge.2)then
  yloc = 0.24
  end if
  gsn_text_ndc(wks,"# ens members: "+sprintf("%3.0f",nens(iseas)),xval1,yloc,txres)

 end do


wnres = True
wnres@gsLineThicknessF = 3.0
  wnres@gsLineColor     = "Blue"
  gsn_polyline_ndc(wks,(/0.18,0.28/),(/0.15,0.15/),wnres)
   wnres@gsLineColor     = "Red"
   gsn_polyline_ndc(wks,(/0.55,0.65/),(/0.15,0.15/),wnres)
;     wnres@gsLineColor     = "Darkgreen"
;     gsn_polyline_ndc(wks,(/0.61,0.53/),(/0.10,0.10/),wnres)
;      wnres@gsLineColor     = "blueviolet"
;      gsn_polyline_ndc(wks,(/0.61,0.53/),(/0.06,0.06/),wnres)

  txres@txFontHeightF = 0.014
  gsn_text_ndc(wks,"All Ensemble Members",0.3,0.15,txres)
  gsn_text_ndc(wks,"Best Fit Ensemble ~C~by Sector (6 total)",0.67,0.15,txres)

  frame(wks)                                   ; for you

end