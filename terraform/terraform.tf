  provider "aws" {
    region = "us-east-1"
    profile = "default"
  }

   #  Lambda function
  resource "aws_lambda_function" "lambdahello" {
    function_name    = "lambdahello"
    handler          = "handler.handler"
    role             = "aws_iam_role.lambda_assume_role.arn"
    runtime          = "python3.8"
  
    lifecycle {
      create_before_destroy = true
    }
  }

 # Lambda IAM role

  resource "aws_iam_role" "lambdahello" {
    name = "lambdahello"
  
    assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "LambdaAssumeRole"
      }
    ]
  }
  EOF
  }

  # Step Function
resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "step-function"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<EOF
  {
    "Comment": "Invoke AWS Lambda from AWS Step Function with Terraform",
    "StartAt": "HelloWorld",
    "States": {
      "HelloWorld": {
        "Type": "Task",
        "Resource": "aws_lambda_function.lambdahello.arn",
        "End": true
      }
    }
  }
  EOF
}
# # Step Function Role
  resource "aws_iam_role" "step_function_role" {
    name               = "step-function-role"
    assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "states.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": "StepFunctionAssumeRole"
        }
      ]
    }
    EOF
  }
# # Step Function Policy
  resource "aws_iam_role_policy" "step_function_policy" {
  name    = "step-function-policy"
  role    = aws_iam_role.step_function_role.id

  policy  = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": "aws_lamba_function.lambdahello.arn"
      }
    ]
  }
  EOF
}
