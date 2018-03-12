!include 'mkl_dfti.f90'
module Const
   implicit none
   private
   public :: SINGLE, DOUBLE, PI, C, IM, &
             ngrid, &
             dx, dt, soft1, soft2, status, nt, La, Ls, Da, Ds

   integer, parameter :: SINGLE = KIND(0.0), DOUBLE = KIND(0.0d0)
   real(DOUBLE), parameter :: PI = 3.14159d0
   real(DOUBLE), parameter :: C = 3.0d8
   complex(DOUBLE), parameter :: IM = DCMPLX(0.0d0, 1.0d0)
   integer(SINGLE), parameter :: ngrid = 2**13

   real(DOUBLE) :: La, Ls, Da, Ds
   integer(SINGLE) :: nt, status
   real(DOUBLE) :: dx, dt, soft1, soft2

end module Const
