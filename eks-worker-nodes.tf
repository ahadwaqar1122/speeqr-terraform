#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "speeqr-worker" {
  name = "speeqr-stage-worker"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "speeqr-worker-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.speeqr-worker.name
}

resource "aws_iam_role_policy_attachment" "speeqr-worker-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.speeqr-worker.name
}

resource "aws_iam_role_policy_attachment" "speeqr-worker-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.speeqr-worker.name
}

resource "aws_eks_node_group" "speeqr-stage" {
  cluster_name    = aws_eks_cluster.speeqr.name
  node_group_name = "speeqr-stage"
  node_role_arn   = aws_iam_role.speeqr-worker.arn
  subnet_ids      = aws_subnet.public[*].id
  disk_size       = 50
  capacity_type     = "ON_DEMAND"
  instance_types  = ["c5.4xlarge"]
  tags = {
    Environment = "stage"
    Application = "stage-speeqr"
    
  }


remote_access {
ec2_ssh_key = "stage-eks-cluster-key" 
}


 scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.speeqr-worker-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.speeqr-worker-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.speeqr-worker-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# resource "aws_eip" "stage_eip" {
#   vpc  = true
#   tags = {
#     Name = "nat"
#   }
# }


# resource "aws_eip_association" "eip" {
#   instance_id   = aws_eks_node_group.speeqr-stage.id
#   allocation_id = aws_eip.stage_eip.id
# }