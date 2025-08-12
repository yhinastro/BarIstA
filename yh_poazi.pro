PRO YH_POAZI, str, enr, Fname, centroid, Pab 
;make Potential azimuthal profile for bar strength
;interpolate by BILINEAR 2011/10
;@yh_barstreng.pro

run = enr-str

For j = 0L, run-1 do begin
 r = j+str & rn = string(r,format='(I0)')
 filen = Fname+'.poazi'+rn
 lunm = 'lun'+rn
openw, lunm, filen, /get_lun
printf, lunm, 'theta', 'poten', $
format='(2(A20,1x))'

 For k = 0, 359 do begin
  theta = k*!dtor
  px = r*cos(theta)+(centroid[0])
  py = r*sin(theta)+(centroid[1])
 ;inten = INTERPOLATE(img,px,py,/CUBIC, /GRID)
 ;inten = BILINEAR(img,px,py)
  poten = BILINEAR(Pab,px,py)
;If (k eq 50) then print, k, px, py, inten
printf, lunm, theta, abs(poten), $
format='(F9.4,1x,F20.4,1x)'
 Endfor
close, lunm
free_lun, lunm
Endfor
;jump0:


END
