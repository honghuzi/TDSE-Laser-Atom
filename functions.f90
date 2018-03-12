module Functions
   use Const, only:DOUBLE, SINGLE, PI, ngrid
   implicit none
   private
   public :: GetGrid, GetV, CheckDelete, norm, shift

contains
   subroutine GetGrid(dx, nx, x, p)
      real(DOUBLE), intent(in) :: dx
      integer(SINGLE), intent(in) :: nx
      real(DOUBLE), dimension(nx), intent(out) :: x
      real(DOUBLE), dimension(nx), intent(out) :: p
      real(DOUBLE) dp
      x = dx*[-nx/2:nx/2 - 1]
      dp = 2*pi/nx/dx
      p = dp*[0:nx/2 - 1, -nx/2:-1]
   end subroutine GetGrid

   subroutine GetV(x, V, soft1, soft2)
      real(DOUBLE), intent(in) :: soft1, soft2
      real(DOUBLE), dimension(:), intent(in) :: x
      real(DOUBLE), dimension(:, :), intent(out) :: V
      integer(SINGLE) i

      do i = 1, size(x)
         V(:, i) = -2.0d0/dsqrt(x**2 + soft1) - 2.0d0/dsqrt(x(i)**2 + soft1) + &
                   1.0d0/dsqrt((x - x(i))**2 + soft2)
      end do
   end subroutine GetV

   subroutine CheckDelete(filename)
      character(*), intent(in) :: filename
      integer(SINGLE) stat
      open (unit=1234, iostat=stat, file=filename, status='old')
      if (stat == 0) close (1234, status='delete')
   end subroutine CheckDelete

   subroutine norm(u, dx)
      complex(DOUBLE), dimension(:, :), intent(inout) :: u
      real(DOUBLE), intent(in) :: dx

      real(DOUBLE), dimension(ngrid):: mid
      integer(SINGLE) j
      do j = 1, ngrid
         mid(j) = sum(abs(u(:, j))**2)
      end do
      u = u/dsqrt(sum(mid))/dx
   end subroutine norm

   subroutine Shift(u)
      implicit none
      complex(DOUBLE), dimension(:, :), intent(inout) :: u
      integer(SINGLE) :: i, kk
      complex(DOUBLE) uw(size(u, 1)/2)

      kk = size(u, 1)

      ! u = CSHIFT(u, kk/2)
      ! u = CSHIFT(u, kk/2, DIM = 2)
      do i = 1, kk/2
         uw = u(1:kk/2, i)
         u(1:kk/2, i) = u(kk/2 + 1:kk, i + kk/2)
         u(kk/2 + 1:kk, i + kk/2) = uw
         uw = u(1:kk/2, i + kk/2)
         u(1:kk/2, i + kk/2) = u(kk/2 + 1:kk, i)
         u(kk/2 + 1:kk, i) = uw
      end do
   end subroutine Shift
end module Functions
