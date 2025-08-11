PRO barista_overlay_ellipse, input_img = img, r = a, xc = xc, yc = yc, e = e, PA = PA, title = title, position = pos, imz = imz, highlight_r = highlight 

;2025/04/15/Tue by yhlee ========================
;This routine displays ellipses obtained from ellipse fitting on the input image.

;--- Required Input Parameters ----
;input_img = 2D array containing the galaxy image
;r         = Array of ellipse semi-major axis lengths
;xc, yc    = Arrays for x and y coordinates of the ellipse centers
;e         = Array of ellipticities
;PA        = Array for  position angle [degree]
;These parameters are typically obtained from ellipse fitting (i.e. barista_ellipsefit.pro)

;--- Optional Input Parameters ---- 
;title     = String for image title 
;position  = Array specifying the display position: [left, bottom, right, top] 
;imz       = Display range in terms of radius  
;hightlight_r = Radius or array of radii to highlight (e.g., bar or disk radius)These will be shown as red solid lines

;--- Example Usage -----------------
;barista_overlay_ellipse, input_img = img, r = r, xc = xc, yc = yc, e = e, PA = PA, title = 'ellipse fitting', position = [0.2, 0.3, 0.77, 0.7], highlight_r = [5, 10]
;================================================


imgs = size(img)
scale = [xc[0], imgs[1]-xc[0], yc[0], imgs[2]-yc[0]]
Fmin = min(scale)-1

;===== display galaxy image =====================
If (n_elements(pos) eq 0) then pos = [0.2, 0.3, 0.77, 0.7]
loadct, 0
If (n_elements(imz) ne 0) then begin
imz = imz < Fmin
Plotimage, bytscl(img), position = pos, $
title = title, $
xtitle = 'x (pixel)', ytitle = 'y (pixel)', $
xran = [xc[0]-imz,xc[0]+imz], yran = [yc[0]-imz, yc[0]+imz], $
charsize = 0.6, charthick = 2, xst = 1, yst =1,  /noerase
EndIf Else begin
Plotimage, bytscl(img), position = pos, $
title = title, $
xtitle = 'x (pixel)', ytitle = 'y (pixel)', $
charsize = 0.6, charthick = 2, xst = 1, yst =1,  /noerase
EndElse
oplot, [0,imgs[1]], [yc[0],yc[0]], color = 0
oplot, [xc[0],xc[0]],[0,imgs[2]], color = 0
;================================================

num = n_elements(a)
c = Fltarr(num) & c[*] = 2.

n_hi = n_elements(highlight)
If (n_hi ne 0) then begin
 in_hi = Fltarr(n_hi)

 For k = 0, n_hi-1 do begin
  in = where(a eq highlight[k], numb)
  If (numb eq 1) then in_hi[k] = in Else in_hi[k] = in[0]
 EndFor
EndIf

For i = 0L, num-1 do begin ;radius

;===== Make the generalized bar image ================== 
;---(1) parameter for the generalized ellipse -----
radi = fix(a[i])
b = fix(a[i])*(1-e[i])
cPA = -(PA[i]+90)   ;for match to the ellipse fitting starndard

;---(2) make the generalized ellipse --------------
;make to the decimal fraction
 np = 2*(2*radi+1) & nc = 0 & nr = np-1
if (radi eq 0) then goto, nextr 
 gen = fltarr(2,np) & fbar = fltarr(2,np) 
 rbar = fltarr(np)
 For o = radi[0], -radi[0], -1 do begin
;make the generalized ellipse isophote
   x = float(o)
   y = (b^c[i]*(1-((abs(x)^c[i])/(fix(a[i])^c[i]))))^(1/c[i])
   gen[0,nc] = x & gen[0,nr] = x
   gen[1,nc] = y & gen[1,nr] = -y

;---(3) rotate the ellipse ------------------------
 rotT1 = [[cos(cPA*!dtor),sin(cPA*!dtor)], $
          [-sin(cPA*!dtor),cos(cPA*!dtor)]]
 re = rotT1##[gen[0,nc],gen[1,nc]]
 rr = rotT1##[gen[0,nr],gen[1,nr]]
;move to the center
   fbar[0,nc] = re[0] + xc[i]
   fbar[1,nc] = re[1] + yc[i]
   fbar[0,nr] = rr[0] + xc[i]
   fbar[1,nr] = rr[1] + yc[i]
  nc = nc+1 & nr = nr-1

 Endfor   ; for o


;---(4) plot the image of gbar --------------------
;plot the generalized isophote
 loadct, 0
 thick = 1

If (n_hi ne 0) then begin
ind = where(in_hi eq i, num)
 If (num eq 1) then begin 
  loadct, 3 
  thick = 2
 EndIf 
EndIf

 oplot, fbar[0,*], fbar[1,*], color = 200, linestyle = 0, thick = thick 

NEXTR:
Endfor ;For i

;=======================================================
OUT:
End


