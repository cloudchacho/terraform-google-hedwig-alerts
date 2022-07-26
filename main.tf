data "google_project" "current" {}

locals {
  title_suffix  = var.alerting_project != data.google_project.current.project_id ? format(" (%s)", data.google_project.current.name) : ""
  filter_suffix = var.alerting_project != data.google_project.current.project_id ? format(" project=\"%s\"", data.google_project.current.project_id) : ""
}

resource "google_monitoring_alert_policy" "high_message_alert" {
  project = var.alerting_project

  display_name = "${title(var.queue)}'s Hedwig queue message count too high${local.title_suffix}"
  combiner     = "OR"

  conditions {
    display_name = "${title(var.queue)}'s Hedwig queue message count too high${local.title_suffix}"

    condition_threshold {
      threshold_value = coalesce(var.queue_alarm_high_message_count_threshold, 5000) // Number of messages
      comparison      = "COMPARISON_GT"
      duration        = "300s" // Seconds

      filter = "metric.type=\"pubsub.googleapis.com/subscription/num_undelivered_messages\" resource.type=\"pubsub_subscription\" (resource.label.\"subscription_id\"=monitoring.regex.full_match(\"hedwig-${var.queue}-.*\") AND resource.labels.\"subscription_id\"!=\"hedwig-${var.queue}-dlq\")${local.filter_suffix}"

      aggregations {
        alignment_period     = "60s"
        cross_series_reducer = "REDUCE_NONE"
        per_series_aligner   = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.queue_high_message_count_notification_channels

  user_labels = var.labels
}

resource "google_monitoring_alert_policy" "no_activity_alert" {
  project = var.alerting_project

  display_name = "${title(var.queue)}'s Hedwig queue has no activity${local.title_suffix}"
  combiner     = "OR"

  conditions {
    display_name = "${title(var.queue)}'s Hedwig queue has no activity${local.title_suffix}"

    condition_absent {
      duration = "300s" // Seconds

      filter = "metric.type=\"pubsub.googleapis.com/subscription/streaming_pull_message_operation_count\" resource.type=\"pubsub_subscription\" (resource.label.\"subscription_id\"=monitoring.regex.full_match(\"hedwig-${var.queue}-.*\") AND resource.labels.\"subscription_id\"!=\"hedwig-${var.queue}-dlq\")${local.filter_suffix}"

      aggregations {
        alignment_period     = "60s"
        cross_series_reducer = "REDUCE_NONE"
        per_series_aligner   = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.queue_no_activity_notification_channels

  user_labels = var.labels
}

resource "google_monitoring_alert_policy" "dlq_alert" {
  project = var.alerting_project

  display_name = "${title(var.queue)}'s Hedwig DLQ is non-empty${local.title_suffix}"
  combiner     = "OR"

  conditions {
    display_name = "${title(var.queue)}'s Hedwig DLQ is non-empty${local.title_suffix}"

    condition_threshold {
      threshold_value = "0" // Number of messages
      comparison      = "COMPARISON_GT"
      duration        = "60s" // Seconds

      filter = "metric.type=\"pubsub.googleapis.com/subscription/num_undelivered_messages\" resource.type=\"pubsub_subscription\" resource.label.\"subscription_id\"=\"hedwig-${var.queue}-dlq\"${local.filter_suffix}"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_SUM"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.dlq_high_message_count_notification_channels

  user_labels = var.labels
}
