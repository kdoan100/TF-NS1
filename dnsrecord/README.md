# terraform-ns1-record

Brief description for this module

## Usage

Basic usage of this module is as follows:

```hcl

# Basic A record
module "terraform-test" {
  source = "../../dnsrecord"

  zone   = "ns1.fiservapis.com"
  domain = "terraform-test.ns1.fiservapis.com"
  type   = "A"
  ttl    = 3600

  answers = [
    {
      name = "1.1.1.1"
      up   = true
    }
  ]
}

# Basic CNAME record
module "terraform-test" {
  source = "../../dnsrecord"

  zone   = "ns1.fiservapis.com"
  domain = "terraform-test.ns1.fiservapis.com"
  type   = "CNAME"
  ttl    = 3600

  answers = [
    {
      name = "00a67e376f644922b4d8584970be371e.v1.radwarecloud.net"
      up   = true
    }
  ]
}


# This example creates a record with multiple answers nested in groups, monitor (health-checks), geotarget regional and weighted shuffle
module "terraform-test" {
  source = "../../dnsrecord"

  zone   = "ns1.fiservapis.com"
  domain = "terraform-test.ns1.fiservapis.com"
  type   = "A"
  ttl    = 60

  groups = [
    {
      name   = "group1"
      weight = 0
    },
    {
      name   = "group2"
      weight = 1
    }
  ]

  answers = [
    {
      name      = "1.1.1.1"
      group     = "group1"
      georegion = "US-CENTRAL"
      up        = "{\"feed\":\"74dec64904f3c521eb229feb\"}"
    },
    {
      name      = "2.2.2.2"
      group     = "group1"
      georegion = "EUROPE"
      up        = "{\"feed\":\"3728f56666b082092250a99d\"}"
    },
    {
      name      = "3.3.3.3"
      group     = "group1"
      georegion = "SOUTH-AMERICA"
      up        = "{\"feed\":\"ab4bb65f4f9af893a48262b5\"}"
    },
    {
      name      = "4.4.4.4"
      group     = "group1"
      georegion = "ASIAPAC"
      up        = "{\"feed\":\"9e4b0829d56ceb15d3c2588c\"}"
    },
    {
      name   = "10.10.10.10"
      group  = "group2"
      up     = "{\"feed\":\"${module.mndns-test.dns_id}\"}"
    }
  ]

  filters = [
    {
     filter = "up"
    },
    {
     filter = "weighted_shuffle"
    },
    {
     filter = "select_first_region"
    },
    {
     filter = "geotarget_regional"
    },
    {
     filter = "select_first_n"
     N      = 1
    },
  ]
}

```
## Notes

Note: 
 - jq is a json formatter and needs to be installed to make the output user readable
 - the $NSONE_API_KEY is obtained from the API keys on NS1. We are using the key from "SA - Terraform"

Get all the values for the meta type <br>
  curl -X GET -H "X-NSONE-Key: $NSONE_API_KEY" https://api.nsone.net/v1/metatypes | jq<br>

Get the feed ID for a monitor so that it can be used in the "UP" status for an answer. The feed ID can then be used for the "UP" status as a health-check, this is the manual method to retrive and use the feed id<br>
  curl -X GET -H "X-NSONE-Key: $NSONE_API_KEY" https://api.nsone.net/v1/monitoring/jobs | jq | grep -B 12 my-healthcheck-url | grep "\"id\":"<br>

Get the information regarding all filter chains<br>
  curl -X GET -H "X-NSONE-Key: $NSONE_API_KEY" https://api.nsone.net/v1/filtertypes | jq<br>

Get the country, state, province, subdivision code used in the "geo" filter chains<br>
  curl -X GET -H "X-NSONE-Key: $NSONE_API_KEY" https://api.nsone.net/v1/metatypes/geo | jq<br>

## Inputs

**Main block** 
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| zone | The DNS domain for the record. Cannot have leading or trailing dots. | `string` | n/a | yes |
| domain | The FQDN of the record. Cannot have leading or trailing dots. | `string` | n/a | yes |
| type | The records' RR type: A, CNAME, TXT, etc | `string` | n/a | yes |
| ttl | The records' time to live (in seconds) | `number` | 3600 | no |
| up | The "UP" status for ungrouped answers.  | `bool` | null | no |
| regions | One or more "regions" for the record. These are really just groupings based on metadata, and are called "Answer Groups" in the NS1 UI, but remain regions here for legacy reasons. See below* | block | n/a | no |
| answers | One or more NS1 answers for the records' specified type. See below* | block | n/a | yes |
| filters | One or more NS1 filters for the record(order matters). See below* | block | n/a | no |

**Regions block** 
Note: regions must be sorted lexically by their "name" argument in the Terraform configuration file, otherwise Terraform will detect changes to the record when none actually exist.
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the region (or Answer Group). | `string` | n/a | yes |
| weight | Meta field - The weight for a weighted round robin response when used with "weighted shuffle" filter | `number` | n/a | no |

**Answers block** 
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| answer |  Space delimited string of RDATA fields dependent on the record type. | `string` | n/a | yes |
| region | The name of the group as defined by the "name" in the Region Block | `string` | n/a | no |
| up | Meta field for `UP` filter chain- The UP status for the answer, can be used statically as UP/DOWN using true/false or as a feed from a monitor | `bool` | n/a | yes |
| georegion | Meta field for the `geotarget_regional` and `geofence_regional` filter chain - the region that request is coming from that the answer will respond to when using the geotarget regional filter. Regions list: US-EAST, US-CENTRAL, US-WEST, EUROPE, ASIAPAC, SOUTH-AMERICA, AFRICA | `string` | n/a | no |
| weight | Meta field for the `weighted_shuffle` and `weighted_sticky` filter chain - The weight for a weighted round robin response when used with "weighted shuffle" filter | `number` | n/a | no |
| low_watermark | Meta field for `shed_load` filter chain -  | `number` | n/a | no |
| high_watermark | Meta field for `shed_load` filter chain -  | `number` | n/a | no |
| loadavg | Meta field for `shed_load` filter chain -  | `number` | n/a | no |
| connections | Meta field for `shed_load` filter chain -  | `number` | n/a | no |
| requests | Meta field for `shed_load` filter chain -  | `number` | n/a | no |
| cost | Meta field for `cost` filter chain -  | `type` | 0 | no |
| country | Meta field for `geofence_country` and `geotarget_country` filter chain - for countries around the world | `string` | n/a | no |
| us_state | Meta field for `geofence_country` and `geotarget_country` filter chain - for US states | `string` | n/a | no |
| ca_province | Meta field for `geofence_country` and `geotarget_country` filter chain - for Canadian provinces | `string` | n/a | no |
| subdivisions | Meta field for `geofence_country` and `geotarget_country` filter chain - same as `country` except the breakout is slightly different i.e. subdivisions in Africa, Anartica, Asia, Europe, North America, Oceania and South America | `string` | n/a | no |
| additional_metadata | Meta field for `additional_metadata` filter chain - used to add values in the TXT field - has to be a JSON format | `string` | n/a | no |
| priority | Meta field for `priority` filter chain - the priority for a particular answer, highest number is highest priority | `number` | n/a | no |

**Filters block** 
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| filter | The type of filter to be added. See the "Filter Types" block below for a list | `string` | n/a | yes |
| config | The configs for each filter type. See the list for each type in the "Filter Types" block below. Some filter type do not have any config | `varies` | n/a | no |

**Filter types** - some filter types have corresponding `config` and `answers` which are described in the `Filter type config` and `Answers block` respectively
| Name | Config | Answers | Description |
|------|--------|---------|:-----------:|
| additional_metadata | n/a | additional_metadata | This filter adds TXT records to the "additionals" section of the DNS response, based on the `additional_metadata` metadata present on the record's answers. The names of the additional records match the position in the list of the actual answers they correspond to. Therefore this filtershould always be at the end of the filter chain so that the order of the metadata added matches the order of the actual answers returned. The values for this metadata has to be in JSON format - see exanple in the "Usage" section for format|
| cost | eliminate | cost | his filter examines the `cost` metadata field for all answers and takes action according to the selected configuration. It can be used to always select the least expensive answer or answers, or combined with `PULSAR_STABILIZE` to always select the least expensive option as long as it is within a user defined threshold of the best performing option.By default, this filter will order all answers from lowest to highest cost. |
| geofence_country | remove_no_location | country, us_state, ca_province, subdivisions | This filter eliminates answers with country, country sub-division, State or Province metadata that do esn't match the requestor's location. It examines the `country`, `subdivisions`, `us_state`, and `ca_province` metadata fields, starting with the most granular location, to get the allowed locations for your answers. A geo-IP database is used to determine the location of the requester based on the source IP of the end user if EDNS Client Subnet is activated and supported by the recursive resolver, or the source IP of the recursive resolver otherwise. If the requester's location does not match the metadata of any answers, then the system will return all answers with no country, country sub-division, State nor Province. If there are no such answers, then NO ERROR, NO ANSWER will be returned. If you want to fence specific US states or CA provinces, you should not add US or CA to the country list for those answers. See the "Notes" section on how to get the country, state, province and subdivision codes |
| geofence_regional | remove_no_georegion | georegion | This filter eliminates answers in different geographical regions than the requester.  It examines the `georegion` metadata field to get the allowed region(s) for your answers, and uses a geo-IP d  atabase to determine the region of the requester.  If a `georegion` value is set for an answer  , and the requester is not in one of the specified geographic regions, the answer will not be returned.  Optionally, if no `georegion` value is set for an answer, this filter will not eliminate the a  nswer.  For example, if your record has one answer with a `georegion=[US-EAST, EUROPE]`, and a  nother answer with no value for `georegion`, a requester in `US-EAST` will receive both answers; a requester in `ASIAPAC` will receive only the second answer.  If instead you want the requester in `US-EAST` to receive only the first answer, enable the "Remove answers without `georegion` on match" option. |
| geotarget_country | n/a | country, us_state, ca_province, subdivisions | This filter sorts answers by distance to location of the requester based on the country(s), country sub-division(s), US state(s), and/or Canadian province(s) metadata assigned to each answer. The filter examines the `country`, `subdivisions`, `us_state`, and `ca_province` metadata fields, starting with the most granular location, to get locations for your answers. A geo-IP data  base is used to determine the location of the requester based  on the source IP of the request if EDNS Client Subnet is activated and supported by the recursive resolver, or the source IP of the recursive resolver otherwise.  You need not assign individual answers for every country, subdivision, state, and province.  If the requester is in a location for which there is no answer with matching metadata, they are given the closest existing answer based on geographical distance.  For example, if you set `country` to `JP, HK` (Japan and Hong Kong) for one of your answers, and `country` to `US, CA` (USA and Canada) for the other, a user in Taiwan will be directed to the former since Taiwan is closer to Hong Kong. You can use this filter with another one like `SELECT_FIRST_N` to send the user to the closest answer.  If you have multiple answers in the same location, you may want to first `SHUFFLE` your answers to randomly pick one of the closest answers. |
| geotarget_regional | n/a | georegion | This filter sorts answers by distance to the IP address of the requester, by assigning answers to one or more coarse geographical regions and determining which region the requester is in.  The filter examines the `georegion` metadata field to get the location of your answers, and uses a geo-IP database to determine the region of the requester. You need not assign individual answers for every region: if the requester is in a region without a regional answer, they are given the closest existing regional answer.  For example, if there are answers only in `US-EAST` and `ASIAPAC`, but the requester is in `US-CENTRAL`, they will receive the `US-EAST` answer.  You can use this filter with another one like `SELECT_FIRST_N` to send the user to the closest answer. If you have multiple answers in the same location, you may want to first `SHUFFLE` your answers to randomly pick one of the closest ones. |
| priority | eliminate | priority | This filter examines the `priority` metadata field for all answers and takes action according to the selected configuration. This filter will order all answers from highest (e.g. priority: 1) to lowest priority. It can be used to always select a group of available answers, or to implement failover in conjunction wi  th filters like `UP`. |
| select_first_n | N | n/a | This filter eliminates all but the first `N` answers from the list.  Use this with filters like `SHUFFLE` or `WEIGHTED_SHUFFLE` to implement round robin or weighted round robin. |
| select_first_region | n/a | n/a | This filter keeps only the answers that are in the same region as the first answer. This filter is most useful with the output of filters like `STICKY_REGION` that group a nswers together by region. |
| shuffle | n/a | n/a | This filter randomly sorts the answers. You can use it in conjunction with a filter like `SELECT_FIRST_N` to return a subset of the available answers at random. |
| shed_load | metric | low_watermark, high_watermark, loadavg, connections, requests | This filter "sheds" traffic to answers based on load, using one of several load metrics. You must set values for `low_watermark`, `high_watermark`, and the configured load metric, for each answer you intend to subject to load shedding. Normally, you will configure a data feed to regularly update the load metrics associated with your answers. This filter will do nothing if load is below the configured `low watermark`. If load is above the configured `high watermark` for an answer, the answer will be eliminated. If load is between the low and high watermarks, the answer will be eliminated with probability that increases as the load approaches the high watermark. The result is that an answer will be returned relatively fewer times (as a percentage of requests) as load increases. |
| sticky | sticky_by_network | n/a | This filter sorts answers uniquely depending on the IP address of the requester, however, the stickiness is applied to the subnet of the requester rather than the IP.  The same requester always gets the same ordering of answers.  You can use this filter with another one like SELECT_FIRST_N to always give a user the same answer.  Need to combine this with weighting behavior?  Use WEIGHTED_STICKY. |
| sticky_region | sticky_by_network | n/a | This filter first sorts regions uniquely depending on the IP address of the requester, and then groups all answers together by region.  The same requester always gets the same ordering of regions, but answers within each region may be in any order.  You can use this filter with another one like `SELECT_FIRST_REGION` to always give a user answers from the same region.  Note that this filter does **not** do any geotargeting or GSLB: it sorts regions randomly but consistently for each user. Answers with no region defined are considered to be in the same (empty) region. |
| up | n/a | up | This filter eliminates all answers where the `up` metadata field is not `true` (or `"1"`). This includes where the `up` metadata field is unset. If all answers would be eliminated by this filter then the filter is bypassed and instead all answers are returned. |
| weighted_shuffle | n/a | weight | This filter examines the `weight` metadata field for all available answers, and reorders the answers by picking them randomly based on their weights until all answers have been randomly reordered. Answers with higher weight will be "first" more often. You can use this filter in conjunction with a filter like `SELECT_FIRST_N` to return one or more answers with probability proportional to their weights. Need to combine this with "sticky" behavior? Use `WEIGHTED_STICKY` |
| weighted_sticky | sticky_by_network | weight | This filter is a special purpose combination of the behaviors of `STICKY` and `WEIGHTED_SHUFFLE` that cannot be achieved by combining the individual filters.  Answers are shuffled randomly based on the `weight` metadata field, but the shuffling is consistently the same for the same requester IP address.  Note that changing the set of answers\n or their weights results in a reshuffling. |

**Filter type config**
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| metric | Used with `shed_load` filter - Metadata field to use with low/high watermark to determine load to shed. Values are: loadavg, connections, requests  | `string` | "loadavg" | no |
| sticky_by_network | Used with `sticky`, `weighted_sticky` and `sticky_region` filter -All requests in the same /24 (IPv4) or /56 (IPv6) will receive the same output. Useful to help ensure users load balanced across multiple recursors get the same answer. | `checkbox` | 0 | no |
| eliminate | Used with `cost` and `priority` filter - Selects only the answer or answers with the lowest cost.| `checkbox` | 0 | no |
| N | Used with `select_first_n` filter - Number of answers to keep| `number` | 1 | no |
| remove_no_location | Used with `geofence_country` filter - If any answers have a location metadata matching therequester's location, then eliminate all answers whose metadata doesn't match the requester's location. If no answers have metadata that matches the requester's location, return answers with no location.| `checkbox` | 0 | no |
| remove_no_georegion | Used with `geofence_regional` filter - If any answers have a georegion matching the requester, then eliminate all answers with no georegion; and if no answers match the requester, return answers with no georegion as fallbacks | `checkbox` | 0 | no |

## Outputs

Outputs are not described in the provider's API.

## References

terraform registry: https://registry.terraform.io/providers/ns1-terraform/ns1/latest/docs/resources/record <br>
Github: HTTPS_LINK <br>
NS1 API docs: https://ns1.com/api?docId=2185 <br>
NS1 Filter Chain: https://help.ns1.com/hc/en-us/articles/360020683013-About-the-NS1-Filter-Chain <br>
NS1 Filter Chain information: https://help.ns1.com/hc/en-us/sections/16110171999251-Filters <br>
