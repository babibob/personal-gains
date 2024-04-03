import socket
import re
import os

def group_validator():
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
                        print("error input, string couldn't be parsed "+indicatingResult)
                        exit()

def user_validator():
    userFile = os.popen("cat list").read()
    aggrFile = os.popen("cat groupsAggregation").read()
    aggrGroups = ''
    aggrRows = aggrFile.split('\n')
    for row in aggrRows:
        if row.find('=')>=1:
            aggrSplit = row.split('=')
            aggrGroups = aggrGroups+aggrSplit[0]+' '
            aggrHosts = aggrSplit[1].split(',')
            for hostGroup in aggrHosts:
                result = os.popen("ls groups/"+hostGroup).read()
                if result.find("No such file or directory")>=1:
                    print('no such group '+hostGroup)
                    exit()
            print("Successfully checked aggr "+aggrSplit[0])
    userRow = userFile.split('\n')
    for row in userRow:
        if row.find('#')>=0:
            print("Commented row "+row)
            return
        if row.find('=')>=1:
            userSplit = row.split('=')
            userHosts = userSplit[1].split(',')
            for hostGroup in userHosts:
                if aggrGroups.find(hostGroup)>=0:
                    result = os.popen("ls "+hostGroup).read()
                    if result.find("No such file or directory")==1:
                        print('no such group'+hostGroup)
                        exit()
            print("Successfully checked user "+userSplit[0])


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

if __name__ == '__main__':
    group_validator()
    user_validator()
