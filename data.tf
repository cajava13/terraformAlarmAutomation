# data.tf

#########################################
# Create zip files for Lambda function
#########################################
data "archive_file" "createAlarmZip" {
  type             = "zip"
  source_file      = "Lambdas/createAlarm.py"
  output_path      = "Lambdas/createAlarm.zip"
}

data "archive_file" "deleteAlarmZip" {
  type             = "zip"
  source_file      = "Lambdas/deleteAlarm.py"
  output_path      = "Lambdas/deleteAlarm.zip"
}