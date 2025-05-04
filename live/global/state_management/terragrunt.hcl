terraform {
  source = "../../../modules/state_management"
}

inputs = {
  bucket_name = "terraform-iac-topgear"
  project     = "topgear"
}
