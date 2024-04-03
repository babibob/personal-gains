import socket
import re
import os
import shutil
from pathlib import Path

def group_validator():
    print('Start checking groups')
    checkResult = "Ok"
    groupList=os.popen("ls groups/*").read()
    groupFile=groupList.split('\n')
    for file in groupFile:
        if file != '':
            hosts = os.popen('cat '+file).read()
            splitedHosts = hosts.split('\n')
            for host in splitedHosts:
                if host != '':
                    indicatingResult, type = network_string_indicator(host)
                    if type != "error":
                        print(indicatingResult,host, type)
                    else:
                        print("error\nstring couldn't be parsed "+indicatingResult)
                        checkResult = "error"
    return checkResult

def user_validator():
    print("Start checking users")
    checkResult = "Ok"
    userFile = Path("list").read_text()
    aggrFile = Path("groupsAggregation").read_text()
    groupsFolder = os.popen("ls groups").read()
    groupsList = groupsFolder.split(' ')
    aggrGroups = ''
    aggrRows = aggrFile.split('\n')
    errorCounter = 0
    for row in aggrRows:
        if row.find('=')>=1:
            aggrSplit = row.split('=')
            aggrGroups = aggrGroups+aggrSplit[0]+' '
            aggrHosts = aggrSplit[1].split(',')
            for hostGroup in aggrHosts:
                if os.path.exists("groups/"+hostGroup)==0:
                    print('error\nno such group '+hostGroup)
                    checkResult = "error"
            if errorCounter == 0:
                print("Successfully checked aggr "+aggrSplit[0])
            else:
                print("Failed to check aggr "+aggrSplit[0])
                errorCounter = 0
    aggrList = aggrGroups.split(' ')
    joinedList = groupsList + aggrList
    userRow = userFile.split('\n')
    userPattern = re.compile(r'^[^0-9|A-Z]{1}\.?[^0-9|A-Z]{2,20}')
    for row in userRow:
        if row.find('#')>=0:
            print("Commented row "+row)
            return
        if len(row)>=1:
            userSplit = row.split('=')
            patternCheck = userPattern.match(userSplit[0])
            if patternCheck.group() != userSplit[0]:
                print('error\nUser pattern check failed  '+userSplit[0])
                checkResult = "error"
                errorCounter = 1
            userHosts = userSplit[1].split(',')
            for hostGroup in userHosts:
                if aggrGroups not in str(joinedList):
                    if os.path.exists("groups/"+hostGroup)==0:
                        print('error\nno such group '+hostGroup)
                        checkResult = "error"
                        errorCounter = 1
            if errorCounter == 0:
                print("Successfully checked user "+userSplit[0])
            else:
                print("Failed to check user "+userSplit[0])
                errorCounter = 0
    return checkResult

def dublicate_name_validation():
    print('Start checking aggrgroup')
    checkResult = "Ok"
    groupsList = os.popen("ls groups").read()
    aggrFile = Path("groupsAggregation").read_text()
    splitedGroups = groupsList.split('\n')
    aggrSplit = aggrFile.split('\n')
    errorCounter = 0
    for row in aggrSplit:
        if row.find('=')>=1:
            result=row.split('=')
            for groupName in splitedGroups:
                if result[0] == groupName:
                    print('error\nFind dublicate group name '+result[0])
                    checkResult = "error"
                    errorCounter = 1
            if errorCounter == 0:
                print('Aggregation group validated '+result[0])
            else:
                errorCounter = 0
    return checkResult

def network_string_indicator(inputString):
    networkPattern = re.compile("\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/\d{1,2}")
    result = networkPattern.match(inputString)
    if result:
        check = inputString.split('.')
        for i in 0,1,2:
            if int(check[i]) < 0 or int(check[i]) > 255:
                print("shit happens, network validity failed on {} oktet of {}".format(str(i+1), inputString))
                return inputString, "error"
        last = check[3].split('/')
        if int(last[0]) < 0 or int(last[0]) > 255:
            print("shit happens, network validity failed on {} oktet of {}".format(str(i+1), inputString))
            return inputString, "error"
        if int(last[1]) < 16 or int(last[1]) > 32:
            print("Bad network "+inputString)
            return inputString, "error"
        return inputString, "network"
    else:
        addressPattern = re.compile("\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}")
        result = addressPattern.match(inputString)
        if result:
            check = inputString.split('.')
            for i in 0,1,2,3:
                try:
                    if int(check[i]) < 0 or int(check[i]) > 255:
                        print("shit happens, network validity failed on {} oktet of {}".format(str(i+1), inputString))
                        return inputString, "error"
                except ValueError :
                    return inputString, "error"
            return inputString, "address"
        else:
            try:
                return socket.gethostbyname(inputString), 'dname'
            except socket.gaierror:
                return inputString, "error"

def get_network_from_mask(network):
    splitRow = network.split('/')
    workOn = int(splitRow[1])
    countFullOctets = workOn // 8
    countLastOctets = workOn % 8
    if countFullOctets == 4:
        result = '255.255.255.255'
    elif countFullOctets == 3:
        temp = 256 - (2 ** (8 - countLastOctets))
        result = '255.255.255.'+str(temp)
    elif countFullOctets == 2:
        temp = 256 - (2 ** (8 - countLastOctets))
        result = '255.255.'+str(temp)+'.0'
    return result

def group_from_aggr():
    aggrFile = Path('groupsAggregation').read_text()
    aggrSplit = aggrFile.split('\n')
    for row in aggrSplit:
        if len(row)>1:
            rowSplit = row.split('=')
            groupSplit = rowSplit[1].split(',')
            if os.path.exists('groups/'+rowSplit[0]):
                os.remove('groups/'+rowSplit[0])
            result = open('groups/'+rowSplit[0], 'w')
            for group in groupSplit:
                file = Path('groups/'+group).read_text()
                result.write(file)
                result.write('\n')
            result.close()

def migration():
    dirs = ['users','nft']
    for dir in dirs:
        if os.path.exists(dir):
            shutil.rmtree(dir)
        os.makedirs(dir)
    userFile = Path('list').read_text()
    userSplit = userFile.split('\n')
    for row in userSplit:
        if len(row)>1:
            rowSplit = row.split('=')
            groupSplit = rowSplit[1].split(',')
            resultUsers = open('Users/'+rowSplit[0], 'w')
            resultNFT = open('nft/'+rowSplit[0], 'w')
            for group in groupSplit:
                address = Path('groups/'+group).read_text()
                addressSplit = address.split('\n')
                for line in addressSplit:
                    if len(line)>1:
                        result, type = network_string_indicator(line)
                        if type == 'dname' or type == 'address':
                            resultUsers.write('push "route '+result+'"\n')
                            resultNFT.write(result+'\n')
                        if type == 'network':
                            splitNetwork = result.split('/')
                            mask = get_network_from_mask(result)
                            resultUsers.write('push "route '+splitNetwork[0]+' '+mask+'"\n')
                            resultNFT.write(result+'\n')
            resultUsers.close()
            resultNFT.close()

def clear_migration():
    dirs = ['Users','nft']
    for dir in dirs:
        if os.path.exists(dir):
            shutil.rmtree(dir)
        os.makedirs(dir)
    aggrFile = Path('groupsAggregation').read_text()
    aggrSplit = aggrFile.split('\n')
    for row in aggrSplit:
        if len(row)>1:
            rowSplit = row.split('=')
            os.remove('groups/'+rowSplit[0])