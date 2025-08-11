Function YH_ellipazi, radius, img, PAc, xc, yc, e, c

;ellipse azimuthal profile with same interval
;not write the azimuthal text file
;2010/09/17/Fri by yhlee
;return azimuthal[0,*]=theta, azimuthal[1,*]=intens
;PA. be matched with ellipse fitting's PA 2011/02/07/Mon by yhlee

;---(1) rotate the ellipse -------------------
;ellipse fitting PA -> rotation PA
PA0 = PAc+90    
rimg = rot(img, PA0, 1.0, xc, yc, /pivot)

;---(2) fix the a & b ------------------------
 a = radius 
 b = a*(1-e)

;---(3) ellipse array: x, y, r, theta, degree  
step = 10 
np = 2*step+1
nc = 0
ar = fltarr(np) & atheta = fltarr(np) & adegree = fltarr(np)
px = fltarr(np) & py = fltarr(np) & inten = fltarr(np)
 For o = step, -step, -1 do begin
  x = a*float(o)/step
  y = (b^c*(1-(abs(x)^c/a^c)))^(1/c)
 If Finite(y, /nan) then goto, nexto
  px[nc] = x + xc
  py[nc] = y + yc
  ar[nc] = SQRT(x^2+y^2)
  atheta[nc] = acos(x/ar[nc])
  adegree[nc] = atheta[nc]*180/!PI   ;radian->degree
  nc = nc+1
 Endfor   ; for o

;---(4) ellipse with same step: interpol -----
degree1 = FINDGEN(180)
r = INTERPOL(ar,adegree,degree1,/Spline)
nr = n_elements(r) 
px1 = fltarr(nr) & py1 = fltarr(nr)
px2 = fltarr(nr) & py2 = fltarr(nr)
azimuthal = fltarr(2,nr*2)

;1,2 quaters
 For i = 0, nr-1 do begin 
  azimuthal[0,i] = degree1[i]*!PI/180               ;degree->theta
  px1[i] = r[i]*cos(azimuthal[0,i])+xc
  py1[i] = r[i]*sin(azimuthal[0,i])+yc
  azimuthal[1,i] = BILINEAR(rimg, px1[i], py1[i])
 Endfor
;3,4 quaters
 For j = 0, nr-1 do begin 
  px2[j] = -r[j]*cos(azimuthal[0,j])+xc
  py2[j] = -r[j]*sin(azimuthal[0,j])+yc
  azimuthal[0,j+nr] = azimuthal[0,j]+3.14
  azimuthal[1,j+nr] = BILINEAR(rimg, px2[j], py2[j])
 Endfor
return, azimuthal 
nexto:
END
