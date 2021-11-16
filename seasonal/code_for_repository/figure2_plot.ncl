;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;NOTE: THIS VERSION KEEPS TRENDS IN PREDICTOR AND PREDICTANDS


ddir2 = "~/OneDrive - Ohio University/sea_ice_recon/extent_recon_sum2021/recons_v4/seas_recon/code_updates/output_data/"
cseas = (/"DJF","MAM","JJA","SON"/)
creg =  (/"Ross","Bellingshausen-Amundsen_Sea","Weddell","King_Hakon","East_Antarctica","totalsie"/)
ctitle = (/"Ross","Bellingshausen-Amundsen","Weddell","King Hakon","East Antarctica","Total"/)
cout =  (/"Ross","Bellingshausen_Amundsen","Weddell","King_Hakon","East_Antarctica","Total"/)
;delim = "	"
delim = " "
CE = new((/4/),"float")
RE = CE
calr = CE
valr = CE
  ydata = new((/4,5,116/),"float")
  uci = new((/4,116/),"float")
  lci = uci
  ydata = -999.9
nens = new((/4,2/),"float")

sector_recons = new((/4,5,116/),"float")
do iseas = 0,3

do isect = 5,5
  stat_all = asciiread(ddir2+"master/"+creg(isect)+"_recon_master_stats_"+cseas(iseas)+".txt",-1,"string")


  CE_all = stringtofloat(str_get_field(stat_all(2:),9,delim))
  RE_all = stringtofloat(str_get_field(stat_all(2:),8,delim))
  calr_all = stringtofloat(str_get_field(stat_all(2:),5,delim))
  valr_all = stringtofloat(str_get_field(stat_all(2:),6,delim))

;   print(CE_all)
;   exit
   best_check = str_get_field(stat_all(2:),10,delim)
   max_ind = ind(best_check.eq."yes")

  
   RE(iseas) = RE_all(max_ind)
   valr(iseas) = valr_all(max_ind)
   calr(iseas) = calr_all(max_ind)
   CE(iseas) = CE_all(max_ind)
   bf_recon = asciiread(ddir2+"best_fit_recons/best_fit_recons_"+creg(isect)+"_"+cseas(iseas)+".txt",-1,"string")
   ydata(iseas,4,:)  =  stringtofloat(str_get_field(bf_recon(1:),3,delim))   

   ens_recon_file = "../../code_updates/output_data/ens_recons/"+creg(isect)+"_recon_ensembles_"+cseas(iseas)+".txt"
   ncols = numAsciiCol(ens_recon_file)
   nrow = numAsciiRow(ens_recon_file)
   ens_recon = asciiread(ens_recon_file,(/nrow,ncols/),"float")
   nens(iseas,0) = ncols-1.
   ydata(iseas,0,:) = ens_recon(:,max_ind+1)
  ydata@_FillValue = -999.9  

  ydata=where(ydata.lt.-900,ydata@_FillValue,ydata)

   resid = ydata(iseas,0,:) - ydata(iseas,4,:)
   std_resid = dim_stddev(resid)
   bf_lci = ydata(iseas,0,:) - 1.96*std_resid
   bf_uci = ydata(iseas,0,:) + 1.96*std_resid

end do ;isect

   delete([/CE_all,RE_all,calr_all,valr_all,stat_all,max_ind,best_check/])

   total_ens = asciiread(cseas(iseas)+"_summed_total_recon_ensemble_data_updated_helena.txt",-1,"string")

   ydata(iseas,1,:) = stringtofloat(str_get_field(total_ens(1:),2,delim))
   ydata(iseas,3,:) = stringtofloat(str_get_field(total_ens(1:),3,delim))
   total_num = stringtofloat(str_get_field(total_ens(1:),5,delim))
   nens(iseas,1) = total_num(0)
   ens_mean = ydata(iseas,3,:)
   ens_std = stringtofloat(str_get_field(total_ens(1:),4,delim))
  uci_mean = ens_mean+1.96*ens_std
  lci_mean = ens_mean-(1.96*ens_std)


  do i = 0,115
  val1 = (/uci_mean(i),bf_uci(i)/)
   uci(iseas,i) = max(val1)
  val2 = (/lci_mean(i),bf_lci(i)/)
   lci(iseas,i) = min(val2) 
  end do  
    delete([/ens_recon,bf_recon/])




do isect = 0,4

  stat_all = asciiread(ddir2+"master/"+creg(isect)+"_recon_master_stats_"+cseas(iseas)+".txt",-1,"string")
   best_check = str_get_field(stat_all(2:),10,delim)
   max_ind = ind(best_check.eq."yes")
   
   ens_recon_file = "../../code_updates/output_data/ens_recons/"+creg(isect)+"_recon_ensembles_"+cseas(iseas)+".txt"
   ncols = numAsciiCol(ens_recon_file)
   nrow = numAsciiRow(ens_recon_file)
   ens_recon = asciiread(ens_recon_file,(/nrow,ncols/),"float")

   sector_recons(iseas,isect,:) = ens_recon(:,max_ind+1)
   delete([/ens_recon,stat_all,best_check/])
end do ;isect

   tmp = dim_sum_n(sector_recons(iseas,:,:),0)
   printVarSummary(tmp)
   ydata(iseas,2,:) = dim_sum_n(sector_recons(iseas,:,:),0)
   

end do ;iseas

  ydata=where(ydata.lt.-900,ydata@_FillValue,ydata)
;   ydata(0,:,:112) = ydata(0,:,1:113)
;   ydata(0,:,113) = ydata@_FillValue
;   ydata(0,4,73) = ydata@_FillValue

  lci = where(lci.lt.0,0,lci)

  ydata=where(ydata.lt.0,0,ydata)

;  uci(0,:112) = uci(0,1:113)
;  lci(0,:112) = lci(0,1:113)
;  uci(0,113) = uci@_FillValue
;  lci(0,113) = lci@_FillValue

;   printVarSummary(recon_mean)
;   printVarSummary(recon_std)
;   exit

;Section 6: plotting of reconstruction timeseries
;******************************************************************************
system("/bin/rm -f total_comparison_multi_v4_revised.ps")
wks = gsn_open_wks("ps","total_comparison_multi_v4_revised")
plot = new(4,graphic)
plot1 = new(4,graphic)
dum=new(4,graphic)
dum1=new(4,graphic)
dum2=new(4,graphic)
dum3=new(4,graphic)

res = True

colors = (/"Red","sienna4","purple","Blue","Black"/)

res@gsnYRefLine = 0.0
  res@gsnDraw            = False             ; don't draw yet
  res@gsnFrame           = False             ; don't advance frame yet
 ; res@gsnMaximize        = True 

  res@vpHeightF 	 = 0.4               ; change aspect ratio of plot
  res@vpWidthF 	         = 0.7

  res@trXMinF	         = 1905              ; set x-axis minimum
  res@trXMaxF            = 2020		     ; set x-axis max

  res@tmYMajorGrid	 = True		     
  res@tmYMajorGridThicknessF = 1.0	     ; properties for y-grid
  res@tmYMajorGridLineDashPattern = 2.0
  res@tmXMajorGrid	 = True		     
  res@tmXMajorGridThicknessF = 1.0	     ; properties for y-grid
  res@tmXMajorGridLineDashPattern = 2.0
  res@tiYAxisString	 = "Sea Ice Extent (x10^6 km^2)"      ; add a axis title    
  res@tiXAxisString	 = "Year"     	     		 ; add a axis title    
  res@tiXAxisFontHeightF = 0.025           		 ; change axis title font heights
  res@tiYAxisFontHeightF = 0.025           		 ; change axis title font heights
  res@xyMonoLineColor    = "False"           ; want colored lines
  res@xyDashPatterns	 = 0.      ; make all lines solid
  res@tmXTOn            = False

  res@xyLineThicknesses = (/2,2,2,2,3/)
  res@xyLineColors       =  colors ; colors chosen
  xdata = ispan(1905,2020,1)


  do iseas = 0,3
 
  if(dim_min(lci(iseas,:)).le.1)then
  ymin = 0.
  else
  ymin = dim_min(lci(iseas,:)) - 2
  end if

  ymax = dim_max(uci(iseas,:)) + 2

;  printVarSummary(ydata)
  
  res@trYMinF  = ymin
  res@trYMaxF  = ymax

  plot(iseas) = gsn_csm_xy(wks,xdata,ydata(iseas,:,:),res)
  plot(iseas) = fill_xy2(wks,plot(iseas),xdata,uci(iseas,:),lci(iseas,:),"gray","gray")

  end do

  pnlres                = True
  pnlres@gsnFrame       = False
  pnlres@gsnPanelTop = 0.95
  pnlres@gsnPanelBottom = .1

  ; draw panel with white space added
  pnlres@gsnPanelYWhiteSpacePercent = 10.
  pnlres@gsnPanelXWhiteSpacePercent = 5.0
  gsn_panel(wks,plot,(/2,2/),pnlres)

  dxres               = True                      ; text mods desired
  if(isect.eq.1)then 
  dxres@txFontHeightF = 0.018                     ; font smaller. default big
  else
  dxres@txFontHeightF = 0.02                     ; font smaller. default big
  end if
  dxres@txJust        = "CenterCenter"
  dxres@txFont        = "helvetica-bold"

  gsn_text_ndc(wks,"Seasonal Antarctic Total Sea Ice Extent Comparisons, 1905-2020",0.5,0.9,dxres)


  dxres               = True                      ; text mods desired
  dxres@txFontHeightF = 0.015                     ; font smaller. default big
  dxres@txJust        = "CenterLeft"
;  dxres@txFont        = "helvetica-bold"



  gsn_text_ndc(wks,"a) DJF",0.1,0.85,dxres)
  gsn_text_ndc(wks,"b) MAM",0.6,0.85,dxres)
  gsn_text_ndc(wks,"c) JJA",0.1,0.51,dxres)
  gsn_text_ndc(wks,"d) SON",0.6,0.51,dxres)

wnres = True
wnres@gsLineThicknessF = 3.0
  wnres@gsLineColor     = "Red"
  gsn_polyline_ndc(wks,(/0.1,0.2/),(/0.18,0.18/),wnres)
  wnres@gsLineColor     = "Black"
  gsn_polyline_ndc(wks,(/0.55,0.65/),(/0.18,0.18/),wnres)
  wnres@gsLineColor     = "sienna4"
  gsn_polyline_ndc(wks,(/0.1,0.2/),(/0.15,0.15/),wnres)
  wnres@gsLineColor     = "purple"
  gsn_polyline_ndc(wks,(/0.1,0.2/),(/0.12,0.12/),wnres)
  wnres@gsLineColor     = "blue"
  gsn_polyline_ndc(wks,(/0.1,0.2/),(/0.09,0.09/),wnres)

  pxres               = True                      ; text mods desired
  pxres@txFontHeightF = 0.013                     ; font smaller. default big
  pxres@txJust        = "CenterLeft" 
 gsn_text_ndc(wks,"Best Fit Total Reconstruction",0.21,0.18,pxres)
 gsn_text_ndc(wks,"Best Fit Summed Sector Reconstructions",0.21,0.15,pxres)
 gsn_text_ndc(wks,"Sum of Best Fit Sector Reconstructions",0.21,0.12,pxres)
 gsn_text_ndc(wks,"Observed Total Sea Ice Extent",0.66,0.18,pxres)
 gsn_text_ndc(wks,"Ensemble Mean of All Possible Summed Sector Reconstructions",0.21,0.09,pxres)

  txres               = True
  txres@txJust        = "CenterLeft"
  txres@txFontColor   = "black"
  txres@txFontHeightF = 0.011
  txres@txPerimColor = "transparent"
  txres@txBackgroundFillColor = "white"  

;  drawNDCGrid(wks)
   yloc = 0.81

   correl_obs = new((/4/),"float")
   correl_ensmean = new((/3/),"float")


 do iseas = 0, 3
   do i = 0,3
    correl_obs(i) = escorc(ydata(iseas,4,:),ydata(iseas,i,:))
   end do
   do i = 0,2
    correl_ensmean(i) = escorc(ydata(iseas,3,:),ydata(iseas,i,:))
   end do
   correl = escorc(ydata(iseas,0,:),ydata(iseas,1,:))
   correl2 = escorc(ydata(iseas,2,:),ydata(iseas,1,:))
  if(iseas.eq.0.or.iseas.eq.2)then
  xval1 = 0.0955
  else
  xval1 = 0.6
  end if
  if(iseas.ge.2)then
  yloc = 0.47
  end if
  yloc2 = yloc - 0.165
  yloc3 = yloc - 0.185
  txres@txFontColor = "black"
  gsn_text_ndc(wks,"cal r: "+sprintf("%5.3f",calr(iseas)),xval1,yloc,txres)
  gsn_text_ndc(wks,"val r: "+sprintf("%5.3f",valr(iseas)),xval1+0.1,yloc,txres)
  gsn_text_ndc(wks,"RE: "+sprintf("%5.3f",RE(iseas)),xval1+0.2,yloc,txres)
  gsn_text_ndc(wks,"CE: "+sprintf("%5.3f",CE(iseas)),xval1+0.29,yloc,txres)
  gsn_text_ndc(wks,"# ens: ",xval1,yloc-0.025,txres)
  gsn_text_ndc(wks,"correl w/ obs: ",xval1,yloc2,txres)
  gsn_text_ndc(wks,"correl w/ ensmean: ",xval1,yloc3,txres)
  txres@txFontColor = "red"
  gsn_text_ndc(wks,sprintf("%3.0f",nens(iseas,0)),xval1+0.05,yloc-0.025,txres)
  txres@txFontColor = "blue"
  gsn_text_ndc(wks,sprintf("%7.0f",nens(iseas,1)),xval1+0.1,yloc-0.025,txres)
  
    do i = 0,3
      txres@txFontColor = colors(i)
      xloc3 = (xval1+0.15)+i*0.05  
      gsn_text_ndc(wks,sprintf("%5.3f",correl_obs(i)),xloc3,yloc2,txres)
    end do
    do i = 0,2
      txres@txFontColor = colors(i)
      xloc3 = (xval1+0.15)+i*0.05  
      gsn_text_ndc(wks,sprintf("%5.3f",correl_ensmean(i)),xloc3,yloc3,txres)
    end do
      
 end do


  frame(wks)

  delete(wks)


end