import json
import spacy

def lambda_handler(event, context):

    print("Received event: " + json.dumps(event, indent=2))

    ### load data from payload

    data = json.loads(json.dumps(event))
    payload = data['data']
    #print("payload", payload)
    
    ### extract person entities from payload using spacy
    nlp = spacy.load('/opt/en_core_web_sm-2.1.0')

    nlp_run = nlp(payload)
    output_ner = [(i, i.label_, i.label) for i in nlp_run.ents]
    #print(output_ner)
    
    people = []
    for i in nlp_run.ents:
        if i.label_ == "PERSON":
            people.append(str(i))
            
    people = list(dict.fromkeys(people))
    
    print(*people, sep = ", ")
    
    return {
        'statusCode': 200,
        'body': json.dumps(people)
    }