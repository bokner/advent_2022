{ awk '{printf "var float: "; 
    gsub(":"," = ", $1); printf; print ";"}' $1; \
    echo "output[show(floor(fix(root)))];";} | minizinc --solver coin-bc -