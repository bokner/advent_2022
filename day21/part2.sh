{ awk '{
    if ($1 == "root:")
        print "constraint ", $2, "=", $4, ";";
    else {
        printf "var float: "; 
        if ($1 == "humn:") 
            print "humn;";
        else {
                gsub(":"," = ", $1); 
                printf; 
                print ";"
            }
        }
    }' $1; \
    echo "output[show(floor(fix(humn)))];";} > part2_model.mzn
minizinc part2_model.mzn --solver coin-bc