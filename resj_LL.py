#!/work/kenneth/test/python/python2.4/bin/python

import pyloadl
import sys

job = sys.argv[1]
action = sys.argv[2]

rc, err_obj = pyloadl.ll_preempt(job,pyloadl.RESUME_STEP)
print "rc from ll_preempt RESUME_STEP is >%d<" % (rc,)
