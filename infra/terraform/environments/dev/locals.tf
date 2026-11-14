locals {
  common_tags = {
    Project     = "enterprise-3tier-devsecops"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}