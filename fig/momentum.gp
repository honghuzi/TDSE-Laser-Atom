reset

set loadpath 'D:/libs/gnuplotconf'
load 'configs/xyborder.cfg'
# load 'configs/grid.cfg'
load 'palettes/parula.pal'
#set palette negative
#moreland, parula, orrd, plasma, rdbu, rdylbu, spectral, whylrd, ylrd, bugn, bupu, chromajs, inferno, pubu, purd, rdbu,
set t  eps font "Arial, 14" #size 3, 2.8
set size ratio 1
set o "temp"

set title 'momentum spectrum'
set xlabel "P_1 (a.u.)"
set ylabel "P_2 (a.u.)"
unset key
set logscale zcb
L = 2.5
# set xrange [-L:0]
# set yrange [0:L]
set xrange [-L:L]
set yrange [-L:L]

set format cb"10^{%1T}"

set border lw 2
set tics front
set xtics 1; set ytics 1 
# set xtics 0.5; set ytics 0.5 
# set arrow 1 from -L, 0 to L, 0 nohead front ls 101 lw 3
# set arrow 2 from 0, -L to 0, L nohead front ls 101 lw 3
#set palette defined (0 "blue", 1 "white", 2 "red")
#set view map
plot '../data2/momentum.bin' binary format='%float64' w image
unset output
set o "p.eps"
offset = GPVAL_CB_MAX
#show variables all
#set pm3d map
set cbrange [1e-3: 1]
plot "" binary format='%float64' u 1:2:($3/offset*3) w image
#splot "" binary format='%float64' u 1:2:($3/offset) w points palette
set output
