locals {
  metric_name = "CpuPercentage"
  time_grain  = "PT1M"
  time_window = "PT3M"
}

resource "azurerm_monitor_autoscale_setting" "this" {
  name                = "${local.full_name}-autoscale"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  target_resource_id  = azurerm_app_service_plan.this.id

  profile {
    name = "${local.full_name}-default"

    capacity {
      default = 1
      minimum = 1
      maximum = var.app_service_plan_max_scale
    }

    rule {
      metric_trigger {
        metric_name        = local.metric_name
        metric_resource_id = azurerm_app_service_plan.this.id
        time_grain         = local.time_grain
        statistic          = "Min"
        time_window        = local.time_window
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = local.metric_name
        metric_resource_id = azurerm_app_service_plan.this.id
        time_grain         = local.time_grain
        statistic          = "Min"
        time_window        = local.time_window
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}
