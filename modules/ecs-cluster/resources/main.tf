variable "cluster_name" {
  description = "Name of ECS Cluster"
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

output "cluster_id" {
  value = aws_ecs_cluster.this.id
}
