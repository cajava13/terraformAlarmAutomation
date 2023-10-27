import boto3

# Lambda function to create CloudWatch alarm and associate with SNS topic
def create_alarm(event, context):
    instance_id = event['detail']['instance-id']
    
    # Create CloudWatch client
    cloudwatch = boto3.client('cloudwatch')
    
    # Create SNS client
    sns = boto3.client('sns')
    
    # Create CloudWatch alarm
    response = cloudwatch.put_metric_alarm(
        AlarmName=f'InstanceAlarm-{instance_id}',
        ComparisonOperator='GreaterThanThreshold',
        EvaluationPeriods=1,
        MetricName='CPUUtilization',
        Namespace='AWS/EC2',
        Period=180,
        Threshold=80,
        Statistic='Average',
        Dimensions=[
            {
                'Name': 'InstanceId',
                'Value': instance_id
            },
        ],
    )
    
    print(f'CloudWatch alarm created: {response}')
