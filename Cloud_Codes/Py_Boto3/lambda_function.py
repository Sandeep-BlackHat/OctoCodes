import boto3
def lambda_handler(event, context):
    client = boto3.client('ec2')
    response = client.describe_instances(
        Filters=[{
                'Name': 'tag:project',
                'Values': [event['project']]
            },
        ]
    )
    msg_dict = {'PreviousState': None, 'CurrentState': None}
    for instance in response['Reservations']:
        instance_id = instance['Instances'][0]['InstanceId']
        instance_state = instance['Instances'][0]['State']['Name']
        if instance_state=='stopped':
            response = client.start_instances(
                    InstanceIds=[instance_id]
                )
            msg_dict['PreviousState'] = response['StartingInstances'][0]['PreviousState']['Name']
            msg_dict['CurrentState'] = response['StartingInstances'][0]['CurrentState']['Name']
        elif instance_state=='running':
            response = client.stop_instances(
                    InstanceIds=[instance_id]
                )
            msg_dict['PreviousState'] = response['StoppingInstances'][0]['PreviousState']['Name']
            msg_dict['CurrentState'] = response['StoppingInstances'][0]['CurrentState']['Name']
    return msg_dict
