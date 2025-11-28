#!/bin/bash

MODDIR=build
OUTFILE=main.exe

mkdir -p "$MODDIR"

# ===== 최적화 옵션 =====
# 안전 + 빠른 편
OPTFLAGS="-O3 -Minfo=all"
# 혹은: OPTFLAGS="-O2 -mp -Minfo=opt"

# ===== 소스 파일 목록 =====
SRC=(
  set_values.cuf
  modules/trig_compute.cuf
  modules/spline2.cuf
  modules/fourier3.cuf
  reader/nc_reader.cuf
  rk4_revised4.cuf
)

echo ">>> Compiling with NVFORTRAN..."

nvfortran \
    $OPTFLAGS \
    -I"$MODDIR" -module "$MODDIR" \
    -I/home/rjrj524/modules/include \
    "${SRC[@]}" \
    -o "$OUTFILE" \
    $(/home/rjrj524/modules/bin/nf-config --flibs)

compile_status=$?

if [ $compile_status -eq 0 ]; then
  echo ">>> Compilation successful. Running $OUTFILE..."
  export LD_LIBRARY_PATH=/home/rjrj524/modules/lib:$LD_LIBRARY_PATH

  base=2000
  step=2000

  for i in 1; do
    arg2=$(echo "$base + ($i - 1) * $step" | bc -l)
    arg1=$(echo "$arg2 * 5.0" | bc -l)
    outfile="dat${i}.dat"

    echo ">>> Running with arguments: $arg2 $arg1 '$outfile' 2.0e-9 5000000 500 1836"

    ./"$OUTFILE" \
      $arg2 2.0e4 "$outfile" 1.0e-9 5000000 500 1836 \
      '/home/rjrj524/project3/20251121_pwo/nc/wout_QA_nfp2_A6.nc' \
      "0.07477, 3.0775, 6.4114"
  done
else
  echo ">>> Compilation failed. $OUTFILE will not run."
fi
