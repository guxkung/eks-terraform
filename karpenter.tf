# Karpenter default EC2NodeClass and NodePool

resource "kubectl_manifest" "karpenter_default_ec2_node_class" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default
spec:
  role: "${local.node_iam_role_name}"
  amiSelectorTerms: 
  - alias: bottlerocket@latest
  securityGroupSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${local.name}
  subnetSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${local.name}
  tags:
    IntentLabel: apps
    KarpenterNodePoolName: default
    NodeType: default
    intent: apps
    karpenter.sh/discovery: ${local.name}
    project: karpenter-blueprints
YAML
  depends_on = [
    module.eks.cluster,
    module.eks_blueprints_addons.karpenter,
  ]
}

resource "kubectl_manifest" "karpenter_default_node_pool" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: default 
spec:  
  template:
    metadata:
      labels:
        intent: apps
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot", "on-demand"]
        - key: karpenter.sh/instance-type
          operator: In
          values: ["t3.large", "t3.xlarge"]
      nodeClassRef:
        name: default
        group: karpenter.k8s.aws
        kind: EC2NodeClass
      kubelet:
        containerRuntime: containerd
        systemReserved:
          cpu: 100m
          memory: 100Mi
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 1m
    
YAML
  depends_on = [
    module.eks.cluster,
    module.eks_blueprints_addons.karpenter,
    kubectl_manifest.karpenter_default_ec2_node_class,
  ]
}
