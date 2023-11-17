resource "ns1_monitoringjob" "monitor_tcp" {
  count         = var.job_type == "tcp" ? 1 : 0
  name          = var.name
  active        = var.active
  regions       = var.regions
  job_type      = var.job_type
  frequency     = var.frequency
  rapid_recheck = var.rapid_recheck
  policy        = var.policy
  mute          = var.mute

  notify_delay    = var.notify_delay
  notify_repeat   = var.notify_repeat
  notify_failback = var.notify_failback
  notify_regional = var.notify_regional
  notify_list     = ns1_notifylist.notifylist_tcp[0].id
  notes           = var.notes

  config = {
    host            = var.host
    port            = var.port
    ipv6            = var.ipv6
    send            = var.send
    connect_timeout = var.connect_timeout
    ssl             = var.ssl
    tls_add_verify  = var.tls_add_verify
  }

  rules {
    value      = var.value
    comparison = var.comparison
    key        = var.key
  }
}

resource "ns1_monitoringjob" "monitor_ping" {
  count         = var.job_type == "ping" ? 1 : 0
  name          = var.name
  active        = var.active
  regions       = var.regions
  job_type      = var.job_type
  frequency     = var.frequency
  rapid_recheck = var.rapid_recheck
  policy        = var.policy
  mute          = var.mute

  notify_delay    = var.notify_delay
  notify_repeat   = var.notify_repeat
  notify_failback = var.notify_failback
  notify_regional = var.notify_regional
  notify_list     = ns1_notifylist.notifylist_ping[0].id
  notes           = var.notes

  config = {
    host     = var.host
    count    = var.ping_count
    interval = var.interval
    timeout  = var.timeout
  }

  rules {
    value      = var.value
    comparison = var.comparison
    key        = var.key
  }
}

resource "ns1_monitoringjob" "monitor_http" {
  count         = var.job_type == "http" ? 1 : 0
  name          = var.name
  active        = var.active
  regions       = var.regions
  job_type      = var.job_type
  frequency     = var.frequency
  rapid_recheck = var.rapid_recheck
  policy        = var.policy
  mute          = var.mute

  notify_delay    = var.notify_delay
  notify_repeat   = var.notify_repeat
  notify_failback = var.notify_failback
  notify_regional = var.notify_regional
  notify_list     = ns1_notifylist.notifylist_http[0].id
  notes           = var.notes

  config = {
    url             = var.url
    virtual_host    = var.virtual_host
    method          = var.method
    user_agent      = var.user_agent
    authorization   = var.authorization
    follow_redirect = var.follow_redirect
    connect_timeout = var.connect_timeout_https
    idle_timeout    = var.idle_timeout
    tls_add_verify  = var.tls_add_verify
    ipv6            = var.ipv6
  }

  rules {
    value      = var.value
    comparison = var.comparison
    key        = var.key
  }
}

resource "ns1_monitoringjob" "monitor_dns" {
  count         = var.job_type == "dns" ? 1 : 0
  name          = var.name
  active        = var.active
  regions       = var.regions
  job_type      = var.job_type
  frequency     = var.frequency
  rapid_recheck = var.rapid_recheck
  policy        = var.policy
  mute          = var.mute

  notify_delay    = var.notify_delay
  notify_repeat   = var.notify_repeat
  notify_failback = var.notify_failback
  notify_regional = var.notify_regional
  notify_list     = ns1_notifylist.notifylist_dns[0].id
  notes           = var.notes

  config = {
    domain           = var.domain
    host             = var.host
    response_timeout = var.response_timeout
    ipv6             = var.ipv6
    type             = var.type
    port             = var.port
  }

  rules {
    value      = var.value
    comparison = var.comparison
    key        = var.key
  }
}


resource "ns1_datasource" "ns1_monitoring" {
  name       = "mn_${var.name}"
  sourcetype = "nsone_monitoring"
}

resource "ns1_datafeed" "datafeed_tcp" {
  count     = var.job_type == "tcp" ? 1 : 0
  name      = "fd_${var.name}"
  source_id = ns1_datasource.ns1_monitoring.id

  config = {
    jobid = ns1_monitoringjob.monitor_tcp[0].id
  }
}

resource "ns1_datafeed" "datafeed_http" {
  count     = var.job_type == "http" ? 1 : 0
  name      = "fd_${var.name}"
  source_id = ns1_datasource.ns1_monitoring.id

  config = {
    jobid = ns1_monitoringjob.monitor_http[0].id
  }
}

resource "ns1_datafeed" "datafeed_ping" {
  count     = var.job_type == "ping" ? 1 : 0
  name      = "fd_${var.name}"
  source_id = ns1_datasource.ns1_monitoring.id

  config = {
    jobid = ns1_monitoringjob.monitor_ping[0].id
  }
}

resource "ns1_datafeed" "datafeed_dns" {
  count     = var.job_type == "dns" ? 1 : 0
  name      = "fd_${var.name}"
  source_id = ns1_datasource.ns1_monitoring.id

  config = {
    jobid = ns1_monitoringjob.monitor_dns[0].id
  }
}

resource "ns1_notifylist" "notifylist_tcp" {
  count = var.job_type == "tcp" ? 1 : 0
  name  = "nl_${var.name}"

  notifications {
    type = "datafeed"
    config = {
      sourceid = ns1_datasource.ns1_monitoring.id
    }
  }
}

resource "ns1_notifylist" "notifylist_ping" {
  count = var.job_type == "ping" ? 1 : 0
  name  = "nl_${var.name}"

  notifications {
    type = "datafeed"
    config = {
      sourceid = ns1_datasource.ns1_monitoring.id
    }
  }
}
resource "ns1_notifylist" "notifylist_http" {
  count = var.job_type == "http" ? 1 : 0
  name  = "nl_${var.name}"

  notifications {
    type = "datafeed"
    config = {
      sourceid = ns1_datasource.ns1_monitoring.id
    }
  }
}

resource "ns1_notifylist" "notifylist_dns" {
  count = var.job_type == "dns" ? 1 : 0
  name  = "nl_${var.name}"

  notifications {
    type = "datafeed"
    config = {
      sourceid = ns1_datasource.ns1_monitoring.id
    }
  }
}
