# S3 Buckets
resource "aws_s3_bucket" "media_ingestion" {
  bucket = "${var.client_name}-media-ingestion"
  tags = merge(
    var.common_tags,
    { Name = "${var.client_name}-media-ingestion" }
  )
}

resource "aws_s3_access_point" "media_ingestion_access_point" {
  bucket = aws_s3_bucket.media_ingestion.id
  name   = "${var.client_name}-media-ingestion-ap"

  public_access_block_configuration {
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
  }
}

resource "aws_s3_bucket" "metadata_ingestion" {
  bucket = "${var.client_name}-metadata-ingestion"
  tags = merge(
    var.common_tags,
    { Name = "${var.client_name}-metadata-ingestion" }
  )
}

resource "aws_s3_access_point" "metadata_ingestion_access_point" {
  bucket = aws_s3_bucket.metadata_ingestion.id
  name   = "${var.client_name}-metadata-ingestion-ap"

  public_access_block_configuration {
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
  }
}

resource "aws_s3_bucket" "alert_engines_output" {
  bucket = "${var.client_name}-alert-engines-output"
  tags = merge(
    var.common_tags,
    { Name = "${var.client_name}-alert-engines-output" }
  )
}

resource "aws_s3_bucket" "media_alerts" {
  bucket = "${var.client_name}-media-alerts"
  tags = merge(
    var.common_tags,
    { Name = "${var.client_name}-media-alerts" }
  )
}

resource "aws_s3_bucket" "report" {
  bucket = "${var.client_name}-report"
  tags = merge(
    var.common_tags,
    { Name = "${var.client_name}-report" }
  )
}

resource "aws_s3_bucket" "media_scan_result" {
  bucket = "${var.client_name}-media-scan-result"
  tags = merge(
    var.common_tags,
    { Name = "${var.client_name}-media-scan-result" }
  )
}

resource "aws_s3_bucket" "auxiliary_media" {
  bucket = "${var.client_name}-auxiliary-media"
  tags = merge(
    var.common_tags,
    { Name = "${var.client_name}-auxiliary-media" }
  )
}

# SQS Queue
resource "aws_sqs_queue" "customer_queue" {
  name = "${var.client_name}-queue"
  tags = merge(
    var.common_tags,
    { Name = "${var.client_name}-queue" }
  )
}

# SNS Topic
resource "aws_sns_topic" "customer_topic" {
  name = "${var.client_name}-topic"
  tags = merge(
    var.common_tags,
    { Name = "${var.client_name}-topic" }
  )
}

# SNS Subscription to SQS
resource "aws_sns_topic_subscription" "customer_sqs_subscription" {
  topic_arn = aws_sns_topic.customer_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.customer_queue.arn
  depends_on = [aws_sqs_queue_policy.customer_queue_policy]
}

# Policy to allow SNS to publish to SQS
resource "aws_sqs_queue_policy" "customer_queue_policy" {
  queue_url = aws_sqs_queue.customer_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.customer_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.customer_topic.arn
          }
        }
      }
    ]
  })
}

# S3 Bucket Notification
resource "aws_s3_bucket_notification" "media_ingestion_notification" {
  bucket = aws_s3_bucket.media_ingestion.id

  queue {
    queue_arn = "arn:aws:sqs:eu-west-1:058264128783:MediaAnalysisFlowQueue"
    events    = ["s3:ObjectCreated:*"]
  }
}