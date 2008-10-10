#!/work/kenneth/test/python/python2.4/bin/python
# runjob <fromhost> <cluster> <proc> <abbreviated form>
# runjob tf225i.sdsc.edu 84 0 tf226i#8 tf227i#8

import pyloadl
import sys
import string

fromhost = sys.argv[1]
cluster = sys.argv[2]
proc = sys.argv[3]
nodencount_list = sys.argv[4:]

node_list = []
for nodencount in nodencount_list :
    nodename, count = string.split(nodencount,'#')
    for index in range(string.atoi(count)) :
        node_list.append(nodename)

#rc = pyloadl.ll_start_job(fromhost + '.' + cluster + '.' + proc, node_list)
#print "rc from ll_start_job is >%s<" % rc

print "(%s) (%s)" % (fromhost + '.' + cluster + '.' + proc, node_list)
