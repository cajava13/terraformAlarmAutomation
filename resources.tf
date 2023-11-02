#########################################
# Create Lambdas
#########################################
resource "aws_lambda_function" "create_alarm" {
  filename         = "Lambdas/createAlarm.zip"
  function_name    = "create_alarm"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "createAlarm.lambda_handler"
  source_code_hash = data.archive_file.createAlarmZip.output_base64sha256
  runtime          = "python3.10"
  timeout          = "30"
}
resource "aws_lambda_function" "delete_alarm" {
  filename      = "Lambdas/deleteAlarm.zip"
  function_name = "delete_alarm"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "deleteAlarm.lambda_handler"
  source_code_hash = data.archive_file.deleteAlarmZip.output_base64sha256
  runtime          = "python3.10"
  timeout          = "30"
}
######################################################################
# Create the IAM role for Lambda execution
######################################################################
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
######################################################################
# Create the IAM policy for Lambda
######################################################################
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Allows Lambda functions to access SNS topic"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}
######################################################################
# Attach the IAM policy for the Lambda execution role
######################################################################
resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}



###############################################################################
# CloudWatch Event Rule EC2 instance Status Running
###############################################################################
resource "aws_cloudwatch_event_rule" "ec2_instance_running_rule" {
  name        = "instance_create_rule"
  description = "Trigger Lambda function when an instance is created"
  event_pattern = <<EOF
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ],
  "detail": {
    "state": [
      "running"
    ]
  }
}
EOF
}
######################################################################
# Lambda create_alarm permission
######################################################################
resource "aws_lambda_permission" "create_alarm_permission" {
  statement_id  = "AllowExecutionFromCloudWatchEventRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_alarm.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_instance_running_rule.arn
}
######################################################################
# CloudWatch Event Rule Target for the ec2_instance_running_rule
######################################################################
resource "aws_cloudwatch_event_target" "instance_create_target" {
  rule      = aws_cloudwatch_event_rule.ec2_instance_running_rule.name
  target_id = "create_alarm_lambda_target"
  arn       = aws_lambda_function.create_alarm.arn
}


######################################################################
# CloudWatch Event Rule EC2 instance Status Terminated
######################################################################
resource "aws_cloudwatch_event_rule" "ec2_instance_terminate_rule" {
  name        = "instance_terminate_rule"
  description = "Trigger Lambda function when an instance is terminated"
  event_pattern = <<EOF
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ],
  "detail": {
    "state": [
      "terminated"
    ]
  }
}
EOF
}
######################################################################
# Lambda delete_alarm permission
######################################################################
resource "aws_lambda_permission" "delete_alarm_permission" {
  statement_id  = "AllowExecutionFromCloudWatchEventRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_alarm.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_instance_terminate_rule.arn
}
######################################################################
# CloudWatch Event Rule Target for the ec2_instance_terminated_rule
######################################################################
resource "aws_cloudwatch_event_target" "instance_terminate_target" {
  rule      = aws_cloudwatch_event_rule.ec2_instance_terminate_rule.name
  target_id = "delete_alarm_lambda_target"
  arn       = aws_lambda_function.delete_alarm.arn
}