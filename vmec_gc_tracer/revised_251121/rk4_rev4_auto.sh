#!/bin/bash

MODDIR=build
OUTFILE=main.exe

mkdir -p "$MODDIR"

# ===== 소스 파일 목록 =====
SRC=(
  set_values.cuf
  modules/trig_compute.cuf
  modules/spline2.cuf
  modules/fourier3.cuf
  modules/spline.cuf
  modules/fourier1.cuf
  reader/nc_reader.cuf
  rk4_init_boun.cuf
)

echo ">>> Compiling with NVFORTRAN..."

nvfortran \
    -I"$MODDIR" -module "$MODDIR" \
    -I/home/rjrj524/modules/include \
    "${SRC[@]}" \
    -o "$OUTFILE" \
    $(/home/rjrj524/modules/bin/nf-config --flibs)

compile_status=$?

if [ $compile_status -eq 0 ]; then
  echo ">>> Compilation successful. Running $OUTFILE..."   # OUTFILE : Executable file name
  export LD_LIBRARY_PATH=/home/rjrj524/modules/lib:$LD_LIBRARY_PATH
  # base / step(interval)
  base=2000
  step=2000

  for i in 1; do
    arg2=$(echo "$base + ($i - 1) * $step" | bc -l)
    arg1=$(echo "$arg2 * 5.0" | bc -l)
    outfile="dat${i}.dat"
  # u, v_perp, outfilename, timestep, iteration, verbose, m/m_e, inputname
    echo ">>> Running with arguments: $arg2 $arg1 '$outfile' 2.0e-9 5000000 50 1836"
    
    ./"$OUTFILE" $arg2 2.0e4 "$outfile" 2.0e-9 200000 50 1836 '/home/rjrj524/project3/20251121_pwo/nc/wout_QA_nfp2_A6.nc' "0.07477, 3.0775, 6.4114"

  done


else
  echo ">>> Compilation failed. $OUTFILE will not run."

fi