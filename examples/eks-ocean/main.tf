module "ocean-eks" {
  source = "spotinst/ocean-eks/spotinst"

  # Credentials.
  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account
}

module "ocean-spark" {
  source = "../.."
  depends_on = [
    module.ocean-eks
  ]
}
