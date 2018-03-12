module Laser
   use Const, only:SINGLE, DOUBLE, C, PI
   implicit none
   private
   public :: gaussfield, trapezoidalfield, sin2field, GetEle, GetEleG, GetEleT, GetEleS, ItoE0

   interface GetEle
      module procedure GetEleG, GetEleT, GetEleS
   end interface GetEle

   type :: field
      real(DOUBLE) :: E0
      real(DOUBLE) :: omega
      real(DOUBLE) :: cep
   end type field
   type, extends(field) :: gaussfield
      real(DOUBLE) :: tau
      real(DOUBLE) :: tm
   end type gaussfield
   type, extends(field) :: trapezoidalfield
      real(DOUBLE) :: tStart
      integer :: nUp
      integer :: nHori
      integer :: nDown
   end type trapezoidalfield
   type, extends(field) :: sin2field
      real(DOUBLE) :: tau
      real(DOUBLE) :: tm
   end type sin2field

contains
   function GetEleG(pulse, t_in)
      type(gaussfield), intent(in) :: pulse
      real(DOUBLE), intent(in) :: t_in
      real(DOUBLE) :: GetEleG
      real(DOUBLE) :: E0, omega, cep, tm, tau
      real(DOUBLE) :: t

      E0 = pulse%E0
      omega = pulse%omega
      T = 2*PI/omega
      cep = pulse%cep
      tm = pulse%tm
      tau = pulse%tau

      t = t_in - tm
      GetEleG = E0*cos(omega*t - cep)*dexp(-2.0d0*log(2.0d0)*(t/tau)**2)
   end function GetEleG

   function GetEleT(pulse, t_in)
      type(trapezoidalfield), intent(in) :: pulse
      real(DOUBLE), intent(in) :: t_in
      real(DOUBLE) :: GetEleT
      real(DOUBLE) :: t
      real(DOUBLE) :: E0, omega, TT, cep, tStart, t1, t2, t3
      integer(SINGLE) :: nUp, nHori, nDown

      E0 = pulse%E0
      omega = pulse%omega
      TT = 2*PI/omega
      cep = pulse%cep
      tStart = pulse%tStart
      nUp = pulse%nUp
      nHori = pulse%nHori
      nDown = pulse%nDown

      GetEleT = 0.0d0
      t1 = tStart + nUp*TT
      t2 = tStart + (nUp + nHori)*TT
      t3 = tStart + (nUp + nHori + nDown)*TT
      if (t > tStart .AND. t < t1) then
         GetEleT = (t - tStart)/nUp/TT
      end if
      if (t > t1 .AND. t < t2) then
         GetEleT = 1.0d0
      end if
      if (t > t2 .AND. t < t3) then
         GetEleT = (t - tStart - (nUp + nHori)*TT)/(nDown)*TT
      end if

      GetEleT = GetEleT*E0*cos(omega*t - cep)
   end function GetEleT

   function GetEleS(pulse, t_in)
      type(sin2field), intent(in) :: pulse
      real(DOUBLE), intent(in) :: t_in
      real(DOUBLE) :: GetEleS
      real(DOUBLE) :: t
      real(DOUBLE) :: E0, omega, cep, tau, tm, tStart, tEnd

      E0 = pulse%E0
      omega = pulse%omega
      cep = pulse%cep
      tau = pulse%tau
      tm = pulse%tm

      tStart = tm - tau/2
      tEnd = tm + tau/2
      GetEleS = 0.0d0

      t = t_in
      if (t > tStart .and. t < tEnd) then
         GetEleS = E0*cos((t - tm)*PI/tau)**2*cos(omega*(t - tm) - cep)
      end if
   end function GetEleS

   function ItoE0(I_si)
      real(DOUBLE), intent(in) :: I_si
      real(DOUBLE) :: ItoE0
      real(DOUBLE) :: E_si
      real(DOUBLE) :: E0
      E_si = 2.742d3*dsqrt(I_si)
      ItoE0 = E_si/5.1421d11
   end function ItoE0

end module Laser
