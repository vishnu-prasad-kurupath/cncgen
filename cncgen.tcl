# Copyright (C) 2023  Vishnu Prasad Kurupath (https://vishnu-prasad-kurupath.github.io/)
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
# for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <https://www.gnu.org/licenses/>. 

package require nanotube
package require psfgen

# Help----------------------------------------------------------------
if { ([lindex $argv 0] == "-h") || 
	($argc != 3) || 
	(![string is int -strict [lindex $argv 0]]) || 
	(![string is double -strict [lindex $argv 1]]) } {
	puts "NANOCONE SCRIPT USAGE:"
	puts "vmd -dispdev text -eofexit -e /path/to/file/cncgen.tcl -args <type> <cone-length>"
	puts "\t <type> (int) can be 1,2,3,4 or 5, representing carbon-nanocones of half-cone angles"
	puts "\t 9.6, 19.45, 30.0, 41.8 and 56.45 degrees"
	puts "\t <cone-length> (float) desired length of the cone from apex to base"
exit
}

# User Parameters-----------------------------------------------------
set type [lindex $argv 0] 
set conlen [lindex $argv 1] 

# Other Parameters----------------------------------------------------

# Sector Angle Removed in Radians
set thet [expr {$type*60*3.14159/180}] 

# Half Cone Angle in Radians
set alphr [expr {asin(1-($thet/(2*3.14159)))}]

# Max length of Cone Slant
set lmax [expr {($conlen/cos($alphr))}]

# Length for Creating Graphene Sheet
set shtl [expr {(2*$lmax/10.0)+0.7}] 

# Radius of Circle to Be cut
set secr [expr {$lmax*$lmax+4*$lmax+4}] 

# Half of Angle Removed(Circle) in Radians
set theta [expr $thet/2]

# For Slope to Cut Sector
set cottheta [expr {1/tan($theta)}]

# Angle Remaining after Forming Sector in Radians
set resttheta [expr 2*3.14159-$thet]

# Base Radius of the Cone
set rcon [expr ($resttheta*$lmax)/(2*3.14159)]

# Half of Angle Remaining after Forming Sector in Radians
set startheta [expr $resttheta/2]

# Create a graphene sheet---------------------------------------------
graphene -lx $shtl -ly $shtl -type armchair -b 0;
set sel [atomselect top all]
set cen [measure center $sel]
$sel moveby [vecscale -1.0 $cen]
set xm -0.614;
if {($type == 2) || ($type == 3)} {
	set xm [expr -1.0*$xm]
}
set mv "$xm 0.0 0.0" 
$sel moveby $mv; 
$sel set resname CON 
$sel writepdb sheet.pdb
$sel writepsf sheet.psf

# Make the sheet a circle---------------------------------------------
mol load psf sheet.psf pdb sheet.pdb
set sel [atomselect top "x*x+y*y<$secr"]
$sel writepdb circle.pdb
$sel writepsf circle.psf

# Cut a sector from circle--------------------------------------------
mol load psf circle.psf pdb circle.pdb
if { $type == 1 } {
	set tn [expr {tan(60*3.14159/180)}]
	set sel [atomselect top "y<x*$tn or y<-x*$tn"]
	set theta [expr {30*3.14159/180}] 
	$sel writepsf sector.psf
	$sel writepdb sector.pdb
} elseif { $type == 2 } {
	set tn [expr {tan(60*3.14159/180)}]
	set sel [atomselect top "y<0 or y<-x*$tn"]
	set theta [expr {60*3.14159/180}] 
	$sel writepsf sector.psf
	$sel writepdb sector.pdb
} elseif { $type == 3 } {
	set sel [atomselect top "y<0"]
	set theta [expr {90*3.14159/180}]
	$sel writepsf sector.psf
	$sel writepdb sector.pdb
} elseif { $type == 4 } {
	set tn [expr {-1*tan(60*3.14159/180)}]
	set sel [atomselect top "y<0 and y<-x*$tn"]
	set theta [expr {120*3.14159/180}]
	$sel writepsf sector.psf
	$sel writepdb sector.pdb
} elseif { $type == 5 } {
	set tn [expr {-1*tan(60*3.14159/180)}]
	set sel [atomselect top "y<x*$tn and y<-x*$tn"]
	set theta [expr {150*3.14159/180}]
	$sel writepsf sector.psf
	$sel writepdb sector.pdb
}

# Fold the sector to cone---------------------------------------------
mol load psf sector.psf pdb sector.pdb
set sel [atomselect top all]
set index [$sel list]
foreach at $index {
	set atsel [atomselect top "index $at"]
	set coord [measure center $atsel]
	set x [lindex $coord 0]
	set y [lindex $coord 1]
	set xy [expr {sqrt($x*$x+$y*$y)}]
	set slope [expr {$y/$x}]
	set slopang [expr {atan($slope)}]
	if { ($x >= 0) && ($y >= 0) } {
		if { ($x > -0.0001) && ($x < 0.0001) } {
			set slopang [expr 3.14159/2] }
		set gamma [expr {3.14159/2-$theta-$slopang}]
	} elseif { ($x >= 0) && ($y <= 0) } {
		if { ($x > -0.0001) && ($x < 0.0001) } {
			set slopang [expr -3.14159/2] }
		set gamma [expr {3.14159/2-$theta-$slopang}] 
#		set gamma [expr {-1*$slopang}] 
	} elseif { ($x <= 0) && ($y <= 0) } {
		if { ($x > -0.0001) && ($x < 0.0001) } {
			set slopang [expr 3.14159/2] }
		set gamma [expr {(3*3.14159)/2-$theta-$slopang}] 
#		set gamma [expr {3.14159-$slopang}] 
	} elseif { ($x <= 0) && ($y >= 0) } {
		if { ($x > -0.0001) && ($x < 0.0001) } {
			set slopang [expr -3.14159/2] }
		set gamma [expr {(3*3.14159)/2-$theta-$slopang}] 
	}
	set beta [expr 3.14159*$gamma/$startheta]
	set r2 [expr $xy*$startheta/3.14159]
	set xc [expr {$r2*cos($beta)}]
	set yc [expr {$r2*sin($beta)}]
	set zc [expr {$xy*cos($alphr)}]
	set concord "{$xc $yc $zc}"
	$atsel set {x y z} "{$xc $yc $zc}"
	}
$sel writepsf cone-${type}-${conlen}.psf
$sel writepdb cone-${type}-${conlen}.pdb

# Remove intermediate files------------------------------------------
exec rm -f sheet.psf circle.psf sector.psf flatcone.psf
exec rm -f sheet.pdb circle.pdb sector.pdb flatcone.pdb

# Terminate----------------------------------------------------------
mol delete all
exit
