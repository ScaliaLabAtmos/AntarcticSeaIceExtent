begin

ddir2 = "~/OneDrive - Ohio University/sea_ice_recon/extent_recon_sum2021/recons_v4/seas_recon/code_updates/output_data/"
ddir3 = "../total_compare/"
cseas = (/"DJF","MAM","JJA","SON"/)
creg =  (/"Ross","Bellingshausen-Amundsen_Sea","Weddell","King_Hakon","East_Antarctica","totalsie"/)
ctitle = (/"Ross","Bellingshausen-Amundsen","Weddell","King Hakon","East Antarctica","Total"/)

recons = new((/4,5,116/),"float") ;4 seasons x 5 variables x 114 years
  sig1=new((/4,5,87,87/),float)
  slope1=new((/4,5,87,87/),float)    
sectors = new((/5,116/),"float")
delim = " 	"
  sig1 = -999.9
   slope1 = -999.9
  slope1@_FillValue=-999.9
  sig1@_FillValue=-999.9

 recons@_FillValue = -999.9


do iseas = 0,3

  stat_all = asciiread(ddir2+"master/totalsie_recon_master_stats_"+cseas(iseas)+".txt",-1,"string")


  CE_all = stringtofloat(str_get_field(stat_all(2:),9,delim))

;   print(CE_all)
;   exit
   best_check = str_get_field(stat_all(2:),10,delim)
   max_ind = ind(best_check.eq."yes")


   ens_recon_file = "../../code_updates/output_data/ens_recons/totalsie_recon_ensembles_"+cseas(iseas)+".txt"
   ncols = numAsciiCol(ens_recon_file)
   nrow = numAsciiRow(ens_recon_file)
   ens_recon = asciiread(ens_recon_file,(/nrow,ncols/),"float")
   recons(iseas,1,:) = ens_recon(:,max_ind+1)

   sectors = 0.0
   bf_recon = asciiread(ddir2+"best_fit_recons/best_fit_recons_totalsie_"+cseas(iseas)+".txt",-1,"string")
   recons(iseas,0,:)  =  stringtofloat(str_get_field(bf_recon(1:),3,delim))   
;   recons(iseas,1,:)  =  stringtofloat(str_get_field(bf_recon(1:),2,delim)) ;best fit total recon is the highest CE recon after variance checks

   total_ens = asciiread(ddir3+cseas(iseas)+"_summed_total_recon_ensemble_data_updated_helena.txt",-1,"string")
   recons(iseas,2,:) = stringtofloat(str_get_field(total_ens(1:),2,delim))
   recons(iseas,4,:) = stringtofloat(str_get_field(total_ens(1:),3,delim))

   delete([/stat_all,best_check,max_ind,ens_recon,CE_all/])

   do isect = 0,4

  stat_all = asciiread(ddir2+"/master/"+creg(isect)+"_recon_master_stats_"+cseas(iseas)+".txt",-1,"string")


  CE_all = stringtofloat(str_get_field(stat_all(2:),9,delim))
  CE_max = dim_max(CE_all)
;   print("number of rows in master stats...."+dimsizes(CE_all))
   best_check = str_get_field(stat_all(2:),10,delim)
  max_ind = ind(best_check.eq."yes")
;  max_ind = ind(CE_all.eq.CE_max)
   ens_recon_file = "../../code_updates/output_data/ens_recons/"+creg(isect)+"_recon_ensembles_"+cseas(iseas)+".txt"
   ncols = numAsciiCol(ens_recon_file)
   nrow = numAsciiRow(ens_recon_file)
   ens_recon = asciiread(ens_recon_file,(/nrow,ncols/),"float")

   sectors(isect,:) = ens_recon(:,max_ind+1)
   delete([/stat_all,CE_all,best_check,ens_recon/])
   end do
   recons(iseas,3,:) = dim_sum_n(sectors,0)

end do




;  recons(0,:,:112) = recons(0,:,1:113)
;  recons(0,:,113) = recons@_FillValue
;  recons(0,0,73) = recons@_FillValue
  recons = where(recons.lt.0,recons@_FillValue,recons)
  recons_stand = dim_standardize(recons,0)
  time1=ispan(1905,2020,1)
;  printVarSummary(time1)


  do iseas = 0,3
    do ivar = 0,4

  do i = 0,86
   do j = 0,86
  sval = i
  eval = j+29
  diff = eval - sval + 1
  nval = num(.not.ismissing(recons_stand(iseas,ivar,sval:eval)))
  if (diff.ge.30.and.nval.ge.30) then
  
  b1=regline(time1(sval:eval),recons_stand(iseas,ivar,sval:eval))
  df1 = b1@nptxy-2
  prob1 = (betainc(df1/(df1+b1@tval^2),df1/2.0,0.5))

  slope1(iseas,ivar,i,j) = b1*10
  sig1(iseas,ivar,i,j) = 1-prob1
  end if
  end do
  end do
  end do
  end do
  
;  exit

  y1_start = 1905
  y1_end   = 1991
  nyrs1    = y1_end-y1_start+1
  y2_start = 1934
  y2_end   = 2020
  nyrs2    = y2_end-y2_start+1

  y0_start = 1979
  y0_end = 1991
  nyrs0 = y0_end - y0_start+1
  y02_start = 2008
  y02_end = 2020
  nyrs02 = y02_end - y02_start+1

; ---------- Plot parameters ---------- ;
  system("/bin/rm -f totalsie_trends_all_times_composite_v4_revised.ps")
  wks = gsn_open_wks("ps","totalsie_trends_all_times_composite_v4_revised")
  gsn_define_colormap(wks,"ncl_default")    ; choose colormap
  colors = gsn_retrieve_colormap(wks)  ; retrieve color map for editing.
  gsn_define_colormap(wks,colors)

  plot2 = new(20,graphic)



  res                     = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@cnFillOn            = True
  res@cnLinesOn           = False
  res@cnLineLabelsOn      = False
  res@cnInfoLabelOn       = False
 ; res@cnFillColors	  = (/2,7,11,16,21,26,30,35,40,45,50,54,59,64,68,73,78,81,85,87,92,0,146,151,156,161,166,171,177,181,186,191,196,201,206,211,216,221,226,231,236,241/)
  res@gsnSpreadColors     = True
  res@gsnSpreadColorStart   = 2
  res@gsnSpreadColorEnd     = 255
  res@cnMissingValFillColor = "white"
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF      = -1.0
  res@cnMaxLevelValF      =  1.0
  res@cnLevelSpacingF     = .05
  res@cnFillMode          = "RasterFill"
  res@tmXBPrecision       = 4
  res@tmYLPrecision       = 4
  res@gsnStringFontHeightF = 0.035
  res@tmXTOn              = False
  res@tmYROn              = False
  res@tiXAxisString       = "End year"
  res@tiYAxisString       = "Start year"
  res@tiYAxisFontHeightF  = 0.055;0.035
  res@tiXAxisFontHeightF  = 0.055;0.035
  res@lbLabelBarOn        = False
  res@tmXBLabelFontHeightF = 0.05;0.025
  res@tmYLLabelFontHeightF = 0.05;0.025
  res@tmXBLabelAngleF     = 45
  
  res@tmXBMode            = "Explicit"
  res@tmYLMode            = "Explicit"
  res@tmXBMinorOn         = True
  res@tmYLMinorOn         = True
  res@tmYLMajorOutwardLengthF   = 0.04
  res@tmYLMinorOutwardLengthF   = 0.02
  res@tmXBMajorOutwardLengthF   = 0.04
  res@tmXBMinorOutwardLengthF   = 0.02
; ------------------------------------------------------

;  season_list   = (/"DJF","MAM","JJA","SON"/)



  res2 = True
  res2@gsnDraw             = False       ; Do not draw plot
  res2@gsnFrame            = False       ; Do not advance frame
  res2@gsnRightString       = ""             ; turn off special titles
  res2@gsnLeftString        = ""
  res2@tiMainString         = ""
  res2@gsnCenterString      = ""

  res2@cnLinesOn           = False
  res2@cnLineLabelsOn      = False
  res2@cnFillOn 	   = True       ; turn on color/pattern fill
  res2@cnMonoFillPattern   = False      ; allow different patterns
  res2@cnMonoFillColor 	   = True       ; only use one color (black)
  res2@lbLabelBarOn        = False
  res2@cnLevelSelectionMode = "ExplicitLevels" ; set explicit cnlev
  res2@cnLevels   	    = (/.90,0.95/)    ; only have 1 contour level
  res2@cnFillPatterns	    = (/-1,3,17/) ; stipple <0.05, don't fill >=0.05
  res2@cnInfoLabelOn       = False       ; turn off info label




  plot1 = new(20,graphic)
  poly1 = new(20,graphic)
  poly2 = new(20,graphic)

  pres = True
  pres@gsLineColor      = "black"                     ; color of lines
  pres@gsLineThicknessF = 2.0   
 
  poly3 = new(3,graphic)
  poly4 = new(20,graphic)

;  res@gsnStringFontHeightF = 0.05
;  res@gsnCenterStringOrthogonalPosF = 0.07

  do iseas = 0,3 
  do iplot = 0,4

   nplot = iseas*5+iplot

    if(iplot.ge.1)then
  res@sfXArray = ispan(y2_start,y2_end+1,1)-0.5
  res@sfYArray = ispan(y1_start,y1_end+1,1)-0.5

  res2@sfXArray = ispan(y2_start,y2_end+1,1)-0.5
  res2@sfYArray = ispan(y1_start,y1_end+1,1)-0.5
  res@tmXBValues          = ispan(y2_start,y2_end,15)
  res@tmXBLabels          = ispan(y2_start,y2_end,15)
  res@tmXBMinorValues     = ispan(y2_start+5,y2_end-5,5)

  res@tmYLValues          = ispan(y1_start,y1_end,10)
  res@tmYLLabels          = ispan(y1_start,y1_end,10)
  res@tmYLMinorValues     = ispan(y1_start+5,y1_end-5,5)

  pres@sfXArray = ispan(y2_start,y2_end+1,1)-0.5
  pres@sfYArray = ispan(y1_start,y1_end+1,1)-0.5
       plot1(nplot) = gsn_csm_contour(wks,slope1(iseas,iplot,:,:),res)
       plot2(nplot) = gsn_csm_contour(wks,sig1(iseas,iplot,:,:),res2)
       overlay(plot1(nplot),plot2(nplot))

       poly1(nplot)=gsn_add_polyline(wks,plot1(nplot),(/2008,2020/),(/1979,1979/),pres)
       poly2(nplot)=gsn_add_polyline(wks,plot1(nplot),(/2008,2008/),(/1979,1991/),pres)
       poly4(nplot) = gsn_add_polyline(wks,plot1(nplot),(/1934,2020/),(/1905,1991/),pres)
    else

  res@sfXArray = ispan(y02_start,y02_end+1,1)-0.5
  res@sfYArray = ispan(y0_start,y0_end+1,1)-0.5

  res2@sfXArray = ispan(y02_start,y02_end+1,1)-0.5
  res2@sfYArray = ispan(y0_start,y0_end+1,1)-0.5
  res@tmXBValues          = ispan(y02_start,y02_end,2)
  res@tmXBLabels          = ispan(y02_start,y02_end,2)
  res@tmXBMinorValues     = ispan(y02_start+5,y02_end-5,1)

  res@tmYLValues          = ispan(y0_start,y0_end,2)
  res@tmYLLabels          = ispan(y0_start,y0_end,2)
  res@tmYLMinorValues     = ispan(y0_start+5,y0_end-5,1)

  pres@sfXArray = ispan(y02_start,y02_end+1,1)-0.5
  pres@sfYArray = ispan(y0_start,y0_end+1,1)-0.5
       plot1(nplot) = gsn_csm_contour(wks,slope1(iseas,iplot,74:,74:),res)
       plot2(nplot) = gsn_csm_contour(wks,sig1(iseas,iplot,74:,74:),res2)
       overlay(plot1(nplot),plot2(nplot))

       poly4(nplot) = gsn_add_polyline(wks,plot1(nplot),(/2008,2020/),(/1979,1991/),pres)
    end if

  delete([/res@sfXArray,res@sfYArray,res2@sfXArray,res2@sfYArray,res@tmXBValues,res@tmYLValues,res@tmXBLabels,res@tmYLLabels/])
  delete([/res@tmXBMinorValues,res@tmYLMinorValues,pres@sfXArray,pres@sfYArray/])

end do
end do
;   poly3(0) = gsn_add_polyline(wks,plot1(0),(/1945,1960/),(/1965,1950/),pres)
;   poly3(1) = gsn_add_polyline(wks,plot1(0),(/1960,1960/),(/1950,1955/),pres)
;   poly3(2) = gsn_add_polyline(wks,plot1(0),(/1955,1960/),(/1950,1950/),pres)

;=========================================================

  txres               = True
  txres@txJust        = "CenterCenter"
  txres@txFontColor   = "black"
  txres@txFontHeightF = 0.016
  txres@txAngleF      = 90.
  txres@tfPolyDrawOrder = "postdraw"

;  gsn_text_ndc(wks,"~F22~60-90S",0.015,0.83,txres)
;  gsn_text_ndc(wks,"~F22~East Antarctica",0.015,0.58,txres)
;  gsn_text_ndc(wks,"~F22~West Antarctica",0.015,0.33,txres)

  txres@txFontHeightF = 0.03
  txres@txAngleF      = 0.

  txres@txJust        = "CenterLeft"
;  dum = gsn_add_text(wks,plot1(0),"Shorter Periods",1940,1970,txres)
  txres@txJust        = "CenterRight"
;  dum1 = gsn_add_text(wks,plot1(0),"Longer Periods",1972,1946,txres)

  txres@txAngleF      = 45.
  txres@txJust        = "CenterLeft"
;  dum2 = gsn_add_text(wks,plot1(1),"30-year Trends",1954,1944,txres)

;  txres@txAngleF      = 90.
;  txres@txJust        = "BottomLeft"
;  dum3 = gsn_add_text(wks,plot1(2),"Observed",1974,1957,txres)
;  dum4 = gsn_add_text(wks,plot1(2),"Period",1979,1957,txres)
;=========================================================

  resPanel                     = True
  resPanel@gsnMaximize         = True
  resPanel@gsnPanelLabelBar    = True
  resPanel@gsnPaperOrientation = "portrait"
  resPanel@lbOrientation       = "horizontal"
  resPanel@lbLabelAutoStride   = True
  resPanel@lbLabelStride       = 5
  resPanel@pmLabelBarHeightF   = 0.07
  resPanel@pmLabelBarWidthF    = 0.43
  resPanel@lbLabelFontHeightF  = 0.012
  resPanel@lbBoxLinesOn        = False
  resPanel@gsnPanelBottom      = 0.1
  resPanel@gsnPanelTop         = 0.95
  resPanel@gsnPanelLeft        = 0.03
  resPanel@lbTitleFontHeightF  = .014                 ; make title smaller
  resPanel@pmLabelBarOrthogonalPosF = -.02           ; move whole thing down
  resPanel@gsnPanelXWhiteSpacePercent = 3
  resPanel@gsnPanelYWhiteSpacePercent = 5
  resPanel@lbTitleString       = "Sea Ice Extent trends (stand dev decade~S~-1~N~)"
;  resPanel@gsnPanelFigureStrings    = (/"a) Obs","b) Best Fit~C~Recon","c) Best Fit~C~Summed~C~Recon","d) Sum of Best~C~Fit Sector~C~Recons","e) Ensemble~C~Mean","f) Obs","g) Best Fit~C~Recon","h) Best Fit~C~Summed~C~Recon","i) Sum of Best~C~Fit Sector~C~Recons","j) Ensemble~C~Mean","k) Obs","l) Best Fit~C~Recon","m) Best Fit~C~Summed~C~Recon","n)Sum of Best~C~Fit Sector~C~Recons","o) Ensemble~C~Mean","p) Obs","q) Best Fit~C~Recon","r) Best Fit~C~Summed~C~Recon","s) Sum of Best~C~Fit Sector~C~Recons","t) Ensemble~C~Mean"/)
  resPanel@gsnPanelFigureStrings    = (/"a)","b)","c)","d)","e)","f)","g)","h)","i)","j)","k)","l)","m)","n)","o)","p)","q)","r)","s)","t)"/)
  resPanel@amJust                   = "TopLeft"
  resPanel@gsnPanelFigureStringsBackgroundFillColor = "transparent"
  resPanel@gsnPanelFigureStringsFontHeightF = 0.015
  resPanel@gsnPanelFigureStringsPerimOn = False

fxres               = True                     ; text mods desired
fxres@txFontHeightF = 0.02		       ; font smaller. default big
fxres@txFont        = "helvetica-bold"
;drawNDCGrid(wks)
gsn_text_ndc(wks, "Antarctic Total Sea Ice Extent Seasonal Time-Varying Trends",0.50,0.97,fxres)

fxres@txFont = "helvetica"
fxres@txFontHeightF = 0.015
fxres@txAngleF = 90.

gsn_text_ndc(wks,"DJF",0.02,0.845,fxres)
gsn_text_ndc(wks,"MAM",0.02,0.6625,fxres)
gsn_text_ndc(wks,"JJA",0.02,0.48,fxres)
gsn_text_ndc(wks,"SON",0.02,0.2975,fxres)

fxres@txFontHeightF = 0.013
fxres@txAngleF = 0.
fxres@txJust  = "CenterCenter"

gsn_text_ndc(wks,"Observations",0.155,0.91,fxres)
gsn_text_ndc(wks,"Best Fit Recon",.35,.91,fxres)
gsn_text_ndc(wks,"      Best Fit ~C~Summed Recon",0.54,0.92,fxres)
gsn_text_ndc(wks,"Sum of Best Fit ~C~Sector Recons",.74,0.92,fxres)
gsn_text_ndc(wks,"Ensemble Mean",0.93,0.91,fxres)

;drawNDCGrid(wks)
  gsn_panel(wks,plot1,(/4,5/),resPanel)



end
