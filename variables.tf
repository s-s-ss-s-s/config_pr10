variable "report_bucket_name" {
  description = "report bucket name" 
  default     = "report" 
}
 
variable "function_bucket_name" {
  description = "function bucket name"
  default     = "report"
}

variable "get_report_key" {
  description = "S3 key of GetReport Lambda func"
  default     = "GetReport.zip"
}

variable "create_report_key" {
  description = "S3 key of CreateReport Lambda func"
  default     = "CreateReport.zip"
}

variable "fill_report_key" {
  description = "S3 key of FillReport Lambda func"
  default     = "FillReport.zip"
}
