subroutine propagation
   use mkl_dfti
   use Const, only:IM, PI, DOUBLE, SINGLE, ngrid, dx, dt, nt, soft1, soft2, &
        status, La, Ls, Da, Ds
   use Functions, only:GetGrid, GetV, CheckDelete, norm, shift
   use Vector, only:V, x, p, t, ele, absorb, split, A
   use Laser, only:gaussfield, trapezoidalfield, sin2field, GetEle, GetEleG, GetEleT, GetEleS, ItoE0
   implicit none

   complex(DOUBLE), dimension(:, :), allocatable :: u, ue, uo, up
   complex(DOUBLE), dimension(:), allocatable :: pp

   real(DOUBLE) :: tExtra = 150.0/0.2
   integer(SINGLE) :: n1, n2, ngrid2 = ngrid/2
   character(10) nowtime
   integer(SINGLE) statusp
   integer(SINGLE) i, j, it
   type(sin2field) :: f1, f2, f3

   type(dfti_descriptor), pointer :: handle
   type(dfti_descriptor), pointer :: handlep
   call CheckDelete('data/fs.bin')
   call CheckDelete('data/ele.bin')
   call CheckDelete('data/p.bin')
   f1 = sin2field(ItoE0(1.0d15), 1.86, 0.0, 30.0, 15.0)
!    f2 = sin2field(ItoE0(1.0d15)/2, 1.70, 0.0, 800.0, 800.0)
   f3 = sin2field(ItoE0(1.0d15), 1.74, 0.0, 30.0, 40.0)
!    nt = int((max(f1%tau + f1%tm, f2%tau + f2%tm, f3%tau + f3%tm) + tExtra)/dt)
    nt = int((max(f1%tau + f1%tm, f3%tau + f3%tm) + tExtra)/dt)
   allocate (u(ngrid, ngrid), uo(ngrid, ngrid), up(ngrid, ngrid))
   allocate (absorb(ngrid), split(ngrid))
   allocate (pp(ngrid))
   allocate (t(nt), ele(nt), A(nt))

   forall (i=1:nt) t(i) = i*dt
   do i = 1, nt
    !   ele(i) = GetEle(f1, t(i)) + GetEle(f2, t(i)) + GetEle(f3, t(i))
      ele(i) = GetEle(f1, t(i)) + GetEle(f3, t(i))
   end do
   print*, "tmax=", maxval(t)
   open (100, file='data/ele.bin', access='stream')
   write (100) (t(i), ele(i), i=1, nt)
   close (100)
   open (200, file='data/gs.bin', access='stream')
   read (200) u
   close (200)

   uo = 0.0d0
   up = 0.0d0
   absorb = 1.0d0/(1.0d0 + dexp(-(abs(x) - La)/Da))
   split = 1.0d0/(1.0d0 + dexp(-(abs(x) - Ls)/Ds))
   n1 = int(ngrid/2 - 100.0d0/dx)
   n2 = int(ngrid/2 + 100.0d0/dx)

   A(1) = ele(1)*dt
   do i = 2, nt
      A(i) = A(i - 1) - ele(i)*dt
   end do

   status = dfticreatedescriptor(handle, dfti_double, dfti_complex, 2, (/ngrid, ngrid/))
   ! status = dftisetvalue(handle, dfti_input_strides,(/0, 1, ngrid/))
   status = dftisetvalue(handle, dfti_backward_scale, 1.0d0/(ngrid*ngrid))
   ! use mkl_user_num_threads make the program even slower

   statusp = DftiCreateDescriptor(handlep, dfti_double, dfti_complex, 2, (/ngrid, ngrid/))
   !status = DftiSetValue(handle, dfti_input_strides,(/0, 1, ngrid/))
   statusp = DftiSetValue(handlep, dfti_forward_scale, 1.0d0/ngrid)

!!!!! use mkl_user_num_threads make the program even slower
   statusp = DftiCommitDescriptor(handlep)

   status = DftiCommitDescriptor(handle)
   call time(nowtime)
   print'("time is:", T20, A)', nowtime

   do it = 1, nt
      do j = 1, ngrid
         u(:, j) = u(:, j)*exp(-im*dt/2d0*(V(:, j) + ele(it)*(x + x(j))))
      end do
      status = dfticomputeforward(handle, u(:, 1))

      do j = 1, ngrid
         u(:, j) = u(:, j)*exp(-im*dt/2d0*(p**2 + p(j)**2))
      end do

      status = dfticomputebackward(handle, u(:, 1))

      do j = 1, ngrid
         u(:, j) = u(:, j)*exp(-im*dt/2d0*(V(:, j) + ele(it)*(x + x(j))))
      end do

      do j = 1, ngrid
         u(:, j) = u(:, j)*(1.0-absorb)*(1.0-absorb(j))
      end do

      if (mod(it, 500) == 0) then
         print *, 'calculated', 100*it/real(nt), '%'
         call flush(250)
      end if
      if (mod(it, 4) == 0) then
         do j = 1, ngrid
            uo(:, j) = u(:, j)*split*split(j)*exp(-im*A(it)*(x + x(j)))
         end do
         statusp = dfticomputeforward(handlep, uo(:, 1))
         pp = p**2/2.0d0*(nt - it) - p*sum(A(it:nt)) + sum(A(it:nt)**2)/2.0d0
         do j = 1, ngrid
            uo(:, j) = uo(:, j)*exp(-im*dt*(pp + pp(j)))
         end do
         call shift(uo)
         do j = 1, ngrid
            up(:, j) = up(:, j) + uo(:, j)
         end do
      end if
   end do

   status = dftifreedescriptor(handle)
   statusp = dftifreedescriptor(handlep)

   call time(nowtime)
   print'("time is:", T20, A)', nowtime

   call flush(250)
   close (250)
   open (100, file='data/fs.bin', access='stream')
   write (100) u
   close (100)
   open (100, file='data/p.bin', access='stream')
   write (100) up
   close (100)

   call time(nowtime)
   print'("time is:", T20, A)', nowtime

   deallocate (u, up)

end subroutine propagation
