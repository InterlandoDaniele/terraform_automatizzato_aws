output "media_ingestion_bucket_name" {
  description = "Nome del bucket S3 per media ingestion"
  value       = aws_s3_bucket.media_ingestion.id
}

output "metadata_ingestion_bucket_name" {
  description = "Nome del bucket S3 per metadata ingestion"
  value       = aws_s3_bucket.metadata_ingestion.id
}

output "alert_engines_output_bucket_name" {
  description = "Nome del bucket S3 per alert engines output"
  value       = aws_s3_bucket.alert_engines_output.id
}

output "media_alerts_bucket_name" {
  description = "Nome del bucket S3 per media alerts"
  value       = aws_s3_bucket.media_alerts.id
}

output "report_bucket_name" {
  description = "Nome del bucket S3 per report"
  value       = aws_s3_bucket.report.id
}

output "media_scan_result_bucket_name" {
  description = "Nome del bucket S3 per media scan result"
  value       = aws_s3_bucket.media_scan_result.id
}

output "auxiliary_media_bucket_name" {
  description = "Nome del bucket S3 per auxiliary media"
  value       = aws_s3_bucket.auxiliary_media.id
}

output "customer_queue_arn" {
  description = "ARN della coda SQS del cliente"
  value       = aws_sqs_queue.customer_queue.arn
}

output "customer_topic_arn" {
  description = "ARN del topic SNS del cliente"
  value       = aws_sns_topic.customer_topic.arn
}

/* output "bucket_name" {
  value = aws_s3_bucket.this.id  
} */