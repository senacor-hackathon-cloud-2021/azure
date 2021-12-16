output "zone_nameservers" {
  value = module.dns.zone_nameservers
}

output "app_service_url" {
  value = module.app_service_public.service_url
}
output "container_app_url" {
  value = module.container_app_public.service_url
}
output "container_instance_url" {
  value = module.container_instance_public.service_url
}
