output "vpc_id" { value = aws_vpc.this.id }
output "public_subnets" { value = [aws_subnet.public_1.id, aws_subnet.public_2.id] }
output "private_subnets" { value = [aws_subnet.presentation_1.id, aws_subnet.presentation_2.id] }
output "eks_cluster_name" { value = aws_eks_cluster.this.name }
output "eks_cluster_endpoint" { value = aws_eks_cluster.this.endpoint }
output "eks_cluster_oidc_issuer" { value = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer }