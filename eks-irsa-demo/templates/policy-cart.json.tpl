{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CartTableAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/cart-items"
    }
  ]
}
