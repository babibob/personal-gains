#exporter.py
""" This script using for export data from vault secret named in path variable it can show just 3 levels deep."""
import os
import json

def get_json_of_secrets(pathtosecret):
    """ This function gets secrets by path and preparing command to insert them"""
    listofsecrets = json.loads(os.popen("vault kv get -format json "+pathtosecret).read())
    stringresult = "vault kv put "+pathtosecret+" "
    for key in listofsecrets['data']['data'].keys():
        value = os.popen("vault kv get -field "+key+" "+pathtosecret).read()
        stringresult = stringresult+key+"='"+value+"' "
    print (stringresult)

""" Start of main part of the script"""
path = "<k8s-clustername>/"
readVaultResult = json.loads(os.popen("vault kv list -format json "+path).read())
jsonVaultResult = readVaultResult
for row in jsonVaultResult:
    """ Getting first level deep, its normal than here is no secrets"""
    newPath = path+row
    readVaultResultsecondRow = json.loads(os.popen("vault kv list -format json "+newPath).read())
    jsonVaultResultsecondRow = readVaultResultsecondRow
    for secondRow in jsonVaultResultsecondRow:
        """ Getting second level deep, script prepared to find here secrets and folders"""
        if secondRow[-1] == "/":
            """ If folder found"""
            readVaultResultThirdRow = json.loads(os.popen("vault kv list -format json "+newPath+secondRow).read())
            jsonVaultResultThirdRow = readVaultResultThirdRow
            for thirdRow in jsonVaultResultThirdRow:
                get_json_of_secrets(newPath + secondRow + thirdRow)
        else:
            """ If this is a secret"""
            get_json_of_secrets(newPath + secondRow)
