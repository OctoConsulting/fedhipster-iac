resource "aws_ecr_repository" "app" {
  name = "app"

  tags = {
    Name = "App ECR repo"
  }
}

resource "aws_ecr_repository" "micro" {
  name = "micro"

  tags = {
    Name = "Micro ECR repo"
  }
}

output "ecr-app" {
  value = aws_ecr_repository.app.repository_url
}

output "ecr-micro" {
  value = aws_ecr_repository.micro.repository_url
}
