module Vector
   use Const, only:ngrid, DOUBLE
   implicit none
   private
   public :: V, x, p, &
             t, ele, absorb, split, A

   real(DOUBLE), dimension(ngrid, ngrid) :: V
   real(DOUBLE), dimension(ngrid) :: x, p

   real(DOUBLE), dimension(:), allocatable :: t
   real(DOUBLE), dimension(:), allocatable :: ele
   real(DOUBLE), dimension(:), allocatable :: absorb, split
   real(DOUBLE), dimension(:), allocatable :: A

end module Vector
