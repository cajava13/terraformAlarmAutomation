import boto3

# Lambda function to create CloudWatch alarm 
class CreateAlarm:
    def __init__(self):
        self.cloudwatch_client = boto3.client('cloudwatch')
             
    def create_alarm(self,thisInstanceID):
        try:
            response = self.cloudwatch_client.put_metric_alarm(
                AlarmName = thisInstanceID,
                AlarmDescription='the age of the latest consistent snapshot, in seconds',
                ActionsEnabled=True,
                MetricName='CPUUtilization',
                Namespace='AWS/EC2',
                Statistic='Average',
                Period=300,
                EvaluationPeriods=5,
                Threshold=1,
                ComparisonOperator='GreaterThanOrEqualToThreshold',
                Unit='Seconds'
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
    thisInstanceID = event['detail']['instance-id']
    print("instance-id: " + thisInstanceID)
    return CreateAlarm().create_alarm(thisInstanceID)