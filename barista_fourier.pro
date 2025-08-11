Function barista_fourier, input_img = img, cent = centro, R25 = ep, $
   radi, amp2, A0, Am2, Bm2, a2fft, I0fft, A2_fft, Pi2, Pi4, reA

;For Fourier analysis @2.searchbar.pro 
;1.Plot azimuthal profile
;2.Calculate relative fourier amplitude
;output: radi & Pi2

xcenter = centro[0]
ycenter = centro[1]

x = indgen(359)
y = fltarr(260)  

sp = 3
rn = 0 & ra = sp 
mterms = 6 

For j = sp, ep-1 do begin
 ra = ra+1
 If (ra ge ep) then goto, out1
 rn = rn+1
EndFor
OUT1:

n = 0 & ra = sp 

;print, rn, mterms
radi = fltarr(rn)
Pi2 = fltarr(rn) & Pi4 = fltarr(rn)
a2fft = fltarr(rn)
I0fft = fltarr(rn)
amp2 = fltarr(rn)
A2_fft = fltarr(rn)
A0 = fltarr(rn)
A2 = fltarr(rn)
Am2 = fltarr(rn)
Bm2 = fltarr(rn)
reA = fltarr(mterms,rn)
Im = fltarr(mterms,rn)


For j = sp, ep-1 do begin
ra = ra+1
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
spectrum = FFT(cirazi[1,*])

num = n_elements(cirazi[1,*])

A0fft = float(spectrum[0]) /num 
A2 = 2 * float(spectrum[2]) /num 
B2 = -2 * imaginary(spectrum[2]) /num 
amp2[n] = sqrt(A2^2 + B2^2)/A0fft

a2fft[n] = abs(float(spectrum[2]))
I0fft[n] = float(spectrum[0])
A2_fft[n] = abs(spectrum[2])/float(spectrum[0])

sig = fltarr(k+1) & sig[*] = 0.00005
fourfit, cirazi[0,*], cirazi[1,*], sig, mterms, coef, csig, $
yfit=yfit, chisq=chisq
;print, j, coef[3]/coef[0], coef[4]/coef[0]
 a2 = coef[3] & b2 = coef[4]
 a4 = coef[7] & b4 = coef[8]
print, float(spectrum[2]), coef[3]
 Am2[n] = abs(coef[3])
; Am2[n] = sqrt(a2^2.+b2^2.)/coef[0]
; Am4[n] = abs(coef[7]/coef[0])
 A0[n] = coef[0]
 Bm2[n] = abs(coef[4]/coef[0])
 Pi2[n] = 180/!Pi*atan(coef[4]/coef[3])
 Pi4[n] = 180/!Pi*atan(coef[8]/coef[7])

;---(3) Fourier amplitude ----
m = 0 & thet = cirazi[0,3]

; For l = 0L, mterms*2-1, 2 do begin
;  Ams = coef[l+1] & Bms = coef[l+2]
;  I0 = coef[0] & Im[m,n] = SQRT(Ams^2+Bms^2)
;  reA[m,n] = Im[m,n]/I0
;  m = m+1
; Endfor ;For l


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

Return, Am2
END
