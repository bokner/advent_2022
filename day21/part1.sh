{ awk '{printf "var float: "; 
    gsub(":"," = ", $1); printf; print ";"}' $1; \
    echo "output[show(floor(fix(root)))];";} > part1_model.mzn
minizinc part1_model.mzn --solver coin-bc