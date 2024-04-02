import os
import shutil
from pathlib import Path
from basefunc import get_network_from_mask, network_string_indicator

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
            resultUsers = open('users/'+rowSplit[0], 'w')
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

if __name__ == '__main__':
#    group_from_aggr()
    migration()