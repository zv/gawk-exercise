# getopt.awk --- Do C library getopt(3) function in awk

# External variables:
#    Optind -- index in ARGV of first nonoption argument
#    Optarg -- string value of argument to current option
#    Opterr -- if nonzero, print our own diagnostic
#    Optopt -- current option letter

# Returns:
#    -1     at end of options
#    "?"    for unrecognized option
#    <c>    a character representing the current option

# Private Data:
#    _opti  -- index in multiflag option, e.g., -abc

# The function starts out with comments presenting a list of the global
# variables it uses, what the return values are, what they mean, and any global
# variables that are “private” to this library function. Such documentation is
# essential for any program, and particularly for library functions.

# The getopt() function first checks that it was indeed called with a string of
# options (the options parameter). If options has a zero length, getopt()
# immediately returns -1:

 function getopt(argc, argv, options,    thisopt, i)
 {
     if (length(options) == 0)    # no options given
         return -1

     if (argv[Optind] == "--") {  # all done
         Optind++
         _opti = 0
         return -1
     } else if (argv[Optind] !~ /^-[^:[:space:]]/) {
         _opti = 0
         return -1
     }

     # The next thing to check for is the end of the options. A -- ends the
     # command-line options, as does any command-line argument that does not begin
     # with a ‘-’. Optind is used to step through the array of command-line
     # arguments; it retains its value across calls to getopt(), because it is a
     # global variable.

     # The regular expression that is used, /^-[^:[:space:]/, checks for a ‘-’
     # followed by anything that is not whitespace and not a colon. If the current
     # command-line argument does not match this pattern, it is not an option, and it
     # ends option processing. Continuing on:

     if (_opti == 0)
         _opti = 2
     thisopt = substr(argv[Optind], _opti, 1)
     Optopt = thisopt
     i = index(options, thisopt)
     if (i == 0) {
         if (Opterr)
             printf("%c -- invalid option\n", thisopt) > "/dev/stderr"
         if (_opti >= length(argv[Optind])) {
             Optind++
             _opti = 0
         } else
             _opti++
         return "?"
     }

# The _opti variable tracks the position in the current command-line argument
# (argv[Optind]). If multiple options are grouped together with one ‘-’ (e.g.,
# -abx), it is necessary to return them to the user one at a time.

# If _opti is equal to zero, it is set to two, which is the index in the string
# of the next character to look at (we skip the ‘-’, which is at position one).
# The variable thisopt holds the character, obtained with substr(). It is saved
# in Optopt for the main program to use.

# If thisopt is not in the options string, then it is an invalid option. If
# Opterr is nonzero, getopt() prints an error message on the standard error that
# is similar to the message from the C version of getopt().

# Because the option is invalid, it is necessary to skip it and move on to the
# next option character. If _opti is greater than or equal to the length of the
# current command-line argument, it is necessary to move on to the next
# argument, so Optind is incremented and _opti is reset to zero. Otherwise,
# Optind is left alone and _opti is merely incremented.

# In any case, because the option is invalid, getopt() returns "?". The main
# program can examine Optopt if it needs to know what the invalid option letter
# actually is. Continuing on:

     if (substr(options, i + 1, 1) == ":") {
         # get option argument
         if (length(substr(argv[Optind], _opti + 1)) > 0)
             Optarg = substr(argv[Optind], _opti + 1)
         else
             Optarg = argv[++Optind]
         _opti = 0
     } else
         Optarg = ""

# If the option requires an argument, the option letter is followed by a colon
# in the options string. If there are remaining characters in the current
# command-line argument (argv[Optind]), then the rest of that string is assigned
# to Optarg. Otherwise, the next command-line argument is used (‘-xFOO’ versus
# ‘-x FOO’). In either case, _opti is reset to zero, because there are no more
# characters left to examine in the current command-line argument. Continuing:

     if (_opti == 0 || _opti >= length(argv[Optind])) {
         Optind++
         _opti = 0
     } else
         _opti++
     return thisopt
 }
# Finally, if _opti is either zero or greater than the length of the current
# command-line argument, it means this element in argv is through being
# processed, so Optind is incremented to point to the next element in argv. If
# neither condition is true, then only _opti is incremented, so that the next
# option letter can be processed on the next call to getopt().

# The BEGIN rule initializes both Opterr and Optind to one. Opterr is set to
# one, because the default behavior is for getopt() to print a diagnostic
# message upon seeing an invalid option. Optind is set to one, because there’s
# no reason to look at the program name, which is in ARGV[0]:

 BEGIN {
     Opterr = 1    # default is to diagnose
     Optind = 1    # skip ARGV[0]

     # test program
     if (_getopt_test) {
         while ((_go_c = getopt(ARGC, ARGV, "ab:cd")) != -1)
             printf("c = <%c>, Optarg = <%s>\n",
                    _go_c, Optarg)
         printf("non-option arguments:\n")
         for (; Optind < ARGC; Optind++)
             printf("\tARGV[%d] = <%s>\n",
                    Optind, ARGV[Optind])
     }
 }
