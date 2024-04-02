#cleaner.py
""" This script using for clear entity list in vault."""
import os
import json
import time

""" Getting list of entities"""
jsonList = json.loads(os.popen("vault list -format json identity/entity/id").read())
currentTime = time.time()
for key in jsonList:
    entityMetadata = json.loads(os.popen('vault read -format json identity/entity/id/'+key).read())['data']
    modificationTimeClear = time.strptime(entityMetadata['last_update_time'][:-4], "%Y-%m-%dT%X.%f")
    ageOfEntity = int(format((currentTime - time.mktime(modificationTimeClear))/3600/24, '.0f'))
    if ageOfEntity > 14 and entityMetadata['aliases'][0]['mount_path'] == 'auth/<vault-name>/':
        """ When you want to really delete entities - uncomment next line. """
        print("I am ready for deleting this entity - "+key)
        #os.popen("vault delete identity/entity/id/"+key)
