# outputs.tf

output "alb_dns_name" {
  description = "Webアプリケーションのアクセス用URL (ALB DNS Name)"
  value       = aws_lb.main.dns_name
}

output "rds_endpoint" {
  description = "RDSデータベースの接続エンドポイント"
  value       = aws_db_instance.main.endpoint
}