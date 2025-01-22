#bucket to store website
resource "google_storage_bucket" "website"{
	name = "terraform-gcp-hesham-1"
	location ="US"

}
#make the object public
resource "google_storage_object_acl" "public_rule" {
  bucket = google_storage_bucket.website.name
  object = google_storage_bucket_object.static_site_src.name
  role_entity = [
    "READER:allUsers",
  ]
}
#upload the html file to the bucket 
 resource "google_storage_bucket_object" "static_site_src" {
	name = "index.html"
	source = "../website/index.html"
	bucket = google_storage_bucket.website.name
   
 }
 #reserve static external ip address 
 resource "google_compute_global_address" "website_ip" {
	name = "website-lb-ip"

   
 }
 # Define the backend bucket
resource "google_compute_backend_bucket" "website-backend" {
  name        = "website-backend"
  bucket_name = google_storage_bucket.website.name
  enable_cdn  = true  # Enable CDN for the backend bucket
}

# Define the URL map
resource "google_compute_url_map" "website-url-map" {
  name            = "website-url-map"
  default_service = google_compute_backend_bucket.website-backend.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.website-backend.self_link
  }
}

# Define the HTTP proxy
resource "google_compute_target_http_proxy" "website-http-proxy" {
  name    = "website-http-proxy"
  url_map = google_compute_url_map.website-url-map.self_link
}

# Define the global forwarding rule
resource "google_compute_global_forwarding_rule" "website-forwarding-rule" {
  name       = "website-forwarding-rule"
  target     = google_compute_target_http_proxy.website-http-proxy.self_link
  port_range = "80"
}