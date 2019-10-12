# Taken from module https://github.com/traveloka/terraform-aws-waf-owasp-top-10-rules

resource "aws_wafregional_sql_injection_match_set" "owasp_01_sql_injection_set" {

  name = "${lower(var.service_name)}-owasp-01-detect-sql-injection"

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "URI"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "HEADER"
      data = "Authorization"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "HTML_ENTITY_DECODE"

    field_to_match {
      type = "HEADER"
      data = "Authorization"
    }
  }
}

resource "aws_wafregional_rule" "owasp_01_sql_injection_rule" {
  depends_on = ["aws_wafregional_sql_injection_match_set.owasp_01_sql_injection_set"]

  name        = "${lower(var.service_name)}-owasp-01-mitigate-sql-injection"
  metric_name = "${lower(var.service_name)}OWASP01MitigateSQLInjection"

  predicate {
    data_id = "${aws_wafregional_sql_injection_match_set.owasp_01_sql_injection_set.id}"
    negated = "false"
    type    = "SqlInjectionMatch"
  }
}


resource "aws_wafregional_web_acl" "acl" {
  name = "BlockSQLInjection"
  metric_name = "${lower(var.service_name)}OWASP01MitigateSQLInjection"
  default_action {
    type = "ALLOW"
  }
  rule {
    action {
      type = "BLOCK"
    }
    priority = 1
    rule_id = "${aws_wafregional_rule.owasp_01_sql_injection_rule.id}"
  }
}


