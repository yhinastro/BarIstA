# BarIstA 
Bar Image astro-Arithmometer in IDL

##1. barista_mask_neighbor.pro
This routine masks bright objects near the target galaxy (e.g., foreground stars, background galaxies) and fills the masked regions with values interpolated from neighboring pixels or with the sky background value.
This step prevents contamination in subsequent analyses such as ellipse fitting, Fourier decomposition, and torque measurements.

##2. barista_ellipsefit.pro
IDL routine to perform robust ellipse fitting of galaxy images, based on methods by Davis et al. (1985) and Athanassoula et al. (1990).
One advantage of this routine is that it provides stable ellipse fitting results without requiring initial guesses for the ellipticity or position angle (PA).
This routine requires the following subroutines: YH_ellipazi.pro, YH_fourier.pro, YH_centroid.pro.

##3. barista_overlay_ellipse.pro
This routine overlays the ellipses obtained from ellipse fitting onto the input galaxy image.
It is useful for visually inspecting the accuracy of the fit and for identifying morphological components such as bars, rings, and spiral arms.

##4. barista_deprojection.pro
This routine deprojects a galaxy image to a face-on view using orientation parameters (ellipticity of inclination, PA).
The orientation parameters are typically obtained from barista_ellipsefit.pro.
Deprojection is necessary for accurate measurements of bar length, bar strength, and torque profiles, as projection effects can otherwise distort these parameters.

##5. barista_fourier.pro
This routine performs a Fourier decomposition of the deprojected galaxy image to quantify non-axisymmetric structures such as bars and spiral arms.
Using the galaxy center (cent), outer radius (R25), it calculates the bar strength (e.g., A2 = abs(a_2^2+b_2^2)/a_0)) and phase angles (Pi2, Pi4) for the m=2 and m=4 modes.

6. barista_bake_qtcake.pro
This routine computes the force ratio map (Q_T map) from the deprojected galaxy image, representing the ratio of tangential to radial forces in the disk.
You can determine the disk scale height (hz) from the disk scale length (hr) and morphological type (T).
The Q_T map—nicknamed “Qtcake” for its marble-cake-like appearance—is essentially baked in this routine and later sliced in radial and azimuthal directions for detailed analysis in the subsequent step.
Radial profiles of Ft, Fr, and Po are also provided as part of the output.

7. barista_cut_qtcake.pro
In this routine, you can cut the Qtcake to examine the properties of the bar.
Following the method of Lee et al. (2020, 2025), it separates the bulge-dominated and disk-dominated regions, measures the bar length (r_Qb) and strength (Qb), and determines the torque profile type (Qtr_class) as well as the bar classification (Bar_class).
The main outputs are the modified force ratio map (Qtcake_nb), the radial Q_T profile (Qt_r), and the azimuthal profile at the bar radius (Qt_cutcake), which corresponds to Figure 6(e) in Lee et al. (2025).


## Attribution
If you use this software for your research, please cite Lee et al. (2019).

<pre> @ARTICLE{2019ApJ...872...97L,
       author = {{Lee}, Yun Hee and {Ann}, Hong Bae and {Park}, Myeong-Gu},
        title = "{Bar Fraction in Early- and Late-type Spirals}",
      journal = {\apj},
     keywords = {galaxies: evolution, galaxies: formation, galaxies: photometry, 
                 galaxies: spiral, galaxies: structure, Astrophysics - Astrophysics of Galaxies},
         year = 2019,
        month = feb,
       volume = {872},
       number = {1},
          eid = {97},
        pages = {97},
          doi = {10.3847/1538-4357/ab0024},
 archivePrefix = {arXiv},
       eprint = {1901.05183},
 primaryClass = {astro-ph.GA},
       adsurl = {https://ui.adsabs.harvard.edu/abs/2019ApJ...872...97L},
      adsnote = {Provided by the SAO/NASA Astrophysics Data System}
} </pre>

@ARTICLE{2020ApJ...899...84L,
       author = {{Lee}, Yun Hee and {Park}, Myeong-Gu and {Ann}, Hong Bae and {Kim}, Taehyun and {Seo}, Woo-Young},
        title = "{Bar Classification Based on the Potential Map}",
      journal = {\apj},
     keywords = {Galaxy classification systems, Galaxy properties, Galaxy structure, Galaxy evolution, 582, 615, 622, 594, Astrophysics - Astrophysics of Galaxies},
         year = 2020,
        month = aug,
       volume = {899},
       number = {1},
          eid = {84},
        pages = {84},
          doi = {10.3847/1538-4357/aba4a4},
archivePrefix = {arXiv},
       eprint = {2007.04430},
 primaryClass = {astro-ph.GA},
       adsurl = {https://ui.adsabs.harvard.edu/abs/2020ApJ...899...84L},
      adsnote = {Provided by the SAO/NASA Astrophysics Data System}
}

@ARTICLE{2025ApJ...989...55L,
       author = {{Lee}, Yun Hee and {Hwang}, Ho Seong and {Cuomo}, Virginia and {Park}, Myeong-Gu and {Kim}, Taehyun and {Hwang}, Narae and {Ann}, Hong Bae and {Kim}, Woong-Tae and {Kim}, Hyun-Jeong and {Seok}, Ji Yeon and {Lee}, Jeong Hwan and {Choi}, Yeon-Ho},
        title = "{Search for Slow Bars in Two Barred Galaxies with Nuclear Structures: NGC 6951 and NGC 7716}",
      journal = {\apj},
     keywords = {Barred spiral galaxies, Galaxy structure, Galaxy dynamics, Galaxy evolution, Galaxy photometry, Galaxy spectroscopy, 136, 622, 591, 594, 611, 2171},
         year = 2025,
        month = aug,
       volume = {989},
       number = {1},
          eid = {55},
        pages = {55},
          doi = {10.3847/1538-4357/ade8ee},
       adsurl = {https://ui.adsabs.harvard.edu/abs/2025ApJ...989...55L},
      adsnote = {Provided by the SAO/NASA Astrophysics Data System}
}

