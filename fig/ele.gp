reset

set loadpath 'D:/libs/gnuplotconf'
load 'configs/xyborder.cfg'
load 'configs/grid.cfg'

set t eps font "Arial, 14" size 3, 2.8
set o "ele.eps"

set title 'electric field'
set xlabel "t (a.u.)"
set ylabel "E (a.u.)"
unset key
# set xrange [-2.5:2.5]
# set yrange [-2.5:2.5]

set border lw 2
set tics front
# set xtics 0.5; set ytics 0.5
plot '../data/ele.bin' binary format='%float64' using 1:2 w l ls 1
unset output