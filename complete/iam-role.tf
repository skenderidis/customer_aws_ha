resource "aws_iam_role" "f5-cloud-failover-role" {
  name = "f5-cloud-failover-role-${random_id.bucket_id.dec}"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "cfe-policy" {
  name        = "cfe-policy-${random_id.bucket_id.dec}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeAddresses",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeNetworkInterfaceAttribute",
                "ec2:DescribeRouteTables",
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation",
                "ec2:AssociateAddress",
                "ec2:DisassociateAddress",
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:CreateRoute",
                "ec2:ReplaceRoute"
            ],
            "Resource": "arn:*:ec2:*:*:route-table/*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:GetBucketTagging"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}


EOF
}

resource "aws_iam_role_policy_attachment" "attach1" {
  role       = aws_iam_role.f5-cloud-failover-role.name
  policy_arn = aws_iam_policy.cfe-policy.arn
}

resource "aws_iam_instance_profile" "f5_cloud_failover_profile" {
  name  = "f5_cloud_failover_profile-${random_id.bucket_id.dec}"
  role = aws_iam_role.f5-cloud-failover-role.name
}
