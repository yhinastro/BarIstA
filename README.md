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

```idl
ellipsefit_result = barista_ellipsefit(input_img = img, result = ellipsefit_result, $
    cent = [xc, yc], fix_cent = 'fix', step = 1, R25 = R25)

