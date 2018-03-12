subroutine DataManager
   use Const, only:SINGLE, DOUBLE, PI, ngrid, nt, dx, dt
   use Functions, only:CheckDelete
   IMPLICIT NONE

   complex(DOUBLE), dimension(:, :), allocatable :: up

   real(DOUBLE) :: p_max, ratio, dp
   real(DOUBLE) :: de
   real(DOUBLE) :: e_max, ebin_max
   real(DOUBLE), dimension(:), allocatable :: ebin, px, py
   real(DOUBLE), dimension(:, :), allocatable  :: up2
   real(DOUBLE) :: energy
   real(DOUBLE) :: t(nt)
   integer :: ngrid2
   integer(SINGLE) :: ne

   integer :: i, j

   p_max = 3.0
   ratio = PI/dx/p_max
   dp = 2*PI/ngrid/dx
   de = 0.005
   ne = 1000
   ngrid2 = int(ngrid/ratio)
   e_max = de*ne
   allocate (ebin(ne), px(ngrid2*ngrid2), py(ngrid2*ngrid2))
   allocate (up(ngrid, ngrid))
   allocate (up2(ngrid2, ngrid2))

   call CheckDelete("momentum.bin")
   call CheckDelete("energy.bin")
   open (100, file='data/p.bin', access='stream')
   read (100) up
   close (100)

   ebin = 0.0d0
   forall (i=1:ne) ebin(i) = de*i

   do j = 1, ngrid2
      do i = 1, ngrid2
         up2(i, j) = abs(up((ngrid - ngrid2)/2 + i, (ngrid - ngrid2)/2 + j))**2
         px(ngrid2*(j - 1) + i) = (-ngrid2/2 + i)*dp
         py(ngrid2*(i - 1) + j) = (-ngrid2/2 + j)*dp
         energy = ((-ngrid2/2 + i)**2 + (-ngrid2/2 + j)**2)*dp**2/2.0
         if (energy < de*ne) then
            ebin(int(energy/de) + 1) = ebin(int(energy/de) + 1) + up2(i, j)
         end if
      end do
   end do

   ebin_max = maxval(ebin)
   ebin = ebin/ebin_max

   forall (i=1:nt) t(i) = i*dt

   open (100, file='data2/momentum.bin', access='stream')
   open (400, file='data2/energy.bin', access='stream')

   write (100) ((px(ngrid2*(j - 1) + i), py(ngrid2*(i - 1) + j), up2(i, j), i=1, ngrid2), j=1, ngrid2)
   write (400) (de*i, ebin(i), i=1, ne)

   close (100)
   close (400)

end Subroutine DataManager
