Function YH_centroid, img, scope

centroid = fltarr(2)

index = where(img gt scope, num)

 If (num eq 0) then index = where(img ge min(img))

imgs = size(img)

xindex = index mod imgs[1] 
yindex = fix(index/imgs[1])

xbunja = total(img[xindex,yindex] * xindex)
xbunmo = total(img[xindex,yindex])
centroid[0] = xbunja/xbunmo

ybunja = total(img[xindex,yindex] * yindex)
ybunmo = total(img[xindex,yindex])
centroid[1] = ybunja/ybunmo

return, centroid 

End
