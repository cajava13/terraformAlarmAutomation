import boto3

# Lambda function to create CloudWatch alarm 
class CreateAlarm:
    def __init__(self):
        self.cloudwatch_client = boto3.client('cloudwatch')
        self.sns = boto3.client('sns')
    
    def find_topic(self):
        # List all of the SNS topics
        topics = self.sns.list_topics()

        # Iterate through the list of topics and find the topic that we want to use
        topic_arn = None
        for topic in topics['Topics']:
            topic_arn = topic['TopicArn']
            if topic_arn == 'arn:aws:sns:us-east-1:165834741047:MyTopic':
                break

        # If we didn't find the topic, then return an error
        if topic_arn is None:
            return {
                'statusCode': 404,
                'body': 'Topic not found'
            }

        # Return the topic ARN
        return {
            'statusCode': 200,
            'body': topic_arn
        }
             
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