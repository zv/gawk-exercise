# Using the FIELDWIDTHS variable (see Constant Size), write a program to read
# election data, where each record represents one voter’s votes. Come up with a
# way to define which columns are associated with each ballot item, and print the
# total votes, including abstentions, for each item.

BEGIN  { FIELDWIDTHS = "18 9 15" }

NR > 2 {
    if ($2 ~ "x") {
        gore++
    } else if ($3 ~ "x") {
        bush++
    } else {
        abstained++
    }
}

END { print "Bush:", bush, "Gore:", gore, "Abstained:", abstained }
