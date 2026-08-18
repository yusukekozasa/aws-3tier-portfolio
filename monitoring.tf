  # monitoring.tf

# ---------------------------------------------
# 1. SNS Topic (アラート通知の送信先グループ)
# ---------------------------------------------
resource "aws_sns_topic" "alerts" {
  name = "sysmon-alerts-topic"

  tags = {
    Name = "sysmon-alerts-topic"
  }
}

# ---------------------------------------------
# 2. SNS Subscription (通知先メールアドレスの設定)
# ---------------------------------------------
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "basukebu28@gmail.com" 
}

# ---------------------------------------------
# 3. CloudWatch Alarm (EC2 Web1 のCPU使用率監視: 80%超えで発報)
# ---------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high_1" {
  alarm_name          = "web1-high-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors EC2 web1 CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.web_1.id
  }

  tags = {
    Name = "web1-high-cpu-alarm"
  }
}

# ---------------------------------------------
# 4. CloudWatch Alarm (EC2 Web2 のCPU使用率監視: 80%超えで発報)
# ---------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high_2" {
  alarm_name          = "web2-high-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors EC2 web2 CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.web_2.id
  }

  tags = {
    Name = "web2-high-cpu-alarm"
  }
}