# Class: s3::curl
#
# This clas installs cURL and ensures it is installed before
# any S3::File resources are evaluated.
class s3::curl () {
  package { 'curl':
  } -> S3::File<| |>
}
