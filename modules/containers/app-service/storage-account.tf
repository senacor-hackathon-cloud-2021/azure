resource "azurerm_storage_account" "this" {
  name                     = replace(local.full_name, "/[^a-z0-9]+/", "")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.common_tags
}

resource "azurerm_storage_container" "this" {
  name                  = "${local.full_name}-files"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

locals {
  local_file_path = "${path.module}/files"

  file_types = {
    ".txt"   = "text/plain; charset=utf-8"
    ".html"  = "text/html; charset=utf-8"
    ".css"   = "text/css; charset=utf-8"
    ".js"    = "application/javascript"
    ".gif"   = "image/gif"
    ".jpeg"  = "image/jpeg"
    ".jpg"   = "image/jpeg"
    ".png"   = "image/png"
    ".svg"   = "image/svg+xml"
    ".webp"  = "image/webp"
    ".weba"  = "audio/webm"
    ".webm"  = "video/webm"
    ".3gp"   = "video/3gpp"
    ".3g2"   = "video/3gpp2"
    ".pdf"   = "application/pdf"
    ".swf"   = "application/x-shockwave-flash"
    ".atom"  = "application/atom+xml"
    ".rss"   = "application/rss+xml"
    ".ico"   = "image/vnd.microsoft.icon"
    ".jar"   = "application/java-archive"
    ".ttf"   = "font/ttf"
    ".otf"   = "font/otf"
    ".eot"   = "application/vnd.ms-fontobject"
    ".woff"  = "font/woff"
    ".woff2" = "font/woff2"
  }
}

resource "azurerm_storage_blob" "content" {
  for_each = fileset(local.local_file_path, "**")

  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.this.name

  name         = each.key
  type         = "Block"
  source       = "${local.local_file_path}/${each.key}"
  content_type = lookup(local.file_types, replace(each.key, "/.*(\\.[^.]+$)/", "$1"), "application/octet-stream")
  content_md5  = filemd5("${local.local_file_path}/${each.key}")
}
