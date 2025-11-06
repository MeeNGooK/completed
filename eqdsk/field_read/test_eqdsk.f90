program test_eqdsk
  use eqdsk_reader
  implicit none

  type(eqdsk_data) :: eq
  integer :: i,j
  call read_eqdsk("g147131.02300_DIIID_KEFIT", eq)

  print *, "B_center: ", eq%bcentr
  print *, "zgrid:", eq%zgrid1
  print *, "rgrid:", eq%rgrid1
  print *, 'zmid:', eq%zmid
  print *, 'zdim:', eq%zdim
  print *, 'rleft:', eq%rleft
  print *, 'rdim:', eq%rdim
  print *, "|ψ(R=1.5,Z=0)| ≈ ", eq%psi(50,65)  ! 인덱스는 예시
  do i=1, eq%nw
    print*, eq%fpol(i)
  end do
end program
