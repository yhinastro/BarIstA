function YH_froz, z

COMMON SHARE, rd
COMMON SHARE, hze
;z_density
;Roz = (2./(exp(zd)+exp(-zd)))^2.
;Fun = Roz/sqrt(rd^2.+zd^2.) 

;hz = 325.
;;z_density
;Roz = 1./(2.*hz)*(2./(exp(z/hz)+exp(-z/hz)))^2.
;Fun = Roz/sqrt(r^2.+z^2.) 

Roz = (1./(2.*hze))*(exp(-(abs(z/hze))))
Fun = Roz/sqrt(rd^2.+z^2.)
;Fun = Roz/sqrt(z^2.)
Return, Fun 
End
