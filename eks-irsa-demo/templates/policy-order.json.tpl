{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "OrderProcessing",
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "arn:aws:sqs:*:*:order-queue",
        "arn:aws:dynamodb:*:*:table/orders"
      ]
    }
  ]
}
