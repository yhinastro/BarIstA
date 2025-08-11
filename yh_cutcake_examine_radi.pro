Function YH_cutcake_examine_radi, Qtcake, cent, r0 = r0, min_r = min_r, max_r = max_r, cutlim = cutlim, localmax, peaks, type, px, py, Qb, Qtcake_nb

;selected method
;2019/01/20/Sun by yhlee

;---(1) cut at the max_r 
sz = size(Qtcake)
Qtcake_nb = Fltarr(sz[1], sz[2])
Qtcake_nb[min_r+r0:sz[1]-1, 0:sz[2]-1] = Qtcake[min_r+r0:sz[1]-1, 0:sz[2]-1]

Qt_cutcake = Qtcake_nb[max_r+r0,*]

;---(2) investigate the number of peaks
  box = 10
;  If (cut_r le 25) then box = 20 
;  If (cut_r le 10) then box = 35

;1.shift the array to the minimum points
  min_index = where(Qt_cutcake eq min(Qt_cutcake))
;print, 'min_index', min_index
  nQt = n_elements(Qt_cutcake)
  arrQt = Fltarr(nQt)
  arrQt_o = Fltarr(nQt)

  If (min_index[0] ne 0) then begin
   arrQt[0:nQt-min_index[0]-1] = Qt_cutcake[min_index[0]:nQt-1]
   arrQt[nQt-min_index[0]:nQt-1] = Qt_cutcake[0:min_index[0]-1]
  EndIf Else arrQt = Qt_cutcake

;2.count four pillar
   filter = (arrQt gt cutlim)
   np = 0 & bl = 0
   nf = n_elements(filter)
;print, filter
    For i = 0L, nf-2 do begin
     If (filter[i] eq 1) then begin
      bl = bl+1
     If (((filter[i+1] eq 0) or (i eq nf-2)) and bl gt 10) then begin
      np = np+1 & bl = 0
     EndIf
     EndIf
    EndFor 
;print, filter
print, 'n_bar', np

;3.smoothing array
  For m = 0L, 2 do begin ;three times smoothing
   arrQt = smooth(arrQt, box, /edge_truncate)
   YH_maxmin, arrQt, localmax_cut0, localmin_cut0
  EndFor
ind0 = where(arrQt[localmax_cut0] gt cutlim, nlp0)
print, 'n_peak', nlp0
;print, localmax_cut0[ind0]
;print, arrQt[localmax_cut0[ind0]]

;test for one peak over one bar region
 localmax_cut = Fltarr(np)
 nb = 0 ;number of peaks
 If (nlp0 gt np) then begin
  ind = where(filter eq 0, n0)
;print, ind, n0
nlp = 0 ;number of local peaks
  For i = 0L, n0-2 do begin
   bl = ind[i+1]-ind[i] 
;print, i, bl, ind[i]
   If (bl gt 10) then begin
;	print, i, '1', nb, nlp
    If (localmax_cut0[ind0[nlp]] gt ind[i]) and (localmax_cut0[ind0[nlp]] lt ind[i+1]) then begin 
;	print, i, '1', nb, nlp
;	print, ind[i+1], nb, nlp, bl
        localmax_cut[nb] = localmax_cut0[ind0[nlp]]
	nb = nb+1 
	nlp = nlp+1
	print, '1', nb, nlp, localmax_cut[nb-1], arrQt[localmax_cut[nb-1]], cutlim
      If (nlp lt nlp0) then begin
;  	print, nlp, nlp0, localmax_cut0[nlp], ind[i], ind[i+1]
      If (localmax_cut0[ind0[nlp]] gt ind[i]) and (localmax_cut0[ind0[nlp]] lt ind[i+1]) then begin 
       If (arrQt[localmax_cut0[ind0[nlp]]] gt arrQt[localmax_cut0[ind0[nlp-1]]]) then begin 
	localmax_cut[nb-1] = localmax_cut0[ind0[nlp]]
	nlp = nlp+1
	print, '2', nb, nlp, localmax_cut[nb-1]
       EndIf Else nlp = nlp+1
      EndIf
      EndIf
    EndIf
   EndIf
;   If (nlp eq nlp0) then goto, out
  EndFor
OUT:
 EndIf Else localmax_cut = localmax_cut0
print, localmax_cut

;4.return the localmax point
  If (min_index[0] ne 0) then begin
   arrQt_o[min_index[0]:nQt-1] = arrQt[0:nQt-min_index[0]-1]
   arrQt_o[0:min_index[0]-1] = arrQt[nQt-min_index[0]:nQt-1]
  EndIf Else arrQt_o = arrQt

  localmax = localmax_cut+min_index[0]
  ind = where(localmax ge 359, numi)
  If (numi ne 0) then localmax[ind] = localmax[ind]-359
  ps = size(localmax)
;print, ps
  If (ps[0] eq 1) then peaks = ps[1] Else peaks = 0
;print, peaks
;print, localmax
  Qb = mean(Qt_cutcake[localmax])
  bind = where(Qt_cutcake[localmax] gt cutlim, bnum)
;print, np
If (np lt 4) then peaks = np Else peaks = bnum
If (bnum ne 0) then localmax = localmax[bind] Else localmax = localmax 
;print, peaks
;print, localmax

;---(3) classification ------
If (peaks eq 4) then begin
 If (Qb ge 0.25) then type = 'SB' Else begin
  If (Qb ge 0.15) then type = 'SAB' Else type = 'SA'
 EndElse
EndIf Else type = 'SA'

;localmax_cut on the Cartesian coordinate
 px = (max_r[0]+r0)*cos(localmax*!dtor) + cent[0]
 py = (max_r[0]+r0)*sin(localmax*!dtor) + cent[1]

Return, Qt_cutcake
;Return, arrQt
END
