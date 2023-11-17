# terraform-ns1-monitor

This module creates health-monitors on NS1. The monitors can then be used for the UP status for a record response. Monitors can be one of the following: tcp, ping, http and dns

## Usage

Basic usage of this module is as follows:

```hcl

module "mntcp-test" {
  source = "../../monitor"

  name          = "tcp-test"
  regions       = ["lga"]
  job_type      = "tcp"

  port       = 443
  host       = "connect-dev.fiservapis.com"
  
  value      = "1000"
  comparison = "<"
  key        = "connect"

}

module "mnping-test" {
  source = "../../monitor"

  name          = "ping-test"
  regions       = ["lga"]
  job_type      = "ping"

  host       = "connect-dev.fiservapis.com"

  value      = "200"
  comparison = "<"
  key        = "rtt"

}

module "mnhttp-test" {
  source = "../../monitor"

  name          = "http-test"
  regions       = ["lga"]
  job_type      = "http"

  url        = "https://35a52859548942dd8e6032e3db351019.v1.radwarecloud.net/healthz/ingress"
  virtual_host = "connect-test.fiservapis.com"

  value      = "200"
  comparison = "=="
  key        = "status_code"

}

module "mndns-test" {
  source = "../../monitor"

  name          = "dns-test"
  regions       = ["lga"]
  job_type      = "dns"

  domain        = "connect-test.fiservapis.com"
  host          = "8.8.8.8"
  port          = 53

  value      = "66.22.20.115"
  comparison = "contains"
  key        = "rdata"

}

# Using the monitor for an "UP" status in an answer
module "terraform-test" {
  source = "../../dnsrecord"

  zone   = "ns1.fiservapis.com"
  domain = "terraform-test.ns1.fiservapis.com"
  type   = "A"
  ttl    = 60

  answers = [
    {
      name   = "1.1.1.1"
      georegion = "US-CENTRAL"
      # up = "{\"feed\":\"74dec64904f3c521eb229feb\"}"
      up = 1
    },
    {
      name   = "10.10.10.10"
      up = "{\"feed\":\"${module.mndns-test.dns_id}\"}"
    }
  ]

```
## Notes
Building the Terraform module requires that the NS1 API be interagated so that the parameters can be identified. Only standard parameters are shown in the NS1 Terraform registry.

Get all the values for the job type
  curl -X GET -H "X-NSONE-Key: $NSONE_API_KEY" https://api.nsone.net/v1/monitoring/jobtypes | jq

    note: 
      jq is a json formatter and needs to be installed
      the $NSONE_API_KEY is the API key used for authentication - found in the NS1 API key on the console

Get the list of all the data sources or just a single record
  curl -X GET -H "X-NSONE-Key: $NSONE_API_KEY" https://api.nsone.net/v1/data/sources | jq
  curl -X GET -H "X-NSONE-Key: $NSONE_API_KEY" https://api.nsone.net/v1/data/sources/<sourceID> | jq
    
Get all the values for the data source types
  curl -X GET -H "X-NSONE-Key: $NSONE_API_KEY" https://api.nsone.net/v1/data/sourcetypes | jq

Get all the notifier list or just a single list
  curl -X GET -H "X-NSONE-Key: $NSONE_API_KEY" https://api.nsone.net/v1/lists | jq
  curl -X GET -H "X-NSONE-Key: $NSONE_API_KEY" https://api.nsone.net/v1/lists/<listID> | jq

Get a list of the notifier type
  curl -X GET -H "X-NSONE-Key: $NSONE_API_KEY" https://api.nsone.net/v1/notifytypes | jq

## Inputs

Main block
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The free-form display name for the monitoring job.  | `string` | n/a | yes |
| job_type | The type of monitoring job to be run. Refer to the NS1 API documentation (https://ns1.com/api#monitoring-jobs) for supported values which include: `ping`, `tcp`, `dns`, `http` | `string` | n/a | yes |
| active | Indicates if the job is active or temporarily disabled. | `bool` | n/a | yes |
| regions | Region where the resource resides: `nrt` (APAC), `dal` (US-CENTRAL), `sin` (APAC), `sjc` (US-WEST), `lga` (US-EAST), `ams` (EMEA), `syd` (APAC), `gru` (LATAM), `lhr` (EMEA) | `string` | n/a | yes |
| frequency | The frequency, in seconds, at which to run the monitoring job in each region, 5s minimum | `number` | n/a | yes |
| rapid_recheck | If true, on any apparent state change, the job is quickly re-run after one second to confirm the state change before notification | `bool` | n/a | yes |
| policy | The policy for determining the monitor's global status based on the status of the job in all regions: QUORUM, ALL, ONE | `string` | QUORUM | no |
| Config | See block below*. A configuration dictionary with keys and values depending on the job_type. Configuration details for each job_type are found by submitting a GET request to https://api.nsone.net/v1/monitoring/jobtypes. | block | n/a | yes |
| mute | turn off the notifications for the monitoring job. | `bool` | n/a | no |
| notify_delay | The time in seconds after a failure to wait before sending a notification. | `number` | 3 | no |
| notify_repeat | The time in seconds between repeat notifications of a failed job. | `number` | 3 | no |
| notify_failback | If true, a notification is sent when a job returns to an "up" state. | `bool` | n/a | no |
| notify_regional | If true, notifications are sent for any regional failure (and failback if desired), in addition to global state notifications. | `bool` | n/a | no |
| notify_list | The Terraform ID (e.g. ns1_notifylist.my_slack_notifier.id) of the notification list to which monitoring notifications should be sent. | `string` | n/a | no |
| notes | Freeform notes to be included in any notifications about this job. | `string` | n/a | no |
| rules | See rule block*. A list of rules for determining failure conditions. Each rule acts on one of the outputs from the monitoring job. You must specify key (the output key); comparison (a comparison to perform on the the output); and value (the value to compare to). For example, {"key":"rtt", "comparison":"<", "value":100} is a rule requiring the rtt from a job to be under 100ms, or the job will be marked failed. Available output keys, comparators, and value types are are found by submitting a GET request to https://api.nsone.net/v1/monitoring/jobtypes. | block | n/a | no |

The "Config and Rule blocks" are dependent on the job_type i.e. if the job_type is dns then use the "Config block - dns". See examples above on how to use the rule block.

Config block - tcp
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| host | IP address or hostname to connect to | `string` | n/a | yes |
| port | TCP port to connect to on host | `number` | n/a | yes |
| response_timeout | Timeout (in ms) after connecting to wait for output | `number` | 1000 | no |
| ipv6 | Attempt to send/receive protocol data via IPv6 | `bool` | false | no |
| send | A string to send to the host upon connecting. String escapes (e.g. '\\n') are allowed | `string` | n/a | no |
| connect_timeout | Timeout (in ms) before we give up trying to connect | `number` | 2000 | no |
| ssl | Attempt to negotiate an SSL connection before sending/receiving protocol data | `bool` | false | no |
| tls_add_verify | When connecting over TLS, validate server certificate | `bool` | false | no |

Rule block - tcp
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| comparison | The type of comparison (comparator) used to match the value to the returned value from the server. | `string` | n/a | yes |
| key | The key use for the comparison: output, connect | `string` | n/a | yes |
| key - output | Output received from the connection, if any. Comparators: "contains" | `string` | n/a | yes |
| key - connect | Time (in ms) for the connection to open. Comparators: "<", ">", "<=",">=","==","!=" | `number` | n/a | yes |
| value | The value of the key by which to compare i.e. 200 | `string` | n/a | yes |

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Config block - ping
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| host | IP address or hostname to test using ICMP echo packets | `string` | n/a | yes |
| count | Number of ICMP echo packets to send.  More take longer, but provide better RTT and packet loss statistics | `number` | 4 | no |
| interval | Minimum time (in ms) to wait between sending each ICMP packet.  If less than the response time for an echo request, we will send the next packet immediately upon receiving a response | `number` | 0 | no |
| timeout | Timeout (in ms) before we mark host failed | `number` | 2000 | no |
| IPv6 | Attempt to send/receive protocol data via IPv6 | `bool` | false | no |

Rule block - ping
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| comparison | The type of comparison used to match the value to the returned value from the server. | `string` | n/a | yes |
| key | The key use for the comparison: rtt, loss | `string` | n/a | yes |
| key - rtt | Average round trip time (in ms) of returned pings. Comparators: "<", ">", "<=",">=","==","!="  | `number` | n/a | yes |
| key - loss | Percentage of ICMP echo packets with no response (timed out). Comparators: "<", ">", "<=",">=","==","!=" | `number` | n/a | yes |
| value | Value by which to compare i.e. 200 | `string` | n/a | yes |

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Config block - http
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| url | URL to query, i.e. https://ns1.com | `string` | n/a | yes |
| virtual_host | FQDN for name-based virtual hosts, used as server_name in TLS handshake and/or Host header value | `string` | "" | no |
| method | Valid methods are HEAD, GET and POST | `string` | "GET" | no |
| user_agent | Describes the text provided in the User-Agent request header String escapes (e.g. ', \\n') are allowed | `string` | "NS1 HTTP Monitoring Job" | no |
| authorization | You can provide a bearer token or api key using this header String escapes (e.g. ', \\n') are allowed | `string` | "" | no |
| follow_redirect | Follows http redirects when response presents one when enabled | `bool` | false | no |
| connect_timeout | Timeout (in seconds) sending query to wait for output | `number` | 5 | no |
| idle_timeout | Timeout (in seconds) waiting for expected data before closing the connection | `number` | 3 | no |
| tls_add_verify | When connecting over TLS, validate server certificate","required":false,"shortdesc":"Add TLS Verify | `bool` | false | no |
| ipv6 | Attempt to send/receive protocol data via IPv6 | `bool` | false | no |

Rule block - http
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| comparison | The type of comparison used to match the value to the returned value from the server. | `string` | n/a | yes |
| key | The key use for the comparison: body, status_code | `string` | n/a | yes |
| key - body | String match over the response body. Comparison that can be used is: "contains" | `string` | n/a | yes |
| key - status_code | HTTP Response Status Code comparison. Comparisons that can be used: "<", ">", "<=",">=","==","!=" | `number` | n/a | yes |
| value | Value by which to compare i.e. 200 | `string` | n/a | yes |

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Config block - dns
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain | The domain name to query | `string` | n/a | yes |
| host | IP address or hostname of the nameserver to query, e.g. 8.8.8.8 | `string` | n/a | yes |
| response_timeout | Timeout (in ms) after sending query to wait for output | `number` | 2000 | no |
| ipv6 | Attempt to send/receive protocol data via IPv6 | `bool` | false | no |
| type | DNS record type to query: A, CNAME, TXT, etc... | `String` | "A"" | no |
| port | DNS port to query on host | `number` | 53 | no |

Rule block - dns
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| comparison | The type of comparison used to match the value to the returned value from the server. | `string` | n/a | yes |
| key | The key use for the comparison: body, status_code | `string` | n/a | yes |
| key - num_records | Number of records in the ANSWER section of the DNS response. Comparators: "<", ">", "<=",">=","==","!=" | `number` | n/a | yes |
| key - rdata | RDATA of records in the DNS response. Comparators: "contains" | `ZZ` | n/a | yes |
| key - rtt | Average response time (in ms) of DNS responses. Comparators: "<", ">", "<=",">=","==","!=" | `number` | n/a | yes |
| value | Value by which to compare i.e. 200 | `string` | n/a | yes |

*Data source and data feed
 - These modules are transparent to the deployment code but are required for the monitor to work properly
 - These are used to link the monitor to `UP` status and use the monitor as a health-check
 - Data source allows the the monitor to have a connector and can be from platforms other than NS1 i.e. Thousandeyes, etc
 - For NS1 data source it is: nsone_monitoring
 - Data feed allows the data source to use the connector with the `UP` status in the filter chain, it returns the values and configuration of the data source


*Notification list
 - This module is transparent to the deployment code but is required for the monitor to work properly
 - Notification list must be created and bound to the monitor so that any changes to the monitor will send notification to `UP` status and have it changed accordingly to the monitor health-check

## Outputs

| Name | Description |
|------|-------------|
| tcp_id | The output ID for the tcp monitoring feed |
| http_id | The output ID for the http monitoring feed |
| ping_id | The output ID for the ping monitoring feed |
| dns_id | The output ID for the DNS monitoring feed |

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.12 and above
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v2.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Network Admin: `roles/compute.networkAdmin`

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Compute Engine API: `compute.googleapis.com`

## References

terraform registry: https://registry.terraform.io/providers/ns1-terraform/ns1/latest/docs/resources/monitoringjob <br>
Github: HTTPS_LINK <br>
NS1 docs: https://ns1.com/api#monitoring-jobs <br>
API calls in other languages: https://www.pulumi.com/registry/packages/ns1/api-docs/monitoringjob/ <br>
