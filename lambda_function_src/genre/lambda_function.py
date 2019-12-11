import os
import io
import boto3
import json
import csv

# grab environment variables
ENDPOINT_NAME = os.environ['ENDPOINT_NAME']
runtime= boto3.client('runtime.sagemaker')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    
    data = json.loads(json.dumps(event))
    payload = data['data']
    print("payload", payload)
    
    name_endpoint = 'retrospider-genre' 

    response = runtime.invoke_endpoint(EndpointName=name_endpoint,
                                       ContentType='application/json',
                                       Body=json.dumps(payload))
    print(response)
    result = json.loads(response['Body'].read().decode())
    print(result)

    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }