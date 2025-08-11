Function barista_cut_qtcake, input_Qtcake = Qtcake, cent = peak, R25 = R25, cri = cri, cutlim = cutlim, Qtcake_nb, r_Qb, radi, r_bulge, max_r_all, ratio_firmin, Qtr_class, del_Qt, Qt_cutcake, n_peaks, peakloca, Qb, Bar_class, px, py, option = option

;2025/08/11/Mon by yhlee ========================
;This step is the second part for measuring bar strength Qb in BarIstA pipeline
;This routine analyzes the force ratio map (Qtcake) and returns various 
;parameters such as bar strength (Qb), bar length (r_Qb),peak locations, torque profile classifications, and azimuthal structure metrics. 
;When interpreted properly, these parameters provide valuable diagnostics 
;for characterizing the properties of galactic bars.
 
;--- Required Input Parameters ---
;input_Qtcake = 2D ratio map of tangential-to-radial forces (output from barista_bake_qtcake)
;cent         = Galaxy center of deprojected image as [xcent, ycent]
;R25          = Outer reference radius for the analysis
;cri          = Criterion for handling cases with secondary bars or strong spiral arms 
;               (default: 0.15). If the ratio_firmin value exceeds cri, the routine checks 
;               for the presence of a secondary bar within the min_r region.
;cutlim       = Threshold for counting peaks in the azimuthal profile (default: 0.05)
;option       = 'plot' to plot the azimuthal profile, 'no' to suppress plotting

;--- Output -----------------------
;The main outputs of this routine are threefold: (1) Qtcake_nb, (2) Qt_r, and (3) Qt_cutcake, which correspond sequentially from top to bottom panels in the Force Ratio Map column of Figure 6(e) in Lee et al. (2025).
;The parameters below the main outputs serve to further describe and characterize each main output.

;1.Qtcake_nb  = Ratio map (Q_T) in which the bulge-dominated region is set to zero 
;               to better visualize the disk-dominated region, including the bar. 
;               The force ratio maps shown in Lee et al. (2020, 2025) correspond 
;               to Qtcake_nb.
;r_Qb         = Bar length (r_Qb = max_r+r0)

;2.Qt_r       = Qt radial profile 
;radi         = Radius values corresponding to each point in the Q_T radial profile
;r_bulge      = radius of the bulge-dominated region boundary
;max_r_all    = Indices of all maxima in the Q_T profile
;ratio_firmin = Radius (in units of R25) of the first minimum in the Q_T profile
;Qtr_class    = Classification of the Q_T radial profile:  
;               'M' type indicates the presence of a clear maximum at a location where a bar is
;                likely, while 'P' type indicates a plateau in the Q_T profile at that location.
;del_Qt       = Difference between max and min Q_T in the radial profile

;3.Qt_cutcake = 1D azimuthal profile extracted from Qtcake at the peak radius
;n_peaks      = Number of peaks at r_Qb
;peakloca     = Index of the azimuthal peak location in the Q_T profile
;Qb           = Bar strength value 
;Bar_class    = Bar classification ('SA', 'SAB', 'SB')
;px, py       = Cartesian coordinates of peaks in the azimuthal profile
;               When overplotted on the image, they indicate the location of the bar segment with the highest strength in the galaxy.

;--- Example Usage ----------------
;Qt_r = barista_cut_qtcake(input_Qtcake = Qtcake, input_cent = peak, R25 = R25, $
;                          cri = 0.15, cutlim = 0.05, Qtcake_nb, r_Qb, $
;                          r_bulge, max_r_all, ratio_firmin, Qtr_class, del_Qt, $
;                          Qt_cutcake, n_peaks, peakloca, Qb, Bar_class, px, py, option = 'no')

;--- Notes ------------------------
;1. 'cri' and 'cutlim' are tuning parameters to prevent false identification 
;   of bar length in the presence of spiral arms or secondary bars.
;2. Bar_class thresholds (SA/SAB/SB) are typically defined based on Qb value 
;   (e.g., SA: Qb < 0.15; SAB: 0.15 ≤ Qb < 0.25; SB: Qb ≥ 0.25).

;--- References --------------------
;For detailed explanation of the calculation methods and parameter definitions, 
;see:
; 1) Lee et al. (2020), "Bar Classification Based on the Potential Map"
; 2) Lee et al. (2025), "Search for Slow Bars in Two Barred Galaxies with 
;    Nuclear Structures: NGC 6951 and NGC 7716"

;--- Example of how to use the output parameters, similar to Fig. 6(e) in Lee et al. (2025)
;loadct, 0
;Plotimage, bytscl(Qtcake_nb), $
;     position = [0.07+0.23*3, 0.83-0.15*2, 0.24+0.23*3, 0.95-0.15*2], $
;     xran = [0, R25], title = 'Force ratio map', $
;     xtitle = 'r (pixel)', ytitle = textoidl('\phi (degree)'), $
;     xst = 1, yst = 1, charthick = cht, charsize = chs, /noerase
;loadct, 3
;Oplot, [r_Qb, r_Qb], [0, 359], linestyle = 0, thick = cht, color = 150

;loadct, 0
;Plot, radi, Qt_r, xst = 1, yst = 1, $
;    position = [0.07+0.23*3, 0.56-0.14, 0.24+0.23*3, 0.64-0.14], $
;    xran = [0, R25], yran = [0, 0.5], $
;    title = condi, xtitle = 'r [pixel]', ytitle = '<Q!Dt!N(r)>', $
;    charthick = cht, charsize = 0.6, /noerase, /nodata
;Oplot, radi, Qt_r, thick = cht
;loadct, 3
;Oplot, [r_Qb, r_Qb], [0, 1], linestyle = 0, thick = cht, $
;    color = 150
;Oplot, [r_bulge, r_bulge], [0, 1], linestyle = 1, thick = cht, $
;    color = 150
;XYouts, 0.6*R25, 0.4, 'r!DQb!N = '+string(r_Qb, format = '(F5.2)'), color = 150, charsize = 0.6, charthick = 3

;cutcake ----
;xp = Indgen(360)
;loadct, 0
;Plot, xp, Qt_cutcake, xst = 1, yst = 1, yran = [0, 0.8], $
;thick = 2, charsize = 0.6, charthick = 2, $
;xtitle = textoidl('\phi [degree]'), ytitle = 'Q!Dt', $
;position = [0.07+0.23*3, 0.47-0.16, 0.24+0.23*3, 0.55-0.16], $
;/noerase
;loadct, 3
;Oplot, [0, 360], [cutlim, cutlim], linestyle = 1, thick = 2, color = 150
;XYouts, 360*0.55, 0.55, $
;        'Q!Db!N = '+string(Qb, format = '(F5.2)'), $
;        charsize = chs, charthick = cht, color = 150
;XYouts, 360*0.55, 0.65, Bar_class, charsize = chs, charthick = cht, color = 150
;XYouts, 360*0.75, 0.65, Qtr_class, charsize = chs, charthick = cht, color = 150

;loadct, 0
;Plotimage, bytscl(d_img), $
;position = [0.07+0.23*2, 0.83-0.15*2, 0.24+0.23*2, 0.95-0.15*2], $
;xran = [cent[0]-imz, cent[0]+imz], $
;yran = [cent[1]-imz, cent[1]+imz], $
;title = title, $
;xst = 1, yst = 1, charthick = cht, charsize = chs, /noerase
;loadct, 3
;Oplot, px, py, psym = 1, symsize = 0.4, thick = 2, color = 150
;loadct, 3
;Oplot, [cent[0], cent[0]], [cent[1], cent[1]], psym = 1, symsize = 0.4, thick = 2, color = 150
;================================================

;---(0) cut r = 0 -----------
r0 = 1
sz1 = size(Qtcake)
Qtmap = Fltarr(sz1[1]-r0, sz1[2])
sz2 = size(Qtmap)
Qtmap = Qtcake[r0:sz1[1]-1, 0:sz1[2]-1]

;---(1) mean Qt_r -----------
radi = Findgen(sz2[1])+1
Qt_r = Fltarr(sz2[1])
If (sz2[1] lt 5) then goto, out
 For p = 0L, sz2[1]-1 do begin
  Qt_r[p] = mean(Qtmap[p,*])
 EndFor

;---(2) local maxima & minima of Qt_r 
;box = R25/10.
box = 5 
Qt_rs = smooth(Qt_r, box, /edge_truncate)
;Qt_rs = Qt_r
YH_maxmin, Qt_rs, localmax, localmin
max_r_all = localmax
If (localmin[0] gt localmax[0]) then firstmin = r0 Else firstmin = localmin[0]
n_max = n_elements(localmax)
print, 'n(max)', n_max
print, 'localmax', localmax
print, 'localmin', localmin

;differential
a1 = deriv(Qt_rs)
a2 = deriv(a1)
;print, a2
;box = 5
;a2_s = smooth(a2, box, /edge_truncate)
;print, 'a1', a1
;print, 'a2', a2
YH_maxmin, a2, amax, amin
;print, 'max', amax
;print, 'min', amin
index = where(a2[amax] eq max(a2[amax]))
If (index eq -1) then goto, out
firstcurve = amax[index]
print, 'firstcurve', firstcurve 

;loadct, 0
;Plot, radi_q2, Qt_r, xst = 1, yst = 1, $
;    position = [0.07+0.23*2, 0.3-0.16, 0.24+0.23*2, 0.95-0.16], $
;    xran = [0, R25], yran = [0, 0.5], $
;    title = condi, xtitle = 'r (pixel)', ytitle = '<Q!Dt!N(r)>', $
;    charthick = cht, charsize = 0.6, /noerase, /nodata
;Oplot, radi_q2, Qt_r, thick = cht

;maxcurve for cut_r
;print, amin, firstcurve
index = where(amin gt firstcurve[0], nin)
If (nin ne 0) then maxcurve = amin[index[0]] Else maxcurve = amin[0]
;print, amax
;print, amin
;print, a2[amin]
print, 'maxcurve', maxcurve

;local minimum in order to extract the nucleus region overstimated.

;---(3) classification -------
ratio_firmin = firstmin/R25
print, firstmin
print, ratio_firmin

If (ratio_firmin le cri and localmax[0] ne 0) then begin
 Qtr_class = 'M' & nm = n_max-1 < 1 
 min_r = firstmin & max_r0 = localmax
EndIf Else begin
 Qtr_class = 'P' & nm =1 
 min_r = firstcurve
 If (localmax[0] eq 0) then begin
  max_r0 = maxcurve & nm = 0
 EndIf Else max_r0 = [maxcurve, localmax[0]]
EndElse
print, Qtr_class, max_r0

;print, nm
 If (min_r gt max_r0[0]) then goto, out 
 For i = 0L, 0 do begin
  Qt_cutcake0 = YH_cutcake_examine_radi(Qtcake, peak, r0 = r0, min_r = min_r, $
                max_r = max_r0[i], cutlim = cutlim, $
               peakloca0, peaks0, Bar_class0, px0, py0, Qb0, Qtcake_nb0)
  xp = Indgen(360)
; 
If (option eq 'plot') then begin
  loadct, 0
If (i eq 0) then ytitle = 'Q!Dt' Else ytitle = ' '
  Plot, xp, Qt_cutcake0, xst = 1, yst = 1, yran = [0, 0.8], $
  thick = 2, charsize = 0.6, charthick = 2, $
  xtitle = textoidl('\phi (degree)'), ytitle = ytitle, $
;  position = [0.07+0.2*i, 0.83, 0.24+0.2*i, 0.95], /noerase
  POSITION = [0.76, 0.83-0.16*(5+i), 0.93, 0.95-0.16*(5+i)], /noerase
  loadct, 3
  Oplot, xp[peakloca0], Qt_cutcake0[peakloca0], psym = 1, symsize = 0.8, $
  thick = 2, color = 150
;  Oplot, [0, 360], [0.05, 0.05], linestyle = 1, thick = 2, color = 150
;  Legend, ['n(peak)='+string(peaks0, format = '(I0)')], $
;  box = 0, charsize = 0.6, charthick = 2, /top, /left
;  Legend, ['r='+string(max_r0[i], format = '(I0)')], $
;  box = 0, charsize = 0.6, charthick = 2, /top, /right
;  Legend, [string(Qb0, format = '(F5.3)')], $
;  box = 0, pos = [230, 0.65], charsize = 0.6, charthick = 2, /top, /left
;If (i eq 0) then Legend, ['(a)'], box = 0, charsize = 0.7, charthick = 2, /top, /left
;If (i eq 1) then Legend, ['(b)'], box = 0, charsize = 0.7, charthick = 2, /top, /left
EndIf

;output
 If (i eq 0) then begin 
  peakloca = peakloca0 & peaks = peaks0 & Bar_class = Bar_class0
  px = px0 & py = py0 & Qb = Qb0 & Qtcake_nb = Qtcake_nb0
  Qt_cutcake = Qt_cutcake0 & max_r = max_r0[i]
 EndIf Else begin
  If ((peaks eq 4 and peaks0 eq 4) and (Qb0 gt Qb)) then begin 
   peakloca = peakloca0 & peaks = peaks0 & Bar_class = Bar_class0
   px = px0 & py = py0 & Qb = Qb0 & Qtcake_nb = Qtcake_nb0
   Qt_cutcake = Qt_cutcake0 & max_r = max_r0[i]
  EndIf
  If (peaks ne 4 and peaks0 eq 4) then begin
   peakloca = peakloca0 & peaks = peaks0 & Bar_class = Bar_class0
   px = px0 & py = py0 & Qb = Qb0 & Qtcake_nb = Qtcake_nb0
   Qt_cutcake = Qt_cutcake0 & max_r = max_r0[i]
  EndIf
nd0 = abs(peaks0 - 4)
nd = abs(peaks - 4)
  If ((peaks ne 4 and peaks0 ne 4) and (nd0 le nd)) then begin 
   peakloca = peakloca0 & peaks = peaks0 & Bar_class = Bar_class0
   px = px0 & py = py0 & Qb = Qb0 & Qtcake_nb = Qtcake_nb0
   Qt_cutcake = Qt_cutcake0 & max_r = max_r0[i]
  EndIf
 EndElse

 EndFor
  del_Qt = Qt_rs[max_r]-Qt_rs[min_r]
;print, 'here', max_r, min_r
;print, del_Qt
;help, del_Qt
 If (Qtr_class eq 'M' and del_Qt le 0.) then Qtr_class = 'P'  


r_Qb = radi[max_r]
r_bulge = radi[min_r]
Return, Qt_rs
OUT:
END
