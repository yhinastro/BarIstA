Function YH_FOURIER, intens, theta, mterms = mterms 
;A1 = coef[1], A2 = coef[2], A4 = coef[4]
;B1 = coef[6], B2 = coef[7]

coef = fltarr(10)
coef[*] = 0
num = n_elements(intens)

For m = 0, mterms-1 do begin
Ams = 0 & Bms = 0 & It = 0
 For j = 0L, num-2  do begin  ; num-2
  f1 = intens[j]*cos(m*theta[j]) & g1 = intens[j]*sin(m*theta[j])
  f2 = intens[j+1]*cos(m*theta[j+1]) & g2 = intens[j+1]*sin(m*theta[j+1])
  delta = theta[j+1]-theta[j]
  Am = (f1+f2)*delta*1/2. & Bm = (g1+g2)*delta*1/2.
  Ams = Ams+Am & Bms = Bms+Bm
 Endfor         ;for j
  Ams = Ams/!PI & Bms = Bms/!PI
  IF (m eq 0) then Ams = Ams/2.
  coef[m] = Ams & coef[m+5] = Bms
Endfor          

return, coef
END

