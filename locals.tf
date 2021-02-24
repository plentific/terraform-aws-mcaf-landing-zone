locals {
  aws_account_emails = { for account in data.aws_organizations_organization.default.accounts : account.id => account.email }
  aws_config_aggregators = flatten([
    for account in toset(try(var.aws_config.aggregator_account_ids, [])) : [
      for region in toset(try(var.aws_config.aggregator_regions, [])) : {
        account_id = account
        region     = region
      }
    ]
  ])
  aws_config_rules = concat(
    try(var.aws_config.rule_identifiers, []),
    [
      "CLOUD_TRAIL_ENABLED",
      "ENCRYPTED_VOLUMES",
      "ROOT_ACCOUNT_MFA_ENABLED",
      "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
    ]
  )
  iam_activity = {
    Root = "{ $.userIdentity.type = \"Root\" }"
    SSO  = "{ $.readOnly IS FALSE  && $.userIdentity.sessionContext.sessionIssuer.userName = \"AWSReservedSSO_*\" && $.eventName != \"ConsoleLogin\" }"
  }
  security_hub_standards_arns = [
    "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0",
    "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0",
    "arn:aws:securityhub:${data.aws_region.current.name}::standards/pci-dss/v/3.2.1"
  ]
}
