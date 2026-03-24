locals {
  normalized_student_id = lower(join("", regexall("[0-9A-Za-z-]", var.student_id)))
  subscription_uuid     = startswith(var.subscription_id, "/subscriptions/") ? element(split("/", var.subscription_id), 2) : var.subscription_id
  subscription_slug     = lower(join("", regexall("[0-9a-z]", local.subscription_uuid)))
  unique_suffix         = substr(local.subscription_slug, 0, 6)

  name_prefix = "lia-${local.normalized_student_id}-${local.unique_suffix}"

  tags = merge(
    {
      project     = "lia-azure-lab"
      environment = var.environment
      student     = var.student_id
      suffix      = local.unique_suffix
      managed_by  = "terraform"
    },
    var.tags
  )
}
