import json

def returnList():
    labels = [{'name':'White T-shirt'}, 
              {'name':'Black hoodie'}, 
              {'name':'Jeans'}]
    result = {'result': labels}
    print(json.dumps(result))

returnList()