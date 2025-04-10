# barista_ellipsefit

IDL routine to perform robust ellipse fitting of galaxy images, based on methods by Davis et al. (1985) and Athanassoula et al. (1990).
One advantage of this routine is that it provides robust ellipse fitting results without requiring initial guesses for the ellipticity or position angle (PA).
This routine requires the following subroutines:
YH_ellipazi.pro, YH_fourier.pro, YH_centroid.pro for this routine.

## Input Parameters

| Parameter   | Description                                       |
|-------------|---------------------------------------------------|
| `input_img` | 2D galaxy image                                   |
| `result`    | Output filename                                   |
| `cent`      | Galaxy center as `[x, y]`                         |
| `fix_cent`  | `'fix'` or `'move'` for fixing/moving the center |
| `step`      | Radius increment for fitting (in pixels)          |
| `R25`       | Maximum fitting radius (in pixels)                |

## Output

Text file containing:
- Radius, intensity, center coordinates, ellipticity, PA, A/B Fourier terms

## Example
ellipsefit_result = barista_ellipsefit(input_img = img, result = ellipsefit_result, $
    cent = [xc, yc], fix_cent = 'fix', step = 1, R25 = R25)

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


