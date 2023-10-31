import boto3

class DeleteAlarm:
    def __init__(self):
        self.cloudwatch_client = boto3.client('cloudwatch')
    
    def delete_alarm(self,InstanceID):
        try:
            response = self.cloudwatch_client.delete_alarms(
                    AlarmNames=[InstanceID]
                )
            
            return {
                'statusCode': 200,
                'body': 'The CPUUtilization Alarm deleted successfully!'
            }
        except Exception as e:
            print(f'Error delete the CPUUtilization Alarm')
            return {
                'statusCode': 500,
                'body': 'Error delete the CPUUtilization Alarm'
            }

# Lambda function to delete CloudWatch alarm when instance is terminated
def lambda_handler(event, context):
    # get the instance id that triggered the event
    InstanceID = event['detail']['instance-id']
    print("instance-id: " + InstanceID)
    return DeleteAlarm().delete_alarm(InstanceID)