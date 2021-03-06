#!/work/kenneth/test/python/python2.4/bin/python

import pyloadl
import sys

state_list = ['Idle', 'Pending', 'Starting', 'Running', 'Complete_Pending',
              'Reject_Pending', 'Remove_Pending', 'Vacate_Pending',
              'Completed', 'Rejected', 'Removed', 'Vacated', 'Canceled',
              'NotRun', 'Terminated', 'Unexpanded', 'Submission_Err',
              'Hold', 'Deferred', 'NotQueued', 'Preempted',
              'Preempt_Pending', 'Resume_Pending']

step_list = []

query_element = pyloadl.ll_query(pyloadl.JOBS)
rc = pyloadl.ll_set_request(query_element,pyloadl.QUERY_ALL,"",pyloadl.ALL_DATA)
if rc != 0 :
    print "rc (%s)" % rc
    raise Failure
job, job_count, rc = pyloadl.ll_get_objs(query_element,pyloadl.LL_CM,"")
if rc != 0 :
    print "rc (%s)" % rc
    raise Failure

while pyloadl.PyCObjValid(job) :
    credential_element = pyloadl.ll_get_data(job,pyloadl.LL_JobCredential)
    username_string = pyloadl.ll_get_data(credential_element,pyloadl.LL_CredentialUserName)
    #print username_string
    group_string = pyloadl.ll_get_data(credential_element,pyloadl.LL_CredentialGroupName)
    #print group_string
    submittime = pyloadl.ll_get_data(job,pyloadl.LL_JobSubmitTime)
    step_element = pyloadl.ll_get_data(job,pyloadl.LL_JobGetFirstStep)
    while pyloadl.PyCObjValid(step_element) :
        new_step = {}
        new_step['username'] = username_string
        new_step['group'] = group_string
        account = pyloadl.ll_get_data(step_element,pyloadl.LL_StepAccountNumber)
        new_step['account'] = account
        new_step['submittime'] = submittime
        stepstate = pyloadl.ll_get_data(step_element,pyloadl.LL_StepState)
        new_step['state'] = stepstate
        #print "stepstate (%s)" % state_list[stepstate]
        stepid = pyloadl.ll_get_data(step_element,pyloadl.LL_StepID)
        new_step['stepid'] = stepid
        #print stepid
        dispatchtime = pyloadl.ll_get_data(step_element,pyloadl.LL_StepDispatchTime)
        new_step['dispatchtime'] = dispatchtime
        jobclass = pyloadl.ll_get_data(step_element,pyloadl.LL_StepJobClass)
        new_step['class'] = jobclass
        comment = pyloadl.ll_get_data(step_element,pyloadl.LL_StepComment)
        new_step['comment'] = comment
        completioncode = pyloadl.ll_get_data(step_element,pyloadl.LL_StepCompletionCode)
        new_step['completioncode'] = completioncode
        wallclocklimit = pyloadl.ll_get_data(step_element,pyloadl.LL_StepWallClockLimitHard)
        new_step['wallclocklimit'] = wallclocklimit
        completiondate = pyloadl.ll_get_data(step_element,pyloadl.LL_StepCompletionDate)
        new_step['completiondate'] = completiondate
        nodeusage = pyloadl.ll_get_data(step_element,pyloadl.LL_StepNodeUsage)
        new_step['nodeusage'] = nodeusage
        adreq_element = pyloadl.ll_get_data(step_element,pyloadl.LL_StepGetFirstAdapterReq)
        adreq_string = ""
        firstelement = 1
        while pyloadl.PyCObjValid(adreq_element) :
            if firstelement == 0 :
                adreq_string = adreq_string + "+"
            adreqtypename = pyloadl.ll_get_data(adreq_element,pyloadl.LL_AdapterReqTypeName)
            adreq_string = adreq_string + adreqtypename
            adreq_string = adreq_string + '#cat_sep#'
            adreqinstances = pyloadl.ll_get_data(adreq_element,pyloadl.LL_AdapterReqInstances)
            adreq_string = adreq_string + "%s" % adreqinstances
            adreq_string = adreq_string + '#cat_sep#'
            adreqprotocol = pyloadl.ll_get_data(adreq_element,pyloadl.LL_AdapterReqProtocol)
            adreq_string = adreq_string + adreqprotocol
            adreq_string = adreq_string + '#cat_sep#'
            adreqmode = pyloadl.ll_get_data(adreq_element,pyloadl.LL_AdapterReqMode)
            adreq_string = adreq_string + adreqmode
            #adreq_string = adreq_string + '#cat_sep#'
            adreq_element = pyloadl.ll_get_data(step_element,pyloadl.LL_StepGetNextAdapterReq)
            firstelement = 0
        new_step['adreq_string'] = adreq_string
        if stepstate in [pyloadl.STATE_RUNNING,
                         pyloadl.STATE_STARTING,
                         pyloadl.STATE_PREEMPTED,
                         pyloadl.STATE_PREEMPT_PENDING,
                         pyloadl.STATE_RESUME_PENDING,
                         pyloadl.STATE_REMOVE_PENDING,] :
            # get machine map
            machine_element = pyloadl.ll_get_data(step_element,pyloadl.LL_StepGetFirstMachine)
            machinename_string = ""
            firstelement = 1
            while pyloadl.PyCObjValid(machine_element) :
                machinename = pyloadl.ll_get_data(machine_element,pyloadl.LL_MachineName)
                if firstelement == 0 :
                    machinename_string = machinename_string + "+"
                else :
                    new_step['first_machine_name'] = machinename
                machinename_string = machinename_string + machinename
                machine_element = pyloadl.ll_get_data(step_element,pyloadl.LL_StepGetNextMachine)
                firstelement = 0
            new_step['machinename_string'] = machinename_string
        node_element = pyloadl.ll_get_data(step_element,pyloadl.LL_StepGetFirstNode)
        while pyloadl.PyCObjValid(node_element) :
            task_element = pyloadl.ll_get_data(node_element,pyloadl.LL_NodeGetFirstTask)
            # ignore Master Task
            task_element = pyloadl.ll_get_data(node_element,pyloadl.LL_NodeGetNextTask)
            nodemininstances = pyloadl.ll_get_data(node_element,pyloadl.LL_NodeMinInstances)
            #print "nodemininstances (%s)" % nodemininstances
            machinemap_string = ""
            requirementsmap_string = ""
            firstelement = 1
            for counter in range(nodemininstances) :
                if firstelement == 0 :
                    machinemap_string = machinemap_string + "+"
                    requirementsmap_string = requirementsmap_string + "+"
                nodeinitiators = pyloadl.ll_get_data(node_element,pyloadl.LL_NodeInitiatorCount)
                #print "nodeinitiators (%s)" % nodeinitiators
                machinemap_string = machinemap_string + "%s" % nodeinitiators
                noderequirements = pyloadl.ll_get_data(node_element,pyloadl.LL_NodeRequirements)
                requirementsmap_string = requirementsmap_string + "%s" % noderequirements
                #print "noderequirements (%s)" % noderequirements
                firstelement = 0
            new_step['machinemap_string'] = machinemap_string
            new_step['requirementsmap_string'] = requirementsmap_string
            resourcesreq_string = ""
            initiatormap_string = ""
            taskinstancemachinemap_string = ""
            taskinstanceadapterwindowmap_string = ""
            firstelement = 1
            while pyloadl.PyCObjValid(task_element) :
                #print "valid task_element"
                resourcereq_element = pyloadl.ll_get_data(task_element,pyloadl.LL_TaskGetFirstResourceRequirement)
                firstreqelement = 1
                while pyloadl.PyCObjValid(resourcereq_element) :
                    if firstreqelement == 0 :
                        resourcesreq_string = resourcesreq_string + "+"
                    #print "valid resourcereq_element"
                    resourcereqname = pyloadl.ll_get_data(resourcereq_element,pyloadl.LL_ResourceRequirementName)
                    #print "resourcereqname (%s)" % resourcereqname
                    resourcereqvalue64 = pyloadl.ll_get_data(resourcereq_element,pyloadl.LL_ResourceRequirementValue64)
                    resourcesreq_string = resourcesreq_string + "%s" % resourcereqname + '#cat_sep#' + "%s" % resourcereqvalue64
                    #print "resourcereqvalue64 (%s)" % resourcereqvalue64
                    resourcereq_element = pyloadl.ll_get_data(node_element,pyloadl.LL_TaskGetNextResourceRequirement)
                    firstreqelement = 0
                # need to discard first task instance?
                # task_element = pyloadl.ll_get_data(node_element,pyloadl.LL_NodeGetNextTask)
                if firstelement == 0 :
                    initiatormap_string = initiatormap_string + "+"
                taskinstancecount = pyloadl.ll_get_data(task_element,pyloadl.LL_TaskInstanceCount)
                #print "taskintancecount (%s)" % taskinstancecount
                initiatormap_string = initiatormap_string + "%s" % taskinstancecount
            #new_step['taskinstancecount'] = taskinstancecount
                taskinstanceadapterwindowmap_string = ""
                taskinstance_element = pyloadl.ll_get_data(task_element,pyloadl.LL_TaskGetFirstTaskInstance)
                firsttaskinstanceelement = 1
                while pyloadl.PyCObjValid(taskinstance_element) :
                    if firsttaskinstanceelement == 0 :
                        taskinstancemachinemap_string = taskinstancemachinemap_string + "+"
                        taskinstanceadapterwindowmap_string = taskinstanceadapterwindowmap_string + "+"
                    #else :
                    #    taskinstanceadapterwindowmap_string = taskinstanceadapterwindowmap_string + "%s-" % taskinstancemachinename
                    taskinstancemachinename = pyloadl.ll_get_data(taskinstance_element,pyloadl.LL_TaskInstanceMachineName)
                    #print "taskintancemachinename (%s)" % taskinstancemachinename
                    taskinstancemachinemap_string = taskinstancemachinemap_string + taskinstancemachinename
                    taskadapterusage_element = pyloadl.ll_get_data(taskinstance_element,pyloadl.LL_TaskInstanceGetFirstAdapterUsage)
                    firstadapterusage = 1
                    while pyloadl.PyCObjValid(taskadapterusage_element) :
                        if firstadapterusage == 0 :
                            taskinstanceadapterwindowmap_string = taskinstanceadapterwindowmap_string + ","
                        else :
                            taskinstanceadapterwindowmap_string = taskinstanceadapterwindowmap_string + "%s-" % taskinstancemachinename
                        adapterusagetag = pyloadl.ll_get_data(taskadapterusage_element,pyloadl.LL_AdapterUsageTag)
                        #print "adapterusagetag (%s)" % adapterusagetag
                        adapterusagewindow = pyloadl.ll_get_data(taskadapterusage_element,pyloadl.LL_AdapterUsageWindow)
                        #print "adapterusagewindow (%s)" % adapterusagewindow
                        taskinstanceadapterwindowmap_string = taskinstanceadapterwindowmap_string + "%s@%s" % (adapterusagetag,adapterusagewindow)
                        taskadapterusage_element = pyloadl.ll_get_data(taskinstance_element,pyloadl.LL_TaskInstanceGetNextAdapterUsage)
                        firstadapterusage = 0
                    taskinstance_element = pyloadl.ll_get_data(task_element,pyloadl.LL_TaskGetNextTaskInstance)
                    firsttaskinstanceelement = 0
                task_element = pyloadl.ll_get_data(node_element,pyloadl.LL_NodeGetNextTask)
                firstelement = 0
            new_step['resourcesreq_string'] = resourcesreq_string
            new_step['initiatormap_string'] = initiatormap_string
            new_step['taskinstancemachinemap_string'] = taskinstancemachinemap_string
            new_step['taskinstanceadapterwindowmap_string'] = taskinstanceadapterwindowmap_string
            node_element = pyloadl.ll_get_data(step_element,pyloadl.LL_StepGetNextNode)
        step_element = pyloadl.ll_get_data(job,pyloadl.LL_JobGetNextStep)
    job = pyloadl.ll_next_obj(query_element)
    #print new_step
    step_list.append(new_step)

# iterate through all jobs to get elapsed wallclock time from the startd
#print "getting wallclockused"
for jobindex in range(len(step_list)) :
    if step_list[jobindex]['state'] in [pyloadl.STATE_RUNNING,
                     pyloadl.STATE_STARTING,
                     pyloadl.STATE_PREEMPTED,
                     pyloadl.STATE_PREEMPT_PENDING,
                     pyloadl.STATE_RESUME_PENDING,
                     pyloadl.STATE_REMOVE_PENDING,] :
        query_element = pyloadl.ll_query(pyloadl.JOBS)
        rc = pyloadl.ll_set_request(query_element,pyloadl.QUERY_STEPID,(step_list[jobindex]['stepid'],""),pyloadl.ALL_DATA)
        if rc != 0 :
            print "ll_set_request failed for (%s)" % step_list[jobindex]['stepid']
        else :
            pass
            #print "ll_set_request succeeded for (%s)" % step_list[jobindex]['stepid']
        #print "first_machine_name (%s)" % step_list[jobindex]['first_machine_name']
        wall_obj_element, obj_count, rc = pyloadl.ll_get_objs(query_element,pyloadl.LL_STARTD,step_list[jobindex]['first_machine_name'])
        if wall_obj_element == None :
        #    print "wall_obj_element == None"
            # assume the job is completing
            step_list[jobindex]['state'] = pyloadl.STATE_REMOVED
            step_list[jobindex]['wallclockused'] = step_list[jobindex]['wallclocklimit']
        else :
            #print "wall_obj_element != None"
            wallstep_element = pyloadl.ll_get_data(wall_obj_element,pyloadl.LL_JobGetFirstStep)
            #print "got wallstep_element"
            wallclockused = None
            while pyloadl.PyCObjValid(wallstep_element) :
                wallstep_name = pyloadl.ll_get_data(wallstep_element,pyloadl.LL_StepID)
                #print "got wallstep_name"
                #if wallstep_name == None :
                    #print "wallstep_name == None!"
                #print "wallstep_name (%s)" % wallstep_name
                if wallstep_name == step_list[jobindex]['stepid'] :
                    wallclockused = pyloadl.ll_get_data(wallstep_element,pyloadl.LL_StepWallClockUsed)
                    step_list[jobindex]['wall_clock_used'] = wallclockused
                    break
                else :
                    wallstep_element = pyloadl.ll_get_data(wall_obj_element,pyloadl.LL_JobGetNextStep)
            if wallclockused == None :
                # failed to get wallclockused
                print "Failed to get wallclockused for (%s)!" % step_list[jobindex]['stepid']
                sys.exit(1)
    else :
        step_list[jobindex]['wall_clock_used'] = 0
                
#print "printint job info"
#for jobstep in step_list :
    #for key in jobstep.keys() :
    #    print "key: %s" % key,
    #    print "value: %s" % jobstep[key],
# print out job line
for jobstep in step_list :
#    print "user:%s#cat_delim#" % jobstep['username'],
#    print "group:%s#cat_delim#" % jobstep['group'],
#    print "account:%s#cat_delim#" % jobstep['account'],
#    print "state:%s#cat_delim#" % state_list[jobstep['state']],
#    print "wall_clock_limit:%s#cat_delim#" % jobstep['wallclocklimit'],
#    print "wall_clock_used:%s#cat_delim#" % jobstep['wall_clock_used'],
#    print "stepid:%s#cat_delim#" % jobstep['stepid'],
#    print "class:%s#cat_delim#" % jobstep['class'],
#    print "node_usage:%s#cat_delim#" % jobstep['nodeusage'],
#    print "taskinstancemachinemap:%s#cat_delim#" % jobstep['taskinstancemachinemap_string'],
#    print "taskinstanceadapterwindowmap:%s#cat_delim#" % jobstep['taskinstanceadapterwindowmap_string'],
#    print "dispatchtime:%s#cat_delim#" % jobstep['dispatchtime'],
#    print "completiontime:%s#cat_delim#" % jobstep['completiondate'],
#    print "completioncode:%s#cat_delim#" % jobstep['initiatormap_string'],
#    print "requirementsmap:%s#cat_delim#" % jobstep['requirementsmap_string'],
#    print "comment:%s#cat_delim#" % jobstep['comment'],
#    print "machinemap:%s#cat_delim#" % jobstep['machinemap_string'],
#    print "adreqmap:%s#cat_delim#" % jobstep['adreq_string'],
#    print "adreqmap:%s#cat_delim#" % jobstep['adreq_string'],
    sys.stdout.write("user:%s#cat_delim#" % jobstep['username'],)
    sys.stdout.write("group:%s#cat_delim#" % jobstep['group'],)
    sys.stdout.write("account:%s#cat_delim#" % jobstep['account'],)
    sys.stdout.write("state:%s#cat_delim#" % state_list[jobstep['state']],)
    sys.stdout.write("wall_clock_limit:%s#cat_delim#" % jobstep['wallclocklimit'],)
    sys.stdout.write("wall_clock_used:%s#cat_delim#" % jobstep['wall_clock_used'],)
    sys.stdout.write("stepid:%s#cat_delim#" % jobstep['stepid'],)
    sys.stdout.write("class:%s#cat_delim#" % jobstep['class'],)
    sys.stdout.write("node_usage:%s#cat_delim#" % jobstep['nodeusage'],)
    sys.stdout.write("taskinstancemachinemap:%s#cat_delim#" % jobstep['taskinstancemachinemap_string'],)
    sys.stdout.write("taskinstanceadapterwindowmap:%s#cat_delim#" % jobstep['taskinstanceadapterwindowmap_string'],)
    sys.stdout.write("dispatchtime:%s#cat_delim#" % jobstep['dispatchtime'],)
    sys.stdout.write("submittime:%s#cat_delim#" % jobstep['submittime'],)
    sys.stdout.write("completiontime:%s#cat_delim#" % jobstep['completiondate'],)
    sys.stdout.write("initiatormap:%s#cat_delim#" % jobstep['initiatormap_string'],)
    sys.stdout.write("resourcesreq:%s#cat_delim#" % jobstep['resourcesreq_string'],)
    sys.stdout.write("requirementsmap:%s#cat_delim#" % jobstep['requirementsmap_string'],)
    sys.stdout.write("comment:%s#cat_delim#" % jobstep['comment'],)
    sys.stdout.write("machinemap:%s#cat_delim#" % jobstep['taskinstancemachinemap_string'],)
    sys.stdout.write("adreqmap:%s#cat_delim#" % jobstep['adreq_string'],)
    print ""
print "qj FINISHED"

