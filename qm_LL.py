#!/work/kenneth/test/python/python2.4/bin/python

import pyloadl
import sys
import string

machine_list = []

def get_list_string(item_list) :
    list_string = ""
    first_item = 1
    for item in item_list :
        if first_item != 1 :
            list_string = list_string + '+'
        list_string = list_string + "%s" % (item,)
        first_item = 0
    return list_string
    
query_element = pyloadl.ll_query(pyloadl.MACHINES)
rc = pyloadl.ll_set_request(query_element,pyloadl.QUERY_ALL,"",pyloadl.ALL_DATA)
if rc != 0 :
    print "rc (%s)" % rc
    raise Failure
machine_ptr, machine_count, rc = pyloadl.ll_get_objs(query_element,pyloadl.LL_CM,"")
if rc != 0 :
    print "rc (%s)" % rc
    raise Failure

while pyloadl.PyCObjValid(machine_ptr) :
    sys.stdout.write("#cat_delim#")
    sys.stdout.write("Machine:%s#cat_delim#" % pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineName))
    sys.stdout.write("Arch:%s#cat_delim#" % pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineArchitecture))
    sys.stdout.write("OpSys:%s#cat_delim#" % (pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineOperatingSystem),))
    sys.stdout.write("Disk:%s#cat_delim#" % pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineDisk))
    #PoolListSize = pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachinePoolList)
    item_list = pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachinePoolList)
    #pool_string = ""
    #first_pool = 1
    #for poolnumber in pool_list :
    #    if first_pool != 1 :
    #        pool_string = pool_string + '+'
    #    pool_string = pool_string + "%s" % (poolnumber,)
    #    first_pool = 0
    #sys.stdout.write("Pool:%s#cat_delim#" % (pool_string,))
    sys.stdout.write("Pool:%s#cat_delim#" % (get_list_string(item_list),))
    item_list = pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineConfiguredClassList)
    #pool_string = ""
    #first_pool = 1
    #for poolnumber in pool_list :
    #    if first_pool != 1 :
    #        pool_string = pool_string + '+'
    #    pool_string = pool_string + "%s" % (poolnumber,)
    #    first_pool = 0
    sys.stdout.write("ConfiguredClasses:%s#cat_delim#" % (get_list_string(item_list),))
    item_list = pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineAvailableClassList)
    #pool_string = ""
    #first_pool = 1
    #for poolnumber in pool_list :
    #    if first_pool != 1 :
    #        pool_string = pool_string + '+'
    #    pool_string = pool_string + "%s" % (poolnumber,)
    #    first_pool = 0
    sys.stdout.write("AvailableClasses:%s#cat_delim#" % (get_list_string(item_list),))
    item_list = pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineFeatureList)
    #pool_string = ""
    #first_pool = 1
    #for poolnumber in pool_list :
    #    if first_pool != 1 :
    #        pool_string = pool_string + '+'
    #    pool_string = pool_string + "%s" % (poolnumber,)
    #    first_pool = 0
    sys.stdout.write("Feature:%s#cat_delim#" % (get_list_string(item_list),))
    sys.stdout.write("Max_Starters:%s#cat_delim#" % (pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineMaxTasks),))
    sys.stdout.write("Memory:%s#cat_delim#" % (pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineRealMemory),))
    sys.stdout.write("Cpus:%s#cat_delim#" % (pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineCPUs),))
    resource_ptr = pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineGetFirstResource)
    sys.stdout.write("resourcesmap:")
    first_element = 1
    while pyloadl.PyCObjValid(resource_ptr) :
        if first_element == 0 :
            sys.stdout.write("+")
        sys.stdout.write("%s#cat_sep#" % (pyloadl.ll_get_data(resource_ptr,pyloadl.LL_ResourceName),))
        sys.stdout.write("%s#cat_sep#" % (pyloadl.ll_get_data(resource_ptr,pyloadl.LL_ResourceInitialValue),))
        sys.stdout.write("%s" % (pyloadl.ll_get_data(resource_ptr,pyloadl.LL_ResourceAvailableValue),))
        resource_ptr = pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineGetNextResource)
        first_element = 0
    sys.stdout.write("#cat_delim#")
    sys.stdout.write("State:%s#cat_delim#" % (pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineStartdState),))
    adapter_ptr = pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineGetFirstAdapter)
    adapter_index = 0
    first_element = 1
    while pyloadl.PyCObjValid(adapter_ptr) :
        if first_element == 0 :
        #    sys.stdout.write("+")
            sys.stdout.write("#cat_delim#")
        adapter_index = adapter_index + 1
        sys.stdout.write("AdapterName%s:%s;" % (adapter_index,pyloadl.ll_get_data(adapter_ptr,pyloadl.LL_AdapterName),))
        sys.stdout.write("AdapterTotalWindowCount:%s;" % (pyloadl.ll_get_data(adapter_ptr,pyloadl.LL_AdapterTotalWindowCount),))
        sys.stdout.write("AdapterAvailWindowCount:%s" % (pyloadl.ll_get_data(adapter_ptr,pyloadl.LL_AdapterAvailWindowCount),))
        # Trying to get this info results in 
#ds001:/work/kenneth/test/catalina/pyloadl)./qm_LL.py
#cat_delim#Machine:ds395#cat_delim#Arch:R6000#cat_delim#OpSys:AIX52#cat_delim#Disk:195576#cat_delim#Pool:1#cat_delim#ConfiguredClasses:Diag+Diag+Diag+Diag+Diag+Diag+Diag+Diag+special+special+special+special+special+special+special+special+special+special+special+special+special+special+special+special+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+high+high+high+high+high+high+high+high+high+high+high+high+high+high+high+high#cat_delim#AvailableClasses:Diag+Diag+Diag+Diag+Diag+Diag+Diag+Diag+special+special+special+special+special+special+special+special+special+special+special+special+special+special+special+special+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+normal+high+high+high+high+high+high+high+high+high+high+high+high+high+high+high+high#cat_delim#Feature:batch+high+Power4+CPUs8+MEM32+GPFS-WAN#cat_delim#Max_Starters:16#cat_delim#Memory:30464#cat_delim#Cpus:8#cat_delim#resourcesmap:ConsumableMemory#cat_sep#24576#cat_sep#24576+ConsumableCpus#cat_sep#8#cat_sep#8+RDMA#cat_sep#4#cat_sep#4#cat_delim#State:Idle#cat_delim#AdapterName1:networks;AdapterTotalWindowCount:16;AdapterAvailWindowCount:16IOT/Abort trap(coredump)
#ds001:/work/kenneth/test/catalina/pyloadl)
        #sys.stdout.write("AdapterCommInterface:%s" % (pyloadl.ll_get_data(adapter_ptr,pyloadl.LL_AdapterCommInterface),))
        adapter_ptr = pyloadl.ll_get_data(machine_ptr,pyloadl.LL_MachineGetNextAdapter)
        first_element = 0
    print ""
    machine_ptr = pyloadl.ll_next_obj(query_element)

print "qm FINISHED"
