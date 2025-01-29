output "s3_bucket_name" {
  value = module.aws_s3_bucket.s3_bucket_id
}

output "velero_iam_role" {
  value = aws_iam_role.fall-project_velero_role.name
}

output "velero_iam_policy" {
  value = aws_iam_policy.fall-project_velero_policy.name
}
