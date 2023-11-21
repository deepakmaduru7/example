variable "runtime" {
  description = "(Required; Default: python) The runtime that will be used by App Engine. Supported runtimes are: python27, python37, python38, java8, java11, php55, php73, php74, ruby25, go111, go112, go113, go114, nodejs10, nodejs12."
  type        = string
  default     = "python"

}

variable "service" {
  description = "(Required; Default: default) Name of the App Engine Service"
  type        = string
  default     = "default"

  validation {
    condition     = length(var.service) > 0 && length(var.service) < 63
    error_message = "The Service name can't be null and the length cannot exceed 63 characters."
  }
}

variable "liveness_path" {
  description = "(Required; Default `/liveness`) The request path."
  type        = string
  default     = "/liveness"
}

variable "readiness_path" {
  description = "(Required; Default `/readiness`) The request path."
  type        = string
  default     = "/readiness"
}

variable "env_variables" {
  description = "(Optional) Environment variables to be passed to the App Engine service."
  type        = map(any)
  default     = null
}

variable "handlers" {
  description = "(Optional) An ordered list of URL-matching patterns that should be applied to incoming requests. The first matching URL handles the request and other request handlers are not attempted."
  type = list(object({
    
    script = object({
      script_path = string
    })
    static_files = object({
      
    })
  }))

  validation {
    condition     = var.handlers != null ? ! contains([for security_level in var.handlers[*].security_level : (security_level == null || contains(["SECURE_DEFAULT", "SECURE_NEVER", "SECURE_OPTIONAL", "SECURE_ALWAYS"], security_level)) if security_level != null], false) : true
    error_message = "Security level field value must be one of [SECURE_DEFAULT, SECURE_NEVER, SECURE_OPTIONAL, SECURE_ALWAYS]."
  }
  validation {
    condition     = var.handlers != null ? ! contains([for login in var.handlers[*].login : (login == null || contains(["LOGIN_OPTIONAL", "LOGIN_ADMIN", "LOGIN_REQUIRED"], login)) if login != null], false) : true
    error_message = "Login field value must be one of [LOGIN_OPTIONAL, LOGIN_ADMIN, LOGIN_REQUIRED]."
  }
  validation {
    condition     = var.handlers != null ? ! contains([for auth_fail_action in var.handlers[*].auth_fail_action : (auth_fail_action == null || contains(["AUTH_FAIL_ACTION_REDIRECT", "AUTH_FAIL_ACTION_UNAUTHORIZED"], auth_fail_action)) if auth_fail_action != null], false) : true
    error_message = "Auth fail action field value must be one of [AUTH_FAIL_ACTION_REDIRECT,AUTH_FAIL_ACTION_UNAUTHORIZED]."
  }
  validation {
    condition     = var.handlers != null ? ! contains([for redirect_http_response_code in var.handlers[*].redirect_http_response_code : (redirect_http_response_code == null || contains(["REDIRECT_HTTP_RESPONSE_CODE_301", "REDIRECT_HTTP_RESPONSE_CODE_302", "REDIRECT_HTTP_RESPONSE_CODE_303", "REDIRECT_HTTP_RESPONSE_CODE_307"], redirect_http_response_code)) if redirect_http_response_code != null], false) : true
    error_message = "Redirect HTTP response code field value must be one of [REDIRECT_HTTP_RESPONSE_CODE_301, REDIRECT_HTTP_RESPONSE_CODE_302, REDIRECT_HTTP_RESPONSE_CODE_303, REDIRECT_HTTP_RESPONSE_CODE_307]."
  }
  default = null
}

variable "network" {
  description = "(Optional) Extra network settings to be defined for the App Engine service."
  type = object({
    name             = string,
  })
  default = null
}

variable "resources" {
  description = "(Optional) Machine resources for a version."
  type = object({
    cpu       = number,
    disk_gb   = number,
    memory_gb = number,
    volumes = list(object({
      name        = string,
      volume_type = string,
      size_gb     = number
    }))
  })
  default = null

  validation {
    condition     = var.resources != null ? (var.resources.cpu == 1 || (var.resources.cpu >= 2 && var.resources.cpu <= 96 && var.resources.cpu / 2 == 0)) : true
    error_message = "CPU must be 1 or an even number between 2 and 96."
  }

  validation {
    condition     = var.resources != null ? (var.resources.disk_gb >= 10 && var.resources.disk_gb <= 10240) : true
    error_message = "Disk size must be between 10GB and 10240GB."
  }

  validation {
    condition     = var.resources != null ? (var.resources.volumes != null ? length(var.resources.volumes["name"]) >= 1 && length(var.resources.volumes["name"]) <= 63 && length(regexall("^[A-z][[:word:]-]+[[:alnum:]]$", var.resources.volumes["name"])) > 0 : true) : true
    error_message = "Volume name length must be between 1 and 63. The first character has to be a letter and the last character can't be a dash."
  }

  validation {
    condition     = var.resources != null ? (var.resources.volumes != null ? var.resources.volumes["volume_type"] == "tmfps" : true) : true
    error_message = "Volume type must be tmfps."
  }
}

variable "api_config" {
  description = "(Optional) Serving configuration for Google Cloud Endpoints."
  type = list(object({
    script           = string,
  }))
  default = null

  validation {
    condition     = var.api_config != null ? ! contains([for auth_fail_action in var.api_config[*].auth_fail_action : (auth_fail_action == null || contains(["AUTH_FAIL_ACTION_REDIRECT", "AUTH_FAIL_ACTION_UNAUTHORIZED"], auth_fail_action)) if auth_fail_action != null], false) : true
    error_message = "Auth fail action field value must be one of [AUTH_FAIL_ACTION_REDIRECT,AUTH_FAIL_ACTION_UNAUTHORIZED]."
  }

  validation {
    condition     = var.api_config != null ? ! contains([for login in var.api_config[*].login : (login == null || contains(["LOGIN_OPTIONAL", "LOGIN_ADMIN", "LOGIN_REQUIRED"], login)) if login != null], false) : true
    error_message = "Login field value must be one of [LOGIN_OPTIONAL, LOGIN_ADMIN, LOGIN_REQUIRED]."
  }

  validation {
    condition     = var.api_config != null ? ! contains([for security_level in var.api_config[*].security_level : (security_level == null || contains(["SECURE_DEFAULT", "SECURE_NEVER", "SECURE_OPTIONAL", "SECURE_ALWAYS"], security_level)) if security_level != null], false) : true
    error_message = "Security level field value must be one of [SECURE_DEFAULT, SECURE_NEVER, SECURE_OPTIONAL, SECURE_ALWAYS]."
  }
}

variable "zip" {
  description = "(Optional) Zip File Structure."
  type = object({
    source_url  = string,
  })
  default = null
}

variable "files" {
  description = "(Optional) Manifest of the files stored in Google Cloud Storage that are included as part of this version."
  type = list(object({
    name       = string,
    source_url = string
  }))
  default = null
}

variable "container" {
  description = "(Optional) The Docker image for the container that runs the version."
  type = list(object({
    image = string
  }))
  default = null

  validation {
    condition     = var.container != null ? ! contains([for image in var.container[*].image : (image == null || length(regexall("^(eu|us|asia)?gcr.io/[[:word:]-]+/[[:word:]-]+(:[[:word:]-]+|@[[:alnum:]]+)$", image)) > 0) if image != null], false) : true
    error_message = "Security level field value must be one of [SECURE_DEFAULT, SECURE_NEVER, SECURE_OPTIONAL, SECURE_ALWAYS]."
  }
}

variable "cloud_build_options" {
  description = "(Optional) Options for the build operations performed as a part of the version deployment. Only applicable when creating a version using source code directly."
  type = list(object({
    app_yaml_path       = string
  }))
  default = null
}

variable "endpoints_api_service" {
  description = "(Optional) Code and application artifacts that make up this version."
  type = list(object({
    name                   = string
  }))
  default = null

  validation {
    condition     = var.endpoints_api_service != null ? ! contains([for rollout_strategy in var.endpoints_api_service[*].rollout_strategy : (rollout_strategy == null || contains(["FIXED", "MANAGED"], rollout_strategy)) if rollout_strategy != null], false) : true
    error_message = "Rollout strategy field value must be one of [FIXED, MANAGED]."
  }
}

variable "entrypoint" {
  description = "(Optional) The entrypoint for the application."
  type = object({
    shell = string
  })
  default = null
}

variable "cool_down_period" {
  description = "Optional) The time period that the Autoscaler should wait before it starts collecting information from a new instance. This prevents the autoscaler from collecting information when the instance is initializing, during which the collected usage would not be reliable."
  type        = string
  default     = "120s"
}

variable "noop_on_destroy" {
  description = "(Optional; Default: True)If set to true, the application version will not be deleted upon running Terraform destroy."
  type        = bool
  default     = true
}
