import boto3

# Lambda function to create CloudWatch alarm 
class CreateAlarm:
    def __init__(self):
        self.cloudwatch_client = boto3.client('cloudwatch')
             
    def create_alarm(self,InstanceID):
        try:
            response = self.cloudwatch_client.put_metric_alarm(
                AlarmName = InstanceID,
                AlarmDescription='CPUUtilization',
                ActionsEnabled=True,
                MetricName='CPUUtilization',
                Namespace='AWS/EC2',
                Statistic='Average',
                Period=60,
                EvaluationPeriods=1,
                Threshold=80,
                ComparisonOperator='GreaterThanOrEqualToThreshold',
                Dimensions=[
                    {
                        'Name': 'InstanceId',
                        'Value': InstanceID
                    },
                ],
            )
            return {
                'statusCode': 200,
                'body': 'The CPUUtilization Alarm created successfully!'
            }
        except Exception as e:
            print(f'Error creating the CPUUtilization Alarm')
            return {
                'statusCode': 500,
                'body': 'Error creating the CPUUtilization Alarm'
            }
            
def lambda_handler(event, context):
    # get the instance id that triggered the event
    InstanceID = event['detail']['instance-id']
    print("instance-id: " + InstanceID)
    return CreateAlarm().create_alarm(InstanceID)