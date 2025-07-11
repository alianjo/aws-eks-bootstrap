resource "aws_iam_policy" "elb_node_policy" {
  name   = "EKSNodeELBAccessPolicy"
  policy = file("${path.module}/policies/elb_controller_policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_elb_policy_to_nodes" {
  policy_arn = aws_iam_policy.elb_node_policy.arn
  role       = module.eks.eks_managed_node_groups["default"].iam_role_name
}

data "aws_iam_policy_document" "aws_lbc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "aws_lbc" {
  name               = "AWSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
}

resource "aws_iam_role_policy_attachment" "aws_lbc" {
  role       = aws_iam_role.aws_lbc.name
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
}

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/policies/iam-policy.json")
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:external-dns"]
    }
  }
}

resource "aws_iam_role" "external_dns" {
  name               = "ExternalDNSRole"
  assume_role_policy = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}