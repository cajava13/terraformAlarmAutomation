import boto3

# Lambda function to delete CloudWatch alarm when instance is terminated
def delete_alarm(event, context):
    instance_id = event['detail']['instance-id']
    
    # Create CloudWatch client
    cloudwatch = boto3.client('cloudwatch')
    
    # Describe CloudWatch alarms
    response = cloudwatch.describe_alarms(
        AlarmNamePrefix=f'InstanceAlarm-{instance_id}',
    )
    
    alarm_names = [alarm['AlarmName'] for alarm in response['MetricAlarms']]
    
    # Delete CloudWatch alarms
    for alarm_name in alarm_names:
        response = cloudwatch.delete_alarms(
            AlarmNames=[alarm_name]
        )
        
        print(f'CloudWatch alarm deleted: {response}')