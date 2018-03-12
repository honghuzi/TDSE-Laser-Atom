subroutine ground
   use mkl_dfti
   use Const, only:ngrid, dx, dt, soft1, soft2, DOUBLE, SINGLE, status
   use Functions, only:GetGrid, GetV, CheckDelete, norm
   use Vector, only:V, x, p
   implicit none

   complex(DOUBLE), dimension(:, :), allocatable :: u, u0
   real(DOUBLE), dimension(ngrid) :: u_row
   complex(DOUBLE) :: Eg
   real(DOUBLE) du
   character(DOUBLE) nowtime
   integer(SINGLE) i, j, count
   type(dfti_descriptor), pointer :: handle

   allocate (u(ngrid, ngrid), u0(ngrid, ngrid))

   call CheckDelete('data/gs.bin')

   status = dfticreatedescriptor(handle, dfti_double, dfti_complex, 2, (/ngrid, ngrid/))
   ! status = dftisetvalue(handle, dfti_input_strides,(/0, 1, ngrid/))
   status = dftisetvalue(handle, dfti_backward_scale, 1.0d0/(ngrid*ngrid))
   ! use mkl_user_num_threads make the program even slower

   status = dfticommitdescriptor(handle)

   u = abs(V)

   call norm(u, dx)
   count = 0
   du = 1.0d0

   call time(nowtime)
   print'("time is: ", T20, A)', nowtime

   do j = 1, ngrid
      u(:, j) = u(:, j)*exp(-dt/2d0*V(:, j))
   end do

   do while (du > 1.0d-15)
      u0 = u

      status = dfticomputeforward(handle, u(:, 1))

      do j = 1, ngrid
         u(:, j) = u(:, j)*exp(-dt/2d0*(p**2 + p(j)**2))
      end do

      status = dfticomputebackward(handle, u(:, 1))
      do j = 1, ngrid
         u(:, j) = u(:, j)*exp(-dt*V(:, j))
      end do

      call norm(u, dx)

      do j = 1, ngrid
         u_row(j) = maxval(abs(u(:, j) - u0(:, j)))
      end do

      du = maxval(u_row)
      count = count + 1

      if (mod(count, 100) == 0) then
         print'("count = ", I4, 5X, "du = ", Es11.4)', count, du
      end if
   end do

   status = dfticomputeforward(handle, u(:, 1))

   do j = 1, ngrid
      u(:, j) = u(:, j)*exp(-dt/2d0*(p**2 + p(j)**2))
   end do
   status = dfticomputebackward(handle, u(:, 1))

   do j = 1, ngrid
      u(:, j) = u(:, j)*exp(-dt/2.0d0*V(:, j))
   end do

   call norm(u, dx)
   call time(nowtime)
   print'("time is:", T20, A)', nowtime

   Eg = 0.0d0
   do i = 2, ngrid - 1
      do j = 2, ngrid - 1
         Eg = Eg + dconjg(u(i, j))*(-0.5d0*(u(i - 1, j) + u(i + 1, j) + u(i, j - 1) + u(i, j + 1) - 4.0d0*u(i, j))/dx**2 &
                                    + V(i, j)*u(i, j))*dx**2
      end do
   end do

   print'("The ground state energy is : ", 4X, F8.5)', dreal(Eg)
   open (100, file='data/gs.bin', access='stream')
   write (100) u
   close (100)

   status = dftifreedescriptor(handle)
   deallocate (u, u0)

end subroutine ground
