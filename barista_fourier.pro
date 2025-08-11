Function barista_fourier, input_img = img, cent = centro, R25 = ep, $
   radi, Pi2, Pi4

;2025/08/11/Mon by yhlee ========================
;This routine computes Fourier amplitude and phase profiles of a galaxy image
;using concentric elliptical annuli, typically after deprojection.
;The analysis is used to characterize bar length and strength.

;--- Required Input Parameters ---
;input_img  = 2D array containing the galaxy image 
;             (shoud be masked and deprojected)
;cent       = Galaxy center as [xcent, ycent]
;R25        = Outer reference radius (e.g., semi-major axis of outermost fitted ellipse)

;--- Output -----------------------
;A2         = 1D array of normalized Fourier m=2 amplitudes as a function of radius (A2 = abs(a_2^2+b_2^2)/a_0)
;radi       = 1D array of semi-major axis lengths at which Fourier components are measured (in pixels, covering the range from center to R25)
;Pi2        = 1D array of m=2 phase angles 
;Pi4        = 1D array of m=4 phase angles

;--- Example Usage ----------------
;A2 = barista_fourier(input_img = img, cent = cent, R25 = R25, radi, Pi2, Pi4)
;================================================


xcenter = centro[0]
ycenter = centro[1]

x = indgen(359)
y = fltarr(260)  

sp = 3
rn = ep-(sp+1)+1 & ra = sp 


n = 0 & ra = sp 

;print, rn, mterms
radi = fltarr(rn)
Pi2 = fltarr(rn) & Pi4 = fltarr(rn)
A2_fft = fltarr(rn)


For j = sp, ep-1 do begin
ra = ra + 1
;print, j, ra, n, rn
radi[n] = ra
If (ra ge ep) then goto, out

;---(1) circular azimuthal profile
cirazi = fltarr(3,360)

 For k = 0L, 360-1 do begin
  cirazi[0,k] = k*!PI/180
  px = radi[n]*cos(cirazi[0,k])+xcenter
  py = radi[n]*sin(cirazi[0,k])+ycenter
  azi_v = BILINEAR(img,px,py)
  cirazi[1,k] = azi_v
  If (n_elements(zero) ne 0) then $
  cirazi[2,k] = -2.5*alog10((azi_v/(exptime*(resolution^2.)))*gtran)
 Endfor ;For k

;---(2) Fourier series -------
;using FFT
spectrum = FFT(cirazi[1,*])
a2 = real_part(spectrum[2])
b2 = imaginary(spectrum[2])
a4 = real_part(spectrum[4])
b4 = imaginary(spectrum[4])
A2_fft[n] = abs(spectrum[2])/float(spectrum[0])
Pi2[n] = 180/!Pi*atan(b2/a2)
Pi4[n] = 180/!Pi*atan(b4/a4)
;print, n, Pi2[n], Pi4[n]

n = n+1
 If (n ge rn) then goto, out
Endfor  ;For j(radius)
out:

;arrange Pi2
For k = 0L, 4 do begin
 Pi1 = Pi2[0:n-2]
 Pi3 = Pi2[1:n-1]
 diff = abs(Pi3-Pi1)
 din = where(diff gt 90, dnum)
 If (dnum eq 0) then goto, okay 
  If (Pi2[din[0]] lt 0) then cor = -180 Else cor = 180
  If (dnum eq 1) then x2 = n-1 Else x2 = din[1] 
  Pi2[din[0]+1:x2] = Pi2[din[0]+1:x2]+cor[0]
EndFor ; For k
OKAY:

Return, A2_fft
END
