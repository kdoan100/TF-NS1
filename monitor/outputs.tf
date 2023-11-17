
output "tcp_id" {
  description = "The output ID for the tcp monitoring feed"
  value       = try(ns1_datafeed.datafeed_tcp[0].id, null)
}

output "http_id" {
  description = "The output ID for the http monitoring feed"
  value       = try(ns1_datafeed.datafeed_http[0].id, null)
}

output "ping_id" {
  description = "The output ID for the ping monitoring feed"
  value       = try(ns1_datafeed.datafeed_ping[0].id, null)
}

output "dns_id" {
  description = "The output ID for the DNS monitoring feed"
  value       = try(ns1_datafeed.datafeed_dns[0].id, null)
}
