#########################################
# Create Lambdas
#########################################

resource "aws_lambda_function" "create_alarm" {
  filename         = "Lambdas/createAlarm.zip"
  function_name    = "create_alarm"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "createAlarm.create_alarm"
  source_code_hash = data.archive_file.createAlarmZip.output_base64sha256
  runtime          = "python3.10"
  timeout          = "10"
}

resource "aws_lambda_function" "delete_alarm" {
  filename      = "Lambdas/deleteAlarm.zip"
  function_name = "delete_alarm"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "deleteAlarm.delete_alarm"
  source_code_hash = data.archive_file.deleteAlarmZip.output_base64sha256
  runtime          = "python3.10"
  timeout          = "10"
}

# Create the IAM role for Lambda execution
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

# Attach the required IAM policies to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create the IAM policy for accessing SNS
resource "aws_iam_policy" "sns_policy" {
  name        = "sns_policy"
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

# Attach the IAM policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "sns_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.sns_policy.arn
}

# Create the CloudWatch Event Rule: Trigger on Instance Creation
resource "aws_cloudwatch_event_rule" "instance_create_rule" {
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

# Create the CloudWatch Event Rule Target for the instance_create_rule
resource "aws_cloudwatch_event_target" "instance_create_target" {
  rule      = aws_cloudwatch_event_rule.instance_create_rule.name
  target_id = "create_alarm_lambda_target"
  arn       = aws_lambda_function.create_alarm.arn
}

# Create the CloudWatch Event Rule: Trigger on Instance Termination
resource "aws_cloudwatch_event_rule" "instance_terminate_rule" {
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

# Create the CloudWatch Event Rule Target for the instance_terminate_rule
resource "aws_cloudwatch_event_target" "instance_terminate_target" {
  rule      = aws_cloudwatch_event_rule.instance_terminate_rule.name
  target_id = "delete_alarm_lambda_target"
  arn       = aws_lambda_function.delete_alarm.arn
}

# Create the Lambda permission for instance_create_rule
resource "aws_lambda_permission" "instance_create_permission" {
  statement_id  = "AllowExecutionFromCloudWatchEventRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_alarm.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.instance_create_rule.arn
}

# Create the Lambda permission for instance_terminate_rule
resource "aws_lambda_permission" "instance_terminate_permission" {
  statement_id  = "AllowExecutionFromCloudWatchEventRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_alarm.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.instance_terminate_rule.arn
}