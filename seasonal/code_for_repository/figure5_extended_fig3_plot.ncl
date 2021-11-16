;***********************************************************
; pdf_1.ncl
;
; Concepts illustrated:
;   - Generating univariate probability distributions
;   - Generating PDFs of each sample distribution
;   - Paneling two plots horizontally on a page
;***********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   

begin
  ddir = "/Users/fogtr/OneDrive - Ohio University/sea_ice_recon/extent_recon_sum2021/recons_v4/seas_recon/analysis/total_compare/total_ens_ncfiles"
ddir2 = "~/OneDrive - Ohio University/sea_ice_recon/extent_recon_sum2021/recons_v4/seas_recon/code_updates/output_data/"
cseas = (/"DJF","MAM","JJA","SON"/)
delim = " 	"

nbin = 20
nbin_obs = 20

opt = True
opt@bin_min = -2.5
opt@bin_max = 2.5

  plot    = new (4, "graphic")
  plot2 = new(4,"graphic")
;  dum = new((/4,3/),graphic)
;  dum2 = new((/4,3/),graphic)
  dum1 = new(4,"graphic")
  dum2 = new(4,"graphic")
  dum3 = new(4,"graphic")
  dum4 = new(4,"graphic")
  dum5 = new(4,"graphic")
  dum6 = new(4,"graphic")
  
;  system("/bin/rm -f test_pdf_diffs_1yr.ps")
  wks  = gsn_open_wks ("ps","test_pdf_diffs_1yr_revised_final")             ; send graphics to PNG file
;  system("/bin/rm -f test_pdf_diffs_2yr.ps")
  wks2  = gsn_open_wks ("ps","test_pdf_diffs_2yr_revised_final")             ; send graphics to PNG file
 
  res  = True
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@xyLineThicknessF       = 2
  res@tiYAxisString          = "PDF (%)"
  res@tiXAxisString          = "Sea Ice Extent Difference (x10^6 km^2)"
;  res@trXminF = -5
;  res@trXmaxF = 5
;  res@trYminF = 0
;  res@trYmaxF = 50

  year = ispan(1979,2020,1) 

do iseas = 0,3

   bf_recon = asciiread(ddir2+"best_fit_recons/best_fit_recons_totalsie_"+cseas(iseas)+".txt",-1,"string")
   obs  =  stringtofloat(str_get_field(bf_recon(1:),3,delim))   
   obs79 = obs(74:)
   obs792 = obs79
   r2obs = runave(obs79,2,0)
   r2obs2 = r2obs
   r2obs2(:39) = r2obs(2:)
   obs792(:40) = obs79(1:)
   r2obs2(40:) = r2obs2@_FillValue
   obs_diff = obs79 - obs792
   obs_diff = obs_diff*-1.0
   obs_diff2 = (r2obs - r2obs2)*-1.0

   maxobs = max(obs_diff)
   minobs = min(obs_diff)
   imax = ind(obs_diff.eq.maxobs)
   imin = ind(obs_diff.eq.minobs)
   years_mina = year(imin)
   years_minb = year(imin+1)+"-"
   years_maxa = year(imax)
   years_maxb = year(imax+1)+"-"

   maxobs2 = max(obs_diff2)
   minobs2 = min(obs_diff2)
   imax2 = ind(obs_diff2.eq.maxobs2)
   imin2 = ind(obs_diff2.eq.minobs2)
   years_min2a = year(imin2)+"-"+year(imin2+1)
   years_min2b = year(imin2+2)+"-"+year(imin2+3)+" vs "
   years_max2a = year(imax2)+"-"+year(imax2+1)
   years_max2b = year(imax2+2)+"-"+year(imax2+3)+" vs "
   print(cseas(iseas)+" 1yr max diff = "+maxobs+" "+years_maxb+years_maxa)
   print(cseas(iseas)+" 1yr min diff = "+minobs+" "+years_minb+years_mina)

   print(cseas(iseas)+" 2yr max diff = "+maxobs2+" "+years_max2b+years_max2a)
   print(cseas(iseas)+" 2yr min diff = "+minobs2+" "+years_min2b+years_min2a)

;   exit

  in1 = addfile(ddir+"/total_sea_ice_ensembles_"+cseas(iseas)+"_updated_helena.nc","r")
  ens = in1->ens_recons

  ens1 = ens
  ens1(:,:114) = ens(:,1:)
  ens1(:,115) = ens@_FillValue
  diff = ens - ens1
  diff = diff*-1.0  
  ens2 = runave(ens,2,0)
  ens22 = ens2
  ens22(:,:113) = ens2(:,2:)
  ens22(:,114:) = ens@_FillValue
  diff2 = (ens2 - ens22)*-1.0



  ens79 = ens(:,74:)
  ens1_79 = ens79
  ens1_79(:,:40) = ens79(:,1:)
  diff79 = ens79 - ens1_79
  diff79 = diff79*-1.0
  ens792 = runave(ens79,2,0)
  ens7922 = ens792
  ens7922(:,:39) = ens792(:,2:)
  ens7922(:,40:) = ens2@_FillValue
  diff792 = (ens792 - ens7922)*-1.0


  pdf_diff = pdfx(diff,nbin,opt)
  pdf_diff79 = pdfx(diff79,nbin,opt)
  pdf_obs = pdfx(obs_diff,nbin_obs,opt)
;  printVarSummary(pdf_diff)
;  printVarSummary(pdf_diff79)

;  exit
  pdf_diff2 = pdfx(diff2,nbin,opt)
  pdf_diff792 = pdfx(diff792,nbin,opt)
  pdf_obs2 = pdfx(obs_diff2,nbin_obs,opt)

  print(pdf_obs2@bin_center+" "+pdf_obs2)
  
;  printVarSummary(pdf_obs)
;  printVarSummary(pdf_obs2)
;  pdf_obs2 = pdf_obs*.4
;  pdf_obs = pdf_obs*.4

;  = pdfx(a, 0, False)    ; default number of bins
;  bp  = pdfx(b, 0, False)   
;  cp  = pdfx(c, 0, False)   

;------------------------------------------------
; Plot each PDF
;------------------------------------------------

  plotmid = new(1,graphic)
  plottop = new(1,graphic)
  plotmid2 = new(1,graphic)
  plottop2 = new(1,graphic)

  res@trYMaxF = 40
  
  res@gsnXYBarChart = False
  res@tmXTOn = False
  res@xyLineColor = "Blue"
  plot(iseas) = gsn_csm_xy (wks, pdf_diff@bin_center, pdf_diff, res)
  plot2(iseas) = gsn_csm_xy (wks2, pdf_diff2@bin_center, pdf_diff2, res)
  res@xyLineColor = "Red"
  plotmid = gsn_csm_xy (wks, pdf_diff79@bin_center, pdf_diff79, res)
  plotmid2 = gsn_csm_xy (wks2, pdf_diff792@bin_center, pdf_diff792, res)
  res@xyLineColor = "Black"
  res@gsnXYBarChart = True
  res@gsnXYBarChartOutlineOnly = False
  plottop = gsn_csm_xy (wks, pdf_obs@bin_center, pdf_obs, res)
  plottop2 = gsn_csm_xy (wks2, pdf_obs2@bin_center, pdf_obs2, res)
  overlay(plot(iseas),plotmid)
  overlay(plot(iseas),plottop)
  overlay(plot2(iseas),plotmid2)
  overlay(plot2(iseas),plottop2)

  yrange = (/0,40/)

  txres = True


  res1 = True
  res1@gsLineColor = "black"
  res1@gsLineDashPattern = 0
  dum1(iseas) = gsn_add_polyline(wks,plot(iseas),(/0.,0./),yrange,res1)
  dum2(iseas) = gsn_add_polyline(wks2,plot2(iseas),(/0.,0./),yrange,res1)
  res1@gsLineDashPattern = 1
  res1@gsLineColor = "gray30"
  res1@gsLineThicknessF = 1
  dum3(iseas) = gsn_add_polyline(wks,plot(iseas),(/maxobs,maxobs/),yrange,res1)
  dum4(iseas) = gsn_add_polyline(wks,plot(iseas),(/minobs,minobs/),yrange,res1)
  dum5(iseas) = gsn_add_polyline(wks2,plot2(iseas),(/maxobs2,maxobs2/),yrange,res1)
  dum6(iseas) = gsn_add_polyline(wks2,plot2(iseas),(/minobs2,minobs2/),yrange,res1)

  txres@txFont = "helvetica"
  txres@txFontHeightF = 0.02
  txres@txPerimColor = "transparent"
  txres@txBackgroundFillColor = "white"  
  
  text1 = gsn_add_text(wks,plot(iseas),years_minb,-2.,35,txres)
  text2 = gsn_add_text(wks,plot(iseas),years_maxb,2.,35,txres)
  text1 = gsn_add_text(wks,plot(iseas),years_mina,-2.,32,txres)
  text2 = gsn_add_text(wks,plot(iseas),years_maxa,2.,32,txres)
  text3 = gsn_add_text(wks2,plot2(iseas),years_min2b,-2.,35,txres)
  text4 = gsn_add_text(wks2,plot2(iseas),years_max2b,2.,35,txres)
  text3 = gsn_add_text(wks2,plot2(iseas),years_min2a,-2.,32,txres)
  text4 = gsn_add_text(wks2,plot2(iseas),years_max2a,2.,32,txres)

  delete([/ens,ens1,diff,ens79,ens1_79,diff79/])
  delete([/ens2,ens22,diff2,ens792,ens7922,diff792/])
;  delete([/dum1,dum2,dum3,dum4,dum5,dum6/])

  end do

;  drawNDCGrid(wks)

  
  txres@txFontHeightF = 0.015
  txres@txJust ="CenterLeft"

  xvals = (/0.175,0.58,0.175,0.58/)
  yvals = (/0.87,0.87,0.435,0.435/)
  clab = (/"a) ","b) ","c) ","d) "/)

  do iseas = 0,3
  gsn_text_ndc(wks,clab(iseas)+cseas(iseas),xvals(iseas),yvals(iseas),txres)
  gsn_text_ndc(wks2,clab(iseas)+cseas(iseas),xvals(iseas),yvals(iseas),txres)
  end do

  txres@txFontHeightF = 0.02
    txres@txJust ="CenterCenter"
  gsn_text_ndc(wks,"Consecutive One year Differences",0.5,0.955,txres)
  gsn_text_ndc(wks,"Antarctic Total Sea Ice Extent",0.5,0.92,txres)
  gsn_text_ndc(wks2,"Differences in Consecutive Two Year Means",0.5,0.955,txres)
  gsn_text_ndc(wks2,"Antarctic Total Sea Ice Extent",0.5,0.92,txres)

  wnres = True
  wnres@gsLineThicknessF = 3.0
  wnres@gsLineColor = "Blue"
  gsn_polyline_ndc(wks,(/0.1,0.2/),(/0.02,0.02/),wnres)
  gsn_polyline_ndc(wks2,(/0.1,0.2/),(/0.02,0.02/),wnres)
  wnres@gsLineColor = "Red"
  gsn_polyline_ndc(wks,(/0.4,0.5/),(/0.02,0.02/),wnres)
  gsn_polyline_ndc(wks2,(/0.4,0.5/),(/0.02,0.02/),wnres)
  wnres@gsLineColor = "Black"
  gsn_polyline_ndc(wks,(/0.7,0.8/),(/0.02,0.02/),wnres)
  gsn_polyline_ndc(wks2,(/0.7,0.8/),(/0.02,0.02/),wnres)

  txres@txFontHeightF = 0.015
  txres@txJust ="CenterLeft"

  gsn_text_ndc(wks,"1905-2020",0.21,0.02,txres)
  gsn_text_ndc(wks2,"1905-2020",0.21,0.02,txres)
  gsn_text_ndc(wks,"1979-2020",0.51,0.02,txres)
  gsn_text_ndc(wks2,"1979-2020",0.51,0.02,txres)
  gsn_text_ndc(wks,"Observed",0.81,0.02,txres)
  gsn_text_ndc(wks2,"Observed",0.81,0.02,txres)

  resP    = True
;  resP@gsnPanelMainString    = "PDF differences 1 year"
  resP@gsnPanelTop = 0.9
  resP@gsnPanelBottom = 0.03
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelYWhiteSpacePercent = 10
;  resP@gsnPanelRowSpec       = True              ; tell panel what order to plt
  gsn_panel(wks,plot,(/2,2/),resP)
;  resP@gsnPanelMainString    = "PDF differences 2 years"
  gsn_panel(wks2,plot2,(/2,2/),resP)
end
