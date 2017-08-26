# Rewrite the program:
# awk 'BEGIN { print "Month Crates"
#     print "----- ------" }
#     { print $1, "     ", $2 }' inventory-shipped
# from Output Separators, by using a new value of OFS.

awk ''
