provider "google" {
  credentials = file("./scegkey.json")
  project     = "advance-wavelet-398416"
  region      = "us-central1"  # Your desired region
}

resource "google_app_engine_application" "app" {
  location_id = "us-central"  # Your desired location
  project     = "advance-wavelet-398416"
}

resource "google_project_service" "service" {
  project     = "advance-wavelet-398416"
  service     = "appengineflex.googleapis.com"

  disable_dependent_services = false
}

resource "google_app_engine_flexible_app_version" "appengine_flexible_automatic_scaling" {
  # ... (your configuration details)

  runtime            = var.runtime

  liveness_check {
    path             = var.liveness_path
  }
 
  readiness_check {
    path             = var.readiness_path
  }

  service            = var.service

  version_id         = "v1"
  
  env_variables      = var.env_variables

  dynamic "handlers" {
    for_each = var.handlers == null ? [] : var.handlers
    content {
      dynamic "script" {
        for_each = handlers.value.script == null ? [] : list(handlers.value.script)
        content {
          script_path = script.value.script_path
        }
      }

      dynamic "static_files" {
        for_each = handlers.value.static_files == null ? [] : list(handlers.value.static_files)
        content {
        }
      }
    }
  }

  dynamic "network" {
    for_each = var.network[*]
    content {
      name = network.value.name
    }
  }

  dynamic "resources" {
    for_each = var.resources[*]
    content {
      cpu       = resources.value.cpu
      disk_gb   = resources.value.disk_gb
      memory_gb = resources.value.memory_gb

      dynamic "volumes" {
        for_each = resources.value.volumes == null ? [] : list(resources.value.volumes)
        content {
          name        = volumes.value.name
          volume_type = volumes.value.volume_type
          size_gb     = volumes.value.size_gb
        }
      }
    }
  }

  dynamic "api_config" {
    for_each = var.api_config == null ? [] : list(var.api_config)
    content {
      script = var.api_config[api_config.key]["script"]
    }
  # Define more API configurations here
  }

deployment {

  zip {
      source_url = "https://storage.googleapis.com/{name_bucket-1}/{test1}"
    }

    dynamic "files" {
      for_each = var.files == null ? [] : list(var.files)
      content {
        name       = var.files[files.key]["name"]
        source_url = var.files[files.key]["source_url"]
      }
    }

    dynamic "container" {
      for_each = var.container == null ? [] : list(var.container)
      content {
        image = var.container[container.key]["image"]
      }
    }

    dynamic "cloud_build_options" {
      for_each = var.cloud_build_options == null ? [] : list(var.cloud_build_options)
      content {
        app_yaml_path = var.cloud_build_options[cloud_build_options.key]["app_yaml_path"]
      }
    }
}

dynamic "endpoints_api_service" {
    for_each = var.endpoints_api_service == null ? [] : list(var.endpoints_api_service)
    content {
      name = var.endpoints_api_service[endpoints_api_service.key]["name"]
    }
  }

  dynamic "entrypoint" {
    for_each = var.entrypoint[*]
    content {
      shell = entrypoint.value.shell
    }
  }

  automatic_scaling {
    cool_down_period = "120s"
    cpu_utilization {
      target_utilization = 0.5
    }
  }
  noop_on_destroy = var.noop_on_destroy
  service_account = "advance-wavelet-398416@appspot.gserviceaccount.com"
}
