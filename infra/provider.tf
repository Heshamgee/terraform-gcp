#gcp provider 
provider "google"{
	credentials = file(var.gcp_svc_key)
	project = "esoteric-stream-447816-e7"
	region = var.gcp_region 


}
