import json
import difflib

def lambda_handler(event, context):
    
    print("Received event: " + json.dumps(event, indent=2))

    ### load data from payload
    data = json.loads(json.dumps(event))
    payload = data['data']
    print("payload", payload)
    
    input = payload['input']
    list = payload['list']
    #print("input", input)
    #print("list", list)
    
    output = []
    
    for i in range(len(list)):
 
        #print(list[i])
        score = difflib.SequenceMatcher(None, input, list[i]).ratio()
        #print("score: ", score)
        
        output.append([list[i], score])
    
    print("output", output)
    
    return {
        'statusCode': 200,
        'body': json.dumps(output)
    }