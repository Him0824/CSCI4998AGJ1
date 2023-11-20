import json

def returnList():
    labels = [{'name':'1'}, 
              {'name':'2'}, 
              {'name':'3'}]
    result = {'result': labels}
    print(json.dumps(result))

returnList()