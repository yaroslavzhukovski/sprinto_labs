locals {
  # Storage account names can only contain lowercase letters and numbers.
  sa_name = substr(replace("st${var.prefix}", "-", ""), 0, 24)
}
