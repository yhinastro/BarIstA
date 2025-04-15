Function barista_mask_neighbor, output_Fname = Filename, input_img = img, $
         cent = cent, R25 = R25, star_threshold = star_thre, psf = psf, $
         sep_val = sep_val, cut_step = cut_step, cut_lim = cut_lim, $
         n_neighbor = n_neighbor, model, total_mask 

;2025/04/15/Tue by yhlee ========================
;This routine masks bright objects near the target galaxy and fills the masked region using values from neighboring pixels
;1. The routine identifies bright regions to be masked from a lower threshold (star_thre) to the higher value (cut_lim), increasing by a factor of cut_step. 
;If star_thre and cut_lim are not provided, they default to:
;   star_thre= sqrt(sky)*3 
;   cut_lim = value_center*0.9
;   cut_step = 1.5
;2. You can fine-tune the masking behavior using the optional parameters

;--- Required Input Parameters ---
;output_Fname = Filename for the masked image to be saved 
;input_img    = 2D array containing the galaxy image
;cent         = Galaxy center as [xcent, ycent]
;R25          = Galaxy size used to define the region of interest
;This routine fills masked objects within R25 using neighboring and ones outside R25 using sky = median(img). 

;--- Optional Input Parameters ---
;star_threshold = Smaller values to mask more clearly
;cut_step       = Smaller values to mask more clearly 
;psf            = Smaller values mask minimal areas
;               = Larger values mask more broadly
;n_neighbor     = Smaller/larger values to estimate replacement values from smaller/more neighbors

sky = median(img)
If (n_elements(star_thre) eq 0) then star_threshold = sqrt(sky)*3
If (n_elements(cut_lim) eq 0) then cut_lim = img[cent[0], cent[1]]*0.9
If (n_elements(cut_step) eq 0) then cut_step = 1.5
If (n_elements(sep_val) eq 0) then sep_val = 10
If (n_elements(n_neighbor) eq 0) then n_neighbor = 5 
If (n_elements(psf) eq 0) then psf = 8

;--- Example Usage ---------------
;result = barista_mask_neighbor(output_Fname = Filename, input_img = img, cent = cent, R25 = R25, model, mask)

;--- Output files ----------------
;model         = 2D array containing the filled values
;total_mask    = 2D array containing the masked regions
;result        = Final 2D masked image
;================================================


;===== Mask bright object ========
 sky = median(img)
 imgs = size(img)
 mask_img = img 
 mask_filt = FLTARR(imgs[1],imgs[2])
 mask_val = FLTARR(imgs[1],imgs[2])
 total_mask = FLTARR(imgs[1],imgs[2])
 total_mask2 = FLTARR(imgs[1],imgs[2])
 resi_img = FLTARR(imgs[1],imgs[2])
 total_img = FLTARR(imgs[1],imgs[2])
 cut_img = img

;---(1) Find bright fields -- 
xcen = cent[0] & ycen = cent[1]
TRY:
 star_thre = star_thre
 resi_img = img

 For k = 0L, 30 do begin
  star_thre = star_thre*cut_step
print, 'cut_val', k, star_thre 
 If (star_thre gt cut_lim) then goto, out
 index = (resi_img gt star_thre)
 mindex = where(resi_img gt star_thre, mcount)

 If (mcount eq 0) then begin
  maskimg = img & goto, next_t 
 Endif

;---(2) Define masking regions: > boundary
;calculate distance to the center
  Dist_circle, odist, [imgs[1],imgs[2]], xcen[0], ycen[0]
  p_radi = index*odist
 
;determine the minimum distance of point/extended sources
  boundary = 0
  r_radi = where(p_radi gt 0, mcount)

  If (mcount le 2) then goto, next_t 

  r_radi = p_radi[r_radi]
  so_radi0 = r_radi[sort(r_radi)]
  so_radi1 = so_radi0[1:mcount-2]
  diff = so_radi1-so_radi0
  
  bin = where(diff gt sep_val, bnum)
  If (bnum eq 0) then boundary = 0 Else boundary = so_radi0[bin[0]]
;print, k, cut_val, boundary

 If (boundary eq 0) then goto, next_t

;---(3) Smoothing filter matrix with circle of r = 5
;bright region
 mask_filt = (p_radi gt boundary)
;convolution
 mask = circ_mask(psf)
 mask_filt = convol(mask_filt,mask)
 mask_filt = (mask_filt ne 0)
 total_mask = total_mask+mask_filt
 total_mask = (total_mask ne 0)
NEXT_T:
EndFor ; For k
OUT:
print, 'out'
;EndIf Else total_mask = input_mask

;neighbor image
 neigh = circ_mask(psf+1)
 neigh_filt = convol(total_mask,neigh)
 neigh_filt = (neigh_filt ne 0)*2
 neigh_filt = neigh_filt - total_mask ; 2-neighbor, 1-mask, 0-background
;residual image
 resi_filt = 1-total_mask
 resi_img = resi_filt*img

;---(4) Find masking value using mean of neighbors 
model = Fltarr(imgs[1], imgs[2])

ind_mask = where(neigh_filt eq 1, nmask)
    x_mask = ind_mask mod imgs[1]
    y_mask = fix(ind_mask/imgs[1])
    r_mask = sqrt((x_mask-xcen)^2.+(y_mask-ycen)^2.)

ind_neigh = where(neigh_filt eq 2, n_neigh)
    x_neigh = ind_neigh mod imgs[1]
    y_neigh = fix(ind_neigh/imgs[1])
    r_neigh = sqrt((x_neigh-xcen)^2.+(y_neigh-ycen)^2.)

 For i = 0L, nmask-1 do begin
 If (r_mask[i] gt R25) then model[x_mask[i], y_mask[i]] = sky Else begin
     diff = abs(r_neigh - r_mask[i])
     sort_ind = sort(diff)
     neighbor = resi_img[x_neigh[sort_ind[0:n_neighbor+2]], y_neigh[sort_ind[0:n_neighbor+2]]]
     masked_value = (total(neighbor)-max(neighbor)-min(neighbor))/n_neighbor
     If (n_neighbor eq 0) then model[x_mask[i], y_mask[i]] = median(img) $ 
     Else model[x_mask[i], y_mask[i]] = masked_value
 EndElse
 EndFor

 total_img = (1-total_mask)*cut_img+model*total_mask
;If some area could not find their masking value, place the sky value instead of 0
 ind = where(total_img eq 0 or Finite(total_img,/NaN), num)
 If (num ne 0) then total_img[ind] = sky

WRITEFITS, Filename+'_maskimg.fits', total_img
;=================================
jump:
Return, total_img 
End 
