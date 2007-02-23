# Restrict nodes to those with ConfiguredClasses normal  and Max_Starters > 0
# If node does not have normal class or has Max_Starters == 0, reject

resource = input_tuple[0]

if resource['State'] == 'Down' :
    result = 'Down'
elif resource['State'] == 'Drain' :
    result = 'Drain'
elif resource['State'] == 'Drained' :
    result = 'Drained'
elif resource['State'] == 'None' :
    result = 'None'
elif resource['State'] == None :
    result = None
elif resource['State'] == 'Unknown' :
    result = 'Unknown'
elif resource['Max_Starters'] == 0 :
    result = 'Max_Starters=0'
elif not DEFAULT_JOB_CLASS in resource['ConfiguredClasses_list'] :
    result = 'noNormal'
else :
    result = 0
