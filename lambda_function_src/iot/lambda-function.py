import json
import boto3
import botocore.vendored.requests.packages.urllib3 as urllib3


def lambda_handler(event, context):
    print('One click Deploy called')
    
    url = 'http://<JENKINS_ENDPINT>/job/app-prod/buildWithParameters?token=<JOB_TOKEN>'

    http = urllib3.PoolManager()
    
    headers = {
        "Authorization": "Basic <BASE_64_ENCODED_TOKEN>"
    }
    
    req = http.request('GET', url, headers=headers)
    print(req.status) 
    
    if (req.status == 201):
        encoded_body = json.dumps({
            "text": "Production Deployment triggered via 1-click IoT button!"
        })
        req2 = http.request('POST', '<SLACK_WEBHOOK_URL>', headers={'Content-Type':'application/json'}, body=encoded_body)

        print('One click Deploy submitted')
        return {
            'statusCode': 201,
            'body': json.dumps('Prod deployment triggered successfully!')
        }
    else:
        print('Failed to trigger One click Deploy')
        return {
            'statusCode': 500,
            'body': json.dumps('Prod deployment trigger failed!')
        }
