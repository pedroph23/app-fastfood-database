resource "aws_docdb_subnet_group" "default" {
 name      = "aws_documentdb_subnets_group"
 subnet_ids = ["subnet-01b5338603a6617a8", "subnet-0b8ae1b91b5d0ad94"] # your private subnet IDs
}

resource "aws_security_group" "this" {
 name       = "security_group_documentdb_fastfood"
 description = "Allow inbound traffic"

 vpc_id = "vpc-033482dbcf507bd17" # your EKS VPC ID

 ingress {
  from_port = 27017
  to_port   = 27017
  protocol  = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_docdb_cluster" "document_db" {
 cluster_identifier   = "fastfood-docdb2-cluster"
 engine               = "docdb"
 master_username      = var.db_username
 master_password      = var.db_password
 skip_final_snapshot  = true
 db_subnet_group_name = "aws_documentdb_subnets_group"
 vpc_security_group_ids = [aws_security_group.this.id]
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
 count              = 1
 identifier         = "fastfood-db2-instance-${count.index}"
 cluster_identifier = aws_docdb_cluster.document_db.id
 instance_class     = "db.t3.medium"
}
