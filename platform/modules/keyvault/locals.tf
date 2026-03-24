locals {
  kv_name = substr(lower(join("", regexall("[0-9a-z-]", "kv-${var.prefix}"))), 0, 24)
}
