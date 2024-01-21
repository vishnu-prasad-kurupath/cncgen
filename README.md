# **cncgen.tcl** (carbon-nanocone generator)

A TCL script to create carbon nano-cone using [VMD](https://www.ks.uiuc.edu/Research/vmd/)

## **USAGE:**

- **vmd -dispdev text -eofexit -e /path/to/file/cncgen.tcl -args \<type> \<cone-length>**
  - \<type> can be 1,2,3,4 or 5, representing carbon-nanocones of half-cone angles 9.6, 19.45, 30.0, 41.8 and 56.45 degrees <br />
  - \<cone-length> is the desired length of the cone from apex to base

## **CAUTION**
The script wraps the graphene lattice produced by VMD to form a conical surface, providing a continuous conical surface of hexagonal carbon rings. This however does not guarantee that the structural nuances of the nanocone apex is handled optimally from a material science point of view. 
 
## **License**

GNU General Public License v3.0
