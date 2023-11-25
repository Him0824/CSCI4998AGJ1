import base64
import json

image_list = []

with open('2.jpg', 'rb') as image_file1:
    base64_image1 = base64.b64encode(image_file1.read()).decode('utf-8')
    temp = {
        'name': '2.jpg',
        'data': base64_image1
    }
    image_list.append(temp)

with open('3.jpg', 'rb') as image_file2:
    base64_image2 = base64.b64encode(image_file2.read()).decode('utf-8')
    temp = {
        'name': '3.jpg',
        'data': base64_image2
    }
    image_list.append(temp)

result = {'result': image_list}

print(json.dumps(result))