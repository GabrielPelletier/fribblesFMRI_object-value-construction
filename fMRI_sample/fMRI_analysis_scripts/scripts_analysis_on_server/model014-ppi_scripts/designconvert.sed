# designconvert.sed
# sed script to convert a design.fsf file into MATLAB code to specify
# the design as a structure named fmri
# R Poldrack, 7/1/04

# replace "." with ".c" when they occur within parens
# this is necessary because matlab can't handle struct fields
# whose name is just a number
# 11/30/05 - RP - removed global flag to prevent problems when 
# con_orig is fractional

/(*\.[0-9]*)/{
   /\.[0-9]/s/\./.c/
}

/fmri/s/$/;/

# put chars in single quotes
/fmri.unwarp_dir/s/\([a-zA-Z\-]*\);/'\1';/g

# deal with cases where the Rvalue is a string


# fix file specification separately
/_files/s/set /fmri./

# create as cell arrays
/_files/y/()/{}/
/_files/s/'/='/
/_files/s/ /=/
/_files/s/$/;/

/con_mode/s/;/';/


# Fixing a weird bug where some end line (;) were duplicated (GP) 
/_files/s/;;/;/

/set/s/set fmri(/fmri./g
/fmri/s/) /=/g
/"/s/"/'/g
/#/s/#/%/g

# Chaning 'BBR' to some value (not used anyway) (GP)
/fmri/s/BBR/3/g

/con_mode/s/=/='/