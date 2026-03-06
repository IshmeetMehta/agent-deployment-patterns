variable "project_id" {}
variable "region" { default = "us-central1" }
variable "github_pat" { sensitive = true }
variable "github_owner" {}
variable "repo_name" {}
variable "agent_patterns" {
  type    = list(string)
  default = ["gke", "cloudrun", "agent-engine"]
}
