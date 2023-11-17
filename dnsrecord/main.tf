resource "ns1_record" "record" {
  zone   = var.zone
  domain = var.domain
  type   = var.type
  ttl    = var.ttl
  meta = {
    up = var.up
  }

  dynamic "regions" {
    for_each = var.groups
    content {
      name = regions.value.name
      meta = {
        weight = try(regions.value.weight, null)
      }
    }
  }

  dynamic "answers" {
    for_each = var.answers
    content {
      answer = answers.value.name
      region = try(answers.value.group, null)
      meta = {
        up                  = answers.value.up
        georegion           = try(answers.value.georegion, null)
        weight              = try(answers.value.weight, null)
        low_watermark       = try(answers.value.low_watermark, null)
        high_watermark      = try(answers.value.high_watermark, null)
        loadavg             = try(answers.value.loadavg, null)
        connections         = try(answers.value.connections, null)
        requests            = try(answers.value.requests, null)
        cost                = try(answers.value.cost, null)
        country             = try(answers.value.country, null)
        us_state            = try(answers.value.us_state, null)
        ca_province         = try(answers.value.ca_province, null)
        subdivisions        = try(answers.value.subdivisions, null)
        additional_metadata = try(answers.value.additional_metadata, null)
        priority            = try(answers.value.priority, null)
      }
    }
  }

  dynamic "filters" {
    for_each = var.filters
    content {
      filter = filters.value.filter
      config = {
        N                   = try(filters.value.N, null)
        metric              = try(filters.value.metric, null)
        sticky_by_network   = try(filters.value.sticky_by_network, null)
        eliminate           = try(filters.value.eliminate, null)
        remove_no_location  = try(filters.value.remove_no_location, null)
        sticky_by_network   = try(filters.value.sticky_by_network, null)
        remove_no_georegion = try(filters.value.remove_no_georegion, null)
      }
    }
  }
}
