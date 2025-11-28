#!/bin/bash

MODDIR=build
OUTFILE=main.exe

mkdir -p "$MODDIR"

# ===== 최적화 옵션 =====
OPTFLAGS="-O3 -Minfo=all"
# 혹은 정확도 좀 더 챙기고 싶으면
# OPTFLAGS="-O2 -mp -Minfo=opt"

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

  # 출력 폴더
  OUTDIR="a"
  mkdir -p "$OUTDIR"

  CSV_FILE="a.csv"

  # CSV 읽기: 헤더 1줄 건너뛰고, 각 열을 변수로 받기
  # v_perp, v_para, output, dt, steps, compress, mass, nc, x1, x2, x3
  tail -n +2 "$CSV_FILE" | while IFS=',' read -r v_perp v_para output dt steps compress mass nc x1 x2 x3
  do
    # 공백 제거 (혹시 모를 스페이스 방지용)
    v_perp=$(echo "$v_perp" | xargs)
    v_para=$(echo "$v_para" | xargs)
    output=$(echo "$output" | xargs)
    dt=$(echo "$dt" | xargs)
    steps=$(echo "$steps" | xargs)
    compress=$(echo "$compress" | xargs)
    mass=$(echo "$mass" | xargs)
    nc_path=$(echo "$nc" | xargs)
    x1=$(echo "$x1" | xargs)
    x2=$(echo "$x2" | xargs)
    x3=$(echo "$x3" | xargs)

    # 실제 출력 파일 경로: a/dat1.dat, a/dat2.dat ...
    outfile="$OUTDIR/$output"

    # 마지막 인자는 "x1, x2, x3" 형태의 문자열
    xvec="${x1}, ${x2}, ${x3}"

    echo ">>> Running: u=$v_para, v_perp=$v_perp, out=$outfile, dt=$dt, steps=$steps"

    ./"$OUTFILE" \
      "$v_para" "$v_perp" "$outfile" "$dt" "$steps" "$compress" "$mass" \
      "$nc_path" "$xvec"

  done

else
  echo ">>> Compilation failed. $OUTFILE will not run."
fi
