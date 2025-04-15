# BarIstA 
Bar Image astro-Arithmometer in IDL

## 1. barista_mask_neighbor.pro
This routine masks bright objects near the target galaxy and fills the masked region using values from neighboring pixels.

## 2. barista_ellisefit.pro
IDL routine to perform robust ellipse fitting of galaxy images, based on methods by Davis et al. (1985) and Athanassoula et al. (1990).
One advantage of this routine is that it provides robust ellipse fitting results without requiring initial guesses for the ellipticity or position angle (PA).
This routine requires the following subroutines: YH_ellipazi.pro; YH_fourier.pro; YH_centroid.pro

## 3. barista_overlay_ellipse.pro
This routine displays ellipses obtained from ellipse fitting on the input image.

## 4. barista_deprojection.pro
This routine deprojects a galaxy image to faced-on using orientation parameters
The orientation parameters are typically obtained from ellipse fitting (i.e. barista_ellipsefit.pro)


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


