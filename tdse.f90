include 'mkl_dfti.f90'
program main
   use MKL_DFTI
   use Const
   use Laser
   use Vector, only:x, p, V
   use Functions
   implicit none

   namelist/inputlist/dx, dt, soft1, soft2, La, Ls, Da, Ds

   dx = 0.2
   dt = 0.1
   soft1 = 0.707d0**2
   soft2 = 0.582d0**2

   La = 750.0d0
   Ls = 150.0d0
   Da = 15.0d0
   Ds = 10.0d0

   open (100, file='input.nml', delim='apostrophe')
   read (unit=100, nml=inputlist)
   close (100)

   call GetGrid(dx, ngrid, x, p)
   call GetV(x, V, soft1, soft2)


   call ground
   call propagation
   call DataManager
end program main
