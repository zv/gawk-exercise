# passwd.awk --- access password file information

BEGIN {
    # tailor this to suit your system
    _pw_awklib = "vendor/"
}

function _pw_init(    oldfs, oldrs, olddol0, pwcat, using_fw, using_fpat)
{
    if (_pw_inited)
        return

    oldfs = FS
    oldrs = RS
    olddol0 = $0
    using_fw = (PROCINFO["FS"] == "FIELDWIDTHS")
    using_fpat = (PROCINFO["FS"] == "FPAT")
    FS = ":"
    RS = "\n"

    pwcat = _pw_awklib "pwcat"
    while ((pwcat | getline) > 0) {
        _pw_byname[$1] = $0
        _pw_byuid[$3] = $0
        _pw_bycount[++_pw_total] = $0
    }
    close(pwcat)
    _pw_count = 0
    _pw_inited = 1
    FS = oldfs
    if (using_fw)
        FIELDWIDTHS = FIELDWIDTHS
    else if (using_fpat)
        FPAT = FPAT
    RS = oldrs
    $0 = olddol0
}

# The getpwnam() function takes a username as a string argument. If that user is
# in the database, it returns the appropriate line. Otherwise, it relies on the
# array reference to a nonexistent element to create the element with the null
# string as its value:

 function getpwnam(name)
{
    _pw_init()
    return _pw_byname[name]
}

# Similarly, the getpwuid() function takes a user ID number argument. If that
# user number is in the database, it returns the appropriate line. Otherwise, it
# returns the null string:

 function getpwuid(uid)
{
    _pw_init()
    return _pw_byuid[uid]
}

# The getpwent() function simply steps through the database, one entry at a
# time. It uses _pw_count to track its current position in the _pw_bycount
# array:

 function getpwent()
{
    _pw_init()
    if (_pw_count < _pw_total)
        return _pw_bycount[++_pw_count]
    return ""
}

# The endpwent() function resets _pw_count to zero, so that subsequent calls to
# getpwent() start over again:

 function endpwent()
{
    _pw_count = 0
}
