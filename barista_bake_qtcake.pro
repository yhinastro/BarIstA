Function barista_bake_qtcake, output_Fname = Fname, input_img = Fimg, cent = Fcent, renew = renew, R25 = Fsc, hz = hz, radi, Fr, Ft, Po 

;2025/08/11/Mon by yhlee ========================
;This routine computes the radial (Fr) and tangential (Ft) force fields
;from a galaxy's surface brightness (or mass) distribution and derives
;the dimensionless bar torque parameter (Q_T).
;This step is the first part for measuring bar strength Qb in BarIstA pipeline.

;--- Required Input Parameters ---
;output_Fname = Filename for the output results (e.g., 'galaxy_qtcake.fits')
;renew        = 'yes' to calculate the potential map or 'no' to use the potential map by reading the F 
;input_img    = 2D array containing the galaxy image (mass-traced, preferably deprojected)
;cent         = Galaxy center of deprojected image as [xcent, ycent]
;R25          = Outer reference radius (e.g., semi-major axis length of the outermost fitted ellipse)
;hz           = Vertical scale height of the disk (in pixels),

;--- Notes on Vertical Scale Height (hz) ----------------
;The vertical scale height of the disk (hz) is estimated from the disk radial
;scale length (hr) following empirical scaling relations:
;   hz = hr / 9
;   If (T ≤ 4) then hz = hr / 5
;   If (T ≤ 1) then hz = hr / 4
;where T is the morphological type index of the galaxy (de Vaucouleurs system).
;Earlier-type galaxies (smaller T) generally have thicker disks, hence larger hz.
;These relations are adopted from observational studies of disk structure.

;--- Output -----------------------
;Qtcake       = 2D array of force ratio map
;Fr           = 1D array of radial force values across the galaxy image
;Ft           = 1D array of tangential force values across the galaxy image
;Po           = 1D array of potential map 
;radi         = 1D array of radii at which Fr, Ft, Po are evaluated

;--- Example Usage ----------------
;Qtcake = barista_bake_qtcake(output_Fname = Fname, renew = renew, $
;                             input_img = Fimg, input_cent = Fcent, R25 = Fsc, $
;                             hz = hz, radi, Fr, Ft, Po)

;--- Reference --------------------
;For detailed explanation of the calculation methods and parameter definitions, 
;see Lee et al. (2020), "Bar Classification Based on the Potential Map".
;================================================

str = 0
infofile = File_info(Fname+'.Pab.fits')
If (renew eq 'no') then $
If infofile.exists ne 0 then goto, jump

;===== 1.2D FFT ===================================
Fs = size(Fimg)
;Cs = size(colormap)
xcent = Fcent[0] 
ycent = Fcent[1]

Fsize = [xcent, ycent, Fs[1]-xcent, Fs[2]-ycent];, Cs[1]-xcent, Cs[2]-ycent]
Fmin = min(Fsize)
Fmax = max(Fsize)

;goto, test
;cut = Fsc
;If (cut ge Fmin) then cut = Fmin-2
;--- rotate image -------------------
;If (PA ge 180) then PA = PA-180
;rPA = -1*PA[0] 
;Rimg = Rot(Fconvol, rPA, 1, xcent, ycent, cubic = -0.5, /pivot)
;RFimg = Rot(Fimg, rPA, 1, xcent, ycent, cubic = -0.5, /pivot)
;r_colormap = Rot(colormap, PA,  1, xcent, ycent, cubic = -0.5, /pivot)

;---(0) smoothing -------------------
;smpix = 16 
;Fconvol = smooth(Fimg,smpix,/edge_truncate)

;---(1) mass: 2n image --------------
 Mpq = fltarr(Fs[1]*2, Fs[2]*2)

For j = 0L, Fs[2]-1 do begin    ;y
 For k = 0L, Fs[1]-1 do begin   ;x
  Mpq[k,j] = Fimg[k,j]
 Endfor
Endfor
;print, size(Mpq)
print, 'Mpq', max(Mpq), mean(Mpq), median(Mpq), min(Mpq)

;check the image
;scaling intensity
; Mpq_d = Mpq > (mean(Fimg)-cut) < (mean(Fimg)+cut)
;plot the image
;loadct, 0
; PLOTIMAGE, bytscl(Mpq), Title = 'mass', $
; Position = [0.10, 0.75, 0.35, 0.92], /noerase

;---(2) radius: including the condition
;For 0 < Fpq < 2n 
 Fpq = fltarr(Fs[1]*2, Fs[2]*2)

;count = 0
cs = Fs[1]*2 & ds = Fs[2]*2
    ;c = Fs[1]+1 
 For c = 0, cs-1 do begin
  If (c ge 0. and c le Fs[1]) then cdis = c else cdis = Fs[1]*2-c
  For d = 0, ds-1 do begin
   If (d ge 0. and d le Fs[2]) then ddis = d else ddis = Fs[2]*2-d
     Iradi = sqrt(cdis^2.+ddis^2.)
    If (cdis eq 0. and ddis eq 0.) then Iradi = 1
     Fpq[c,d] = Iradi 
  Endfor
;count = count+1
 Endfor

;check the radius function
; Fpq_d = Fpq < max(Fpq)/2. 
;print, max(Fpq), median(Fpq), mean(Fpq), min(Fpq)
; PLOTIMAGE, bytscl(Fpq), title = 'radius@pq', $
; Position = [0.40, 0.75, 0.65, 0.92], /noerase 

;---(3) scale height: 2D -> 3D -----
;print, max(Fpq), median(Fpq), min(Fpq)
; calculate G(r) for bar strength
;t1 = systime(1)
scale = fix(Fs[1]*0.2)
COMMON SHARE, rd
COMMON SHARE, hze
 hze = hz
 nstep = scale & nd = fix(max(Fpq)) 
 rstep = nd/scale
 rd_Fpq = fltarr(nstep)
 gr_Gpq = fltarr(nstep)
;print, nd, rstep

 nd = fix(scale*0.7)
 zd = fltarr(nd)
 zd = findgen(nd)
 roz = (1./(2.*hze))*(exp(-(abs(zd/hze))))
 roz_z = roz/sqrt(zd^2.)

For n = 0L, nstep-1 do begin
  rd = (n+1)*rstep
  rd_Fpq[n] = rd
  gr_Gpq[n] = 2.*Qromo('yh_Froz', 0., 10.*hz) ;/Midexp)
Endfor
;print, max(gr_Gpq)
;
;calculate G(r)
;hz = 325./30.  ; in pixel
;gr_Gpq = gr_Gpq/(2.*hz)
;Fpq = Fpq/hz
;print, max(gr_Gpq)
;calculate G(r) for Fpq
;Gpq = fltarr(Fs[1]*2,Fs[2]*2)
;For j = 0L, Fs[2]*2-1 do begin
; For k = 0L, Fs[1]*2-1 do begin
;  Gpq[k,j] = INTERPOL(gr_Gpq, rd_Fpq, Fpq[k,j],/Splin)
; Endfor
;Endfor
;print, max(Fpq), min(Fpq), max(Gpq)
;print, Gpq[100,100]
;print, rd_Fpq[10], gr_Gpq[10]


;Plot, rd_Fpq, gr_Gpq, xtitle = 'rd', ytitle = 'g(r)', $
;xran = [0, nd], $
;Position = [0.70, 0.75, 0.95, 0.92], /noerase
;Legend, [string(hz,format='(F5.2)')], box = 0, /top, /right

;calculate G(r) for Fpq
;print, max(Gpq), median(Gpq), min(Gpq)
Gpq = fltarr(Fs[1]*2,Fs[2]*2)
For j = 0L, Fs[2]*2-1 do begin
 For k = 0L, Fs[1]*2-1 do begin
  Gpq[k,j] = INTERPOL(gr_Gpq, rd_Fpq, Fpq[k,j],/Splin)
 Endfor
Endfor
;print, max(Gpq), median(Gpq), min(Gpq)
;t2 = systime(1)
;print, t2-t1, 's'

;check the radius function
; Gpq_d = Gpq < max(Gpq)/10
; PLOTIMAGE, bytscl(Gpq_d), title = '1/r@pq', $
; Position = [0.40, 0.51, 0.65, 0.68], /noerase 

;---(3) FFT ------------------------
;FFT(array, direction)
;direction < 0: forward transform
;direction > 0: inverse transform
Mkl = FFT(Mpq,-1)*(Fs[1]*2)*(Fs[2]*2)
Fkl = FFT(Gpq,-1)*(Fs[1]*2)*(Fs[2]*2)

;---(4) potential ------------------
Pkl = Mkl*Fkl
Pab = FFT(Pkl,1)/(Fs[1]*2*Fs[2]*2)

;check the potential
;Pab_d = abs(Pab)
;PLOTIMAGE, bytscl(Pab_d), title='Potential', $
;Position = [0.10, 0.51, 0.35, 0.68], /noerase
WRITEFITS, Fname+'.Pab.fits', abs(Pab) 
;===============================================
JUMP:

;===== 3. Radial Force: Fr =====================
;---(2) Make the azimuthal profile -----
Pab = readfits(Fname+'.Pab.fits')
YH_poazi, 0, Fsc[0], Fname, Fcent, Pab 

;---(3) Calculate the fourier series --
openw, lun, Fname+'.fouri', /get_lun
printf, lun, 'r', 'Poten', Format = '(2(A5,3x))'

run = Fsc-str

For l = 0L, run[0]-1 do begin
 radi = l+str
 inte = string(radi, format='(I0)')
 Filen = Fname[0]+'.poazi'+inte
 READCOL, Filen, skipline=1, Format='F,F', $
  theta, poten, /silent
  num = n_elements(poten)
 sig = fltarr(num) & sig[*] = 0.5
 mterms = 1 
; Fourfit, theta, poten, sig, mterms, coef, csig, yfit = yfit, chisq = chisq
 coef = YH_fourier(poten, theta, mterms = mterms)
printf, lun, radi, coef[0], Format = '(I3,1x,1(F10.3,1x))'
Endfor

close, lun
free_lun, lun
;=================================================
TEST:

;===== 4. Bar Strength: Qt =======================
;---(1) Radial Force :Fr -----------------
READCOL, Fname[0]+'.fouri', skipline = 1, Format = 'F,F', $
radi, Po, /silent
numr = n_elements(radi)
Fr = Fltarr(numr-1) & Qtmax = Fltarr(numr-1)
Qtcake = Fltarr(numr-1,359)
;Qt1 = Fltarr(3,(nump-1)*90) & Qt2 = Fltarr(3,(nump-1)*90) 
;Qt3 = Fltarr(3,(nump-1)*90) & Qt4 = Fltarr(3,(nump-1)*90)

For m = 0, numr-2 do begin ; nump-2
 Fr[m] = abs(Po[m+1]-Po[m])/(radi[m+1]-radi[m])

;---(2) Tangentail Force : Ft -------------
 inte = string(radi[m], format = '(I0)')
 Filen = Fname[0]+'.poazi'+inte
 READCOL, Filen, skipline = 1, Format = 'F,F', $
 theta, poten, /silent
 numt = n_elements(theta)

 Ft = Fltarr(numr-1, 359) 
; Ft1 = Fltarr(90) & Ft2 = Fltarr(90)
; Ft3 = Fltarr(90) & Ft4 = Fltarr(90)

 For o = 0, numt-2 do begin    ;For theta
  If (o eq numt-1) then begin
   Ft1 = 1./radi[m]
   Ft2 = (poten[0]-poten[o])
   Ft3 = abs(theta[o-1]-theta[o])
   Ft[m,o] = abs(Ft1*Ft2/Ft3)
  EndIf Else begin
   Ft1 = 1./radi[m]
   Ft2 = (poten[o+1]-poten[o])
   Ft3 = (theta[o+1]-theta[o])
;print, m, Ft1, Ft2, Ft3
   Ft[m,o] = abs(Ft1*Ft2/Ft3)
  EndElse

;---(3) Bar Strenght: Qt ------------------
  Qtcake[m,o] = Ft[m,o]/abs(Fr[m])
 EndFor

Endfor
WRITEFITS, Fname+'.Qt.fits', Qtcake
;===================================================

Return, Qtcake
End

