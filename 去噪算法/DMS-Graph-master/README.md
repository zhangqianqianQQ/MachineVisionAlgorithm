DMS_Graph

*******************************************************
* author: Yacouba Kaloga                              *
* institution: CNRS, LPENSL                           *
* date:   September 1 2018     	                      *
* revised verion 2.0: Monday, Mai 20 2019             *
* License CeCILL-B                                    *
*******************************************************


*****************************************************
* RECOMMENDATIONS:                                  *
* This toobox is designed to work with              *
* Matlab R2017b including                           *
*****************************************************

------------------------------------------------------------------------------------
DESCRIPTION:
The discrete Mumford-Shah formalism has been introduced for the image 
denoising problem, allowing to capture both smooth behavior inside an 
object and sharp transitions on the boundary. In the present work, we 
propose first to extend this formalism to graphs and to the problem of 
mixing matrix estimation. New algorithmic schemes with convergence 
guarantees relying on proximal alternating minimization strategies are 
derived and their efficiency (good estimation and robustness to 
initialization) are evaluated on simulated data, in the context of vote 
transfer matrix estimation.



------------------------------------------------------------------------------------
SPECIFICATIONS for using DMS_Graph:

A demo.m file allows to display an example of mixing matrice estimation 
when the graph is associated with the Lyon city vote location.

We display the estimation result after 1 iteration, 50 iterations and 
after convergence.

------------------------------------------------------------------------------------
RELATED PUBLICATIONS:

Y. Kaloga, M. Foare, N. Pustelnik, and P. Jensen , Discrete Mumford-Shah on graph 
for mixing matrix estimation, accepted in IEEE Signal Processing Letters, 2019.

-------------------------------------------------------------------------------------


![alt text](http://perso.ens-lyon.fr/nelly.pustelnik/images/ill_DMS_Graph.jpg)
