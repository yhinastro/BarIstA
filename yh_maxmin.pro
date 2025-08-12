PRO YH_maxmin, array, maxindex, minindex

 num = n_elements(array)

 arr1 = array[0:num-2]
 arr2 = array[1:num-1]
 diff = arr2-arr1
;print, 'diff', diff
 diff1 = diff[0:num-3]
 diff2 = diff[1:num-2]
 grad = diff1*diff2
;print, 'grad', grad
del0in = where(grad le 0, mcount)
;print, 'del0in', del0in

 del01 = array[del0in+1]
 del02 = array[del0in+3]
;print, del01
;print, del02
 grad_del = del01-del02
;print, grad_del
 maxin = where(grad_del gt 0, xcount)
 minin = where(grad_del lt 0, ncount)
;print, 'max', xcount, maxin
;print, 'min', ncount, minin

;OUTPUT
If (xcount eq 0) then maxindex = 0 $
Else maxindex = del0in[maxin]+1
If (ncount eq 0) then minindex = 0 $
Else minindex = del0in[minin]+1
;print, 'maxindex', maxindex
;print, 'minindex', minindex

END
