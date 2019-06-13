Non-local Bayes for Matlab
==========================

Implementation of the non-local Bayes denoising algorithm for matlab.

Compilation
-----------

The main function is `nlbayes.m`. This script runs two steps of nl-bayes denoising.
You need to modify the code of the script to change parameters, input image, etc.

Notes
-----

For simplicity, this version has some differences with respect to the [IPOL
implementation][1]:

* We work in both steps with RGB patches. The IPOL implementation does a different
  handling of color in the first step.
* We consider always `prms.np` similar patches. The IPOL implementation can use more
  similar patches in the second step, if the distances are smaller than a threshold.
* The user needs to provide all parameters.
* We add a parameter `prms.r` to reduce the rank of the _a priori_ covariance matrix.
  Only the `r` leading eigenvectors of the covariance matrix are kept.
  It is disabled by default.

[1]: http://www.ipol.im/pub/art/2013/16/ 


Visualization of Patch Groups Computed by NL-Bayes
==================================================

The function `patch_group_image.m` is an interactive tool for visualizing the
patch groups built by the (video) nlbayes algorithm.

Parameters
----------

The following parameters can be specified by modifying the code:
* patches size
* search region
* number of similar patches

Noise values
------------

The noise value can be controlled using the interactive tool.

Names of the image files
------------------------

The function dumps images with the result with the naming convention:

`patch_group_[IMAGE]_[REFx]_[REFy]_s[SIGMA]_[DISTA]_[WSZ]_[PSZ]_[NP]_[CODE].png`

where
* `IMAGE` : name of the image where we took the patches from
* `REFx ` : x coordinate of top-left pixel in reference patch
* `REFy ` : y coordinate of top-left pixel in reference patch
* `SIGMA` : noise std. deviation
* `DISTA` : patch distance used (e.g. l1 or l2)
* `WSZ`   : (spatial) size of search region
* `PSZ`   : (spatial) patch size
* `NP`    : number of similar patches
* `CODE ` : a 4-letter code indicating what the file shows (see bellow)

For example:

`patch_group_traffic_coor_545_290_s20.png`

shows the coordinates (coor) of the similar patches for a reference patch at
position (545,290) in the image `traffic` with sigma = 20.


What is shown in each file?
---------------------------

For each reference patch and each noise value we show several images
identified with a 4 letter abbreviation:

* `coor`: coordinates of the top-left corner of the nearest neighbors shown in
the search region. We use the following color code:
	- RED  : nearest neighbors from 1 to 5
	- GREEN: nearest neighbors from 6 to 45
	- BLUE : rest of the nearest neighbors

* `nisy`: set of noisy similar patches found in the search region. 
      The reference patch is in the top-left corner. The nearest neighbors
      are ordered from left-to-right, top-to-bottom.

* `orig`: the noiseless version of the patches in 'nisy' image. Note that the 
      similar patches were found according to the distance between the 
      noisy patches. The noiseless version is shown to see how the set
      of similar patches degrades when the noise increases.

* `pcas`: mean patch and eigenvectors of the sample covariance matrix. The 
      patch in the top-left corner is the mean patch. The eigenvectors
      are shown ordered by decreasing variance from left-to-right, 
      top-to-bottom. To visualize the eigenvalues, we add a color-coded
      border around each eigenvector.
	- A GREEN border, indicates an eigenvalues larger than sigma^2. The
      intensity of the green is proportional to `\sqrt{\lambda_i} - \sigma.`
	- A RED border shows an eigenvalue smaller than sigma^2 with intensity
      proportional to `\sigma - \sqrt{\lambda_i}.`

* `eigs`: plot of the square root of the eigenvalues, compared to sigma. In blue
      we plot the positive eigenvals, and in red the negative.
      Don't pay attention to the legend in the plot, it's wrong!

