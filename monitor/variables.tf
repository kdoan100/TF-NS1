variable "name" {
  description = "Name of the monitor"
  type        = string
}

variable "active" {
  description = "Indicates if the job is active or temporarily disabled"
  default     = true
  type        = bool
}

variable "regions" {
  description = "Region where the resource resides: `nrt` (APAC), `dal` (US-CENTRAL), `sin` (APAC), `sjc` (US-WEST), `lga` (US-EAST), `ams` (EMEA), `syd` (APAC), `gru` (LATAM), `lhr` (EMEA)"
  default     = null
  type        = list(string)
}

variable "job_type" {
  description = "The type of monitoring job to be run"
  type        = string
}

variable "frequency" {
  description = "The frequency, in seconds, at which to run the monitoring job in each region, 5s minimum"
  default     = 5
  type        = number
}

variable "rapid_recheck" {
  description = "If true, on any apparent state change, the job is quickly re-run after one second to confirm the state change before notification"
  default     = true
  type        = bool
}

variable "policy" {
  description = "The policy for determining the monitor's global status based on the status of the job in all regions: QUORUM, ALL, ONE"
  default     = "quorum"
  type        = string
}

variable "mute" {
  description = "turn on the notifications for the monitoring job"
  default     = false
  type        = bool
}

variable "notify_delay" {
  description = "The time in seconds after a failure to wait before sending a notification."
  default     = 3
  type        = number
}

variable "notify_repeat" {
  description = "The time in seconds between repeat notifications of a failed job."
  default     = 60
  type        = number
}

variable "notify_failback" {
  description = "If true, a notification is sent when a job returns to an up state."
  default     = true
  type        = bool
}

variable "notify_regional" {
  description = "If true, notifications are sent for any regional failure (and failback if desired), in addition to global state notifications."
  default     = false
  type        = bool
}

variable "notes" {
  description = "A description for the monitor"
  default     = null
  type        = string
}

#=========== Rule block =====================

variable "value" {
  description = "The returned value to compare the key to"
  default     = null
  type        = string
}

variable "comparison" {
  description = "The type of comparator: <, >, <=,>=,==,!="
  default     = null
  type        = string
}

variable "key" {
  description = "The key value to be used for comparison"
  default     = null
  type        = string
}

#=========== TCP block =====================

# connect_timeout variable is also shared with other blocks
variable "connect_timeout" {
  description = "Timeout (in ms) before we give up trying to connect"
  default     = 5000
  type        = number
}

# host variable is also shared with other blocks
variable "host" {
  description = "IP address or hostname to connect to"
  default     = ""
  type        = string
}

# ipv6 variable is also shared with other blocks
variable "ipv6" {
  description = "Attempt to send/receive protocol data via IPv6"
  default     = false
  type        = bool
}

# port variable is also shared with other blocks
variable "port" {
  description = "TCP port to connect to on host"
  default     = 443
  type        = number
}

variable "send" {
  description = "A string to send to the host upon connecting. String escapes (e.g. '\\n') are allowed"
  default     = null
  type        = string
}

variable "ssl" {
  description = "Attempt to negotiate an SSL connection before sending/receiving protocol data"
  default     = false
  type        = bool
}

# tls_add_verify variable is also shared with other blocks
variable "tls_add_verify" {
  description = "When connecting over TLS, validate server certificate"
  default     = false
  type        = bool
}

#=========== ping block =====================

variable "ping_count" {
  description = "Number of ICMP echo packets to send.  More take longer, but provide better RTT and packet loss statistics"
  default     = 4
  type        = number
}

variable "interval" {
  description = "Minimum time (in ms) to wait between sending each ICMP packet.  If less than the response time for an echo request, we will send the next packet immediately upon receiving a response"
  default     = 0
  type        = number
}

variable "timeout" {
  description = "Timeout (in ms) before we mark host failed"
  default     = 2000
  type        = number
}

#=========== http block =====================

variable "authorization" {
  description = "You can provide a bearer token or api key using this header String escapes (e.g. ', \\n') are allowed"
  default     = null
  type        = string
}

variable "follow_redirect" {
  description = "You can provide a bearer token or api key using this header String escapes (e.g. ', \\n') are allowed"
  default     = true
  type        = bool
}

variable "idle_timeout" {
  description = "Timeout (in seconds) waiting for expected data before closing the connection"
  default     = 3
  type        = number
}

variable "method" {
  description = "Valid methods are HEAD, GET and POST"
  default     = "GET"
  type        = string
}

variable "url" {
  description = "URL to query, i.e. https://ns1.com "
  default     = null
  type        = string
}

variable "user_agent" {
  description = "Describes the text provided in the User-Agent request header String escapes (e.g. ', \\n') are allowed"
  default     = "NS1 HTTP Monitoring Job"
  type        = string
}

variable "virtual_host" {
  description = "FQDN for name-based virtual hosts, used as server_name in TLS handshake and/or Host header value "
  default     = null
  type        = string
}

variable "connect_timeout_https" {
  description = "Timeout (in seconds) before we give up trying to connect"
  default     = 5
  type        = number
}

#=========== DNS block =====================

variable "domain" {
  description = "The domain name to query "
  default     = ""
  type        = string
}

variable "response_timeout" {
  description = "Timeout (in ms) after sending query to wait for output"
  default     = 2000
  type        = number
}

variable "type" {
  description = "DNS record type to query: A, CNAME, TXT, etc..."
  default     = "A"
  type        = string
}
