Function barista_ellipsefit, input_img = img, result = Fname, cent = cent, $
         fix_cen = fix_cen, step = step, R25 = R25
; magp = magp, R_fin, I_fin, PA_fin, e_fin 
          
;2025/04/10/Thur/by yhlee =======================
;This routine allows you to fit ellipses to a galaxy image in IDL, following the methods of Davis et al. (1985) and Athanassoula et al. (1990).
;One advantage of this routine is that it provides robust ellipse fitting results without requiring initial guesses for the ellipticity or position angle (PA).
;This routine requires the following subroutines:
;YH_ellipazi.pro, YH_fourier.pro, YH_centroid.pro for this routine.

;--- Input Parameters -----
;input_img = 2D array containing the galaxy image
;result    = File name for saving the output
;cent      = X, Y coordinates of the galaxy center, in the form [xcent, ycent] [pixel]
;fix_cent  = Specify 'fix' to keep the center fixed, or 'move' to allow it to vary with radius during fitting 
;step      = Step size in pixels for increasing the radius during ellipse fitting
;R25       = Maximum radius (in pixels) up to which ellipses are fitted

;--- Example Usage ----
;ellipsefit_result = barista_ellipsefit(input_img = img, result = ellipsefit_result, cent = [xc, yc], fix_cent = 'fix', step = 1, R25 = R25)

;--- Output -----
;The routine outputs a text file named 'ellipsefit_result', which contains the following parameters at each radius: 'radius', 'intensity', 'xcent', 'ycent', 'ellipticity', 'PA', 'c', 'A0', 'A1', 'B1', 'A2(e)', 'B2(PA)', 'A4', 'B4'
;=================================================

xcent = cent[0] & ycent = cent[1]

If (N_elements(magp) ne 0) then begin
 zero = magp[0]
 exti = magp[1]
 airmass = magp[2]
 resolution = magp[3]
 exptime = magp[4]
Endif

;--- open the file for the final result ------
eresult = Fname
openw, luna, eresult, /get_lun
printf, luna, 'r','inten', 'xcent', 'ycent', 'e', 'PAc', 'c', $
'A0', 'A1', 'B1', 'A2(e)', 'B2(PA)', 'A4', 'B4', format='(A5,1x,13(A13,2x))'

;===== 1. call the initial parameter   
c = 2.
e = 0.5 & en = 0
PAc = 0 & pn = 0

ra = 1  & rd = R25  ;rd = sc
;=================================

;For each radius
For i = 0L, R25-1  do begin   ;for radius

 estep = 0.3 & Pstep = 20.  
;IRAF step
;ra = ra+ra*0.1
ra = ra+step
print, i, ra, rd
 If (ra ge rd) then goto, bye

 For t = 0, 15 do begin ;for iteration
;===== 2. Iteration ==============
;print, name, ra, t
;print, ec, PAe, xc0, yc0

;---(1) the ellipse azimuthal profile ---------
;ellipse with same interval
  PAc = PAc[0]
  azimuthal = YH_ellipazi(ra, img, PAc[0], xcent, ycent, e[0], c)
  asize = size(azimuthal)
  num = asize[2]
; If (asize[0] eq 0) then goto, bye

;---(2) Fourier analysis:Buie -----------------
;coef = YH_fourier(intens, theta, mterms = mterms)
  coef = YH_fourier(azimuthal[1,*], azimuthal[0,*], mterms = 5)
  inten = coef[0]
;print, i, t, inten
;a0 = coef[0]
;a1 = coef[1] & b1 = coef[6]
;a2 = coef[2] & b2 = coef[7]
;a3 = coef[3]
;a4 = coef[4]

;sig = fltarr(num) & sig[*] = 0.00005
;mterms = 2 
;t3 = systime(1)
;fourfit, azimuthal[0,*], azimuthal[1,*], sig, mterms, coef, csig, yfit=yfit, chisq=chisq
;t4 = systime(1)
;print, coef, t4-t3
;result = coef/coef[0]
 
;noise level
;  If (coef[0] le 0 or Finite(coef[0], /Nan)) then begin 
  If (Finite(coef[0], /Nan)) then begin 
    printf, luna, ra, inten, xcent, ycent, e, PAc, c, coef[0], $
    coef[1]/coef[0], coef[6]/coef[0], coef[2]/coef[0], coef[7]/coef[0], $
    format='(I5,1x,11(F13.7,2x))'
    goto, bye
  Endif

;R25 calculation
  If (n_elements(magp) ne 0) then begin
   I25 = coef[0]
   gtran = 10.^(0.4*(zero[0]+exti[0]*airmass[0]))
   m_a0 = -2.5*alog10((coef[0]/(exptime*(resolution^2.)))*gtran)
;print, ra, t, xcent, ycent, I25, m_a0

   If (m_a0 ge 25) then begin 
    printf, luna, ra, inten, xcent, ycent, e, PAc, c, coef[0], $
    coef[1]/coef[0], coef[6]/coef[0], coef[2]/coef[0], $
    coef[7]/coef[0], coef[4]/coef[0], coef[9]/coef[0], $
    format='(I5,1x,13(F13.7,2x))'
    goto, bye
   Endif
  Endif

;---(3) Decide the exact center -
 result1 = Fltarr(2) 
 result1 = [abs(coef[1]/coef[0]),abs(coef[6]/coef[0])]
;rep1 = where(result1 eq max(result1))

;---(4) Decide the next initial parameter
 result2 = Fltarr(2)
 result2 = [abs(coef[2]/coef[0]),abs(coef[7]/coef[0])]
 rep2 = where(result2 eq max(result2))

 If (max(result2) lt 0.001) then goto, nextr 
;for e
 If (rep2[0] eq 0) then begin
   en = en +1
  If (en gt 1) then estep = estep/2.
   e = e + estep*coef[2]/abs(coef[2])
  If (e gt 0.95) then e = 0.9
  If (e lt 0) then begin
   b = ra
   a = (1-e)*b
   e = (a-b)/a
   PAc = PAc + 90 
 MODI:
   If (PAc gt 180) then PAc = PAc - 180
   If (PAc gt 180) then goto, modi Else goto, okay
 OKAY: 
;print, 'here', a, b, e, PAc
  Endif
; print, 'e', coef[3]/coef[0], estep, e
 Endif
;for PA
 If (rep2 eq 1) then begin
   pn = pn + 1
  If (pn gt 1) then Pstep = Pstep/2.
   PAc = PAc + Pstep*coef[7]/abs(coef[7])
; If (PAc ge 360) then PAc = PAc-360.
; If (PAc gt 180) then PAc = PAc-180
; If (PAc lt -180) then PAc = PAc+180
; print, 'PA', coef[4]/coef[0], Pstep, PAc
  Endif
;print, ra, t, xcent, ycent, e, PAc
;print, result1[0], result1[1]
;print, result2[0], result2[1]

;---(5) rivised the next center
If (fix_cen eq 'move') then begin 
 scope = coef[0]
 center = YH_centroid(img,scope)
 xcent = center[0] & ycent = center[1]
Endif
;=================================
Endfor     ; for t(iteration)
nextr:
printf, luna, ra, inten, xcent, ycent, e, PAc, c, coef[0], $
coef[1]/coef[0], coef[6]/coef[0], coef[2]/coef[0], coef[7]/coef[0], $
coef[4]/coef[0], coef[9]/coef[0], format='(F8.3,1x,13(F13.3,2x))' 
;print, ra, inten, e, PAc
Endfor     ; for n(radius)
bye:
;---(6) output result -------
 R_fin = ra & I_fin = coef[0] & PA_fin = PAc[0] & e_fin = e[0]
 If (R_fin lt 5) then begin
  I_fin = 999 & PA_fin = 999 & e_fin = 999
 Endif

free_lun, luna
close, luna
Return, eresult 
End
