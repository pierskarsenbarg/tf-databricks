terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
}

locals {
  resource_regex            = "(?i)subscriptions/(.+)/resourceGroups/(.+)/providers/Microsoft.Databricks/workspaces/(.+)"
  subscription_id           = data.azurerm_client_config.current.subscription_id
  resource_group            = ""
  databricks_workspace_name = ""
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  databricks_workspace_host = data.azurerm_databricks_workspace.this.workspace_url
  databricks_workspace_id   = data.azurerm_databricks_workspace.this.workspace_id
}

data "azurerm_databricks_workspace" "this" {
  name                = local.databricks_workspace_name
  resource_group_name = local.resource_group
}

provider "databricks" {
  host = local.databricks_workspace_host
}

provider "databricks" {
  alias      = "accounts"
  host       = "https://accounts.azuredatabricks.net"
  account_id = ""
}

resource "databricks_catalog" "sandbox" {
  name = "sandbox"
  comment = "this catalog is managed by terraform"
  properties = {
    purpose = "testing"
  }
  depends_on = [databricks_metastore_assignment.default_metastore]
}

resource "databricks_grants" "sandbox" {
  catalog = databricks_catalog.sandbox.name
  grant {
    principal  = "Data Scientists"
    privileges = ["USE_CATALOG", "CREATE"]
  }
  grant {
    principal  = "Data Engineers"
    privileges = ["USE_CATALOG"]
  }
}

resource "databricks_schema" "things" {
  catalog_name = databricks_catalog.sandbox.id
  name         = "things"
  comment      = "this database is managed by terraform"
  properties = {
    kind = "various"
  }
}

resource "databricks_schema" "things_2" {
  catalog_name = databricks_catalog.sandbox.id
  name         = "things_2"
  comment      = "this database is managed by terraform"
  properties = {
    kind = "various"
  }
}

resource "databricks_grants" "things" {
  schema = databricks_schema.things.id
  grant {
    principal  = "Data Engineers"
    privileges = ["USE_SCHEMA"]
  }
}

resource "databricks_grants" "things_2" {
  schema = databricks_schema.things_2.id
  grant {
    principal  = "Data Engineers"
    privileges = ["USE_SCHEMA"]
  }
}
