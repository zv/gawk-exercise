# group.awk --- functions for dealing with the group file

BEGIN {
    # Change to suit your system
    _gr_awklib = "vendor/"
}

function _gr_init(oldfs, oldrs, olddol0, grcat,
                  using_fw, using_fpat, n, a, i)
{
    if (_gr_inited)
        return

    oldfs = FS
    oldrs = RS
    olddol0 = $0
    using_fw = (PROCINFO["FS"] == "FIELDWIDTHS")
    using_fpat = (PROCINFO["FS"] == "FPAT")
    FS = ":"
    RS = "\n"

    grcat = _gr_awklib "grcat"
    while ((grcat | getline) > 0) {
        if ($1 in _gr_byname)
            _gr_byname[$1] = _gr_byname[$1] "," $4
        else
            _gr_byname[$1] = $0
        if ($3 in _gr_bygid)
            _gr_bygid[$3] = _gr_bygid[$3] "," $4
        else
            _gr_bygid[$3] = $0

        n = split($4, a, "[ \t]*,[ \t]*")
        for (i = 1; i <= n; i++)
            if (a[i] in _gr_groupsbyuser)
                _gr_groupsbyuser[a[i]] = _gr_groupsbyuser[a[i]] " " $1
            else
                _gr_groupsbyuser[a[i]] = $1

        _gr_bycount[++_gr_count] = $0
    }
    close(grcat)
    _gr_count = 0
    _gr_inited++
    FS = oldfs
    if (using_fw)
        FIELDWIDTHS = FIELDWIDTHS
    else if (using_fpat)
        FPAT = FPAT
    RS = oldrs
    $0 = olddol0
}

# The getgrnam() function takes a group name as its argument, and if that group
# exists, it is returned. Otherwise, it relies on the array reference to a
# nonexistent element to create the element with the null string as its value:

 function getgrnam(group)
{
    _gr_init()
    return _gr_byname[group]
}

# The getgrgid() function is similar; it takes a numeric group ID and looks up
# the information associated with that group ID:

 function getgrgid(gid)
{
    _gr_init()
    return _gr_bygid[gid]
}

# The getgruser() function does not have a C counterpart. It takes a username
# and returns the list of groups that have the user as a member:

 function getgruser(user)
{
    _gr_init()
    return _gr_groupsbyuser[user]
}

# The getgrent() function steps through the database one entry at a time. It
# uses _gr_count to track its position in the list:

 function getgrent()
{
    _gr_init()
    if (++_gr_count in _gr_bycount)
        return _gr_bycount[_gr_count]
    return ""
}

# The endgrent() function resets _gr_count to zero so that getgrent() can start
# over again:

 function endgrent()
{
    _gr_count = 0
}
