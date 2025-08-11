Function barista_deprojection, output_Fname = Filename, input_img = img, $
         cent = cent, R25 = SMA, e_disk = ellip, incl = incl, pa_disk = PA, $
         dep_img, dep_cent

;2025/04/15/Tue by yhlee ========================
;This routine deprojects a galaxy image to faced-on using orientation parameters
;The orientation parameters are typically obtained from ellipse fitting (i.e. barista_ellipsefit.pro)

;--- Required Input Parameters ---
;output_Fname = Filename for the deprojected image (e.g., 'galaxy_dep.fits') 
;input_img    = 2D array containing the galaxy image
;cent         = Galaxy center as [xcent, ycent]
;R25          = Outermost radius at which orientation parameters are measured
;e_disk       = Ellipticity of the outermost ellipse
;pa_disk      = Position angle of the outermost ellipse
;incl         = Inclination measured from the ellipticity
;You can provide either e_disk or inclination

;--- Example Usage ---------------
;result = barista_deprojec(output_Fname = 'deproject.fits', input_img = img, cent = cent, R25 = r_disk, e_disk = ellip, pa_disk = PA, dep_img, dep_cent)

;--- Output-----------------------
;dep_img      = 2D array containing the deprojected image
;dep_cent     = [xcent, ycent] for the deprojected image
;result       = inclination in degree
;================================================


;===== Deproject the image ======================
imgs = size(img)
X0 = cent[0] & Y0 = cent[1]
;print, 'x0,y0', X0, Y0
If (n_elements(incl) eq 0) then incl = 180./!PI*acos(1.-ellip) Else incl = incl
If (n_elements(ellip) eq 0) then ellip = 1-cos(incl*!DTOR) Else ellip = ellip

a = round(SMA*10)           & a = float(a[0])/10
b = round((1-ellip)*SMA*10) & b = float(b[0])/10
x = round(X0*10)            & x = float(x[0])/10
y = round(Y0*10)            & y = float(y[0])/10
ro = round(PA*10)           & ro = float(ro[0])/10+90
 
;---(1) face-on image: variation for the intensity
var = cos(incl*!dtor)
Limg = img*var[0]

;---(2) rotate the image to the x-axis --------
Rimg = rot(Limg, ro[0], 1, x[0], y[0], cubic = -0.5, /pivot)
;print, 'dep', ro[0], size(Rimg)

;TK_img_scaling, Rimg, d_img, sky, sky_sig
;loadct, 0
;Plotimage, bytscl(d_img), title = 'Rimg', $
;    position = [0.07+0.23*0, 0.83-0.16, 0.24+0.23*0, 0.95-0.16] , $
;    xst = 1, yst = 1, charthick = 2, charsize = 0.6, /noerase

;---(3) expand the image to y-axis -------------
xs = imgs[1]
ys = fix(imgs[2]/var)+1
ps = xs*ys
Eimg = fltarr(xs, ys)

For j = 0L, ps[0]-1 do begin
 sx = j mod xs
 sy = fix(j/xs)
 py = sy*var
 Eimg[sx,sy] = INTERPOLATE(Rimg, sx, py, /CUBIC, /GRID)
Endfor

 eb = fix(b[0]/var)
 ey = fix(y[0]/var)
;print, 'ey', var, y[0], ey

;centroid
dep_cent = fltarr(2)
dep_cent[0] = X0
dep_cent[1] = Y0/var

;TK_img_scaling, Eimg, d_img, sky, sky_sig
;loadct, 0
;Plotimage, bytscl(d_img), title = 'Eimg', $
;    position = [0.07+0.23*1, 0.83-0.16, 0.24+0.23*1, 0.95-0.16] , $
;    xst = 1, yst = 1, charthick = 2, charsize = 0.6, /noerase

;---(4) rotate the image to the real direction ---
rero = 360-ro[0]
dep_img = rot(Eimg, rero, 1, x[0], ey[0], cubic = -0.5, /pivot)

;TK_img_scaling, dep_img, d_img, sky, sky_sig
;loadct, 0
;Plotimage, bytscl(d_img), title = 'deprojected', $
;    position = [0.07+0.23*2, 0.83-0.16, 0.24+0.23*2, 0.95-0.16] , $
;    xst = 1, yst = 1, charthick = 2, charsize = 0.6, /noerase

WRITEFITS, Filename+'.fits', dep_img

return, incl 
End
