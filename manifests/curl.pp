# Class: s3file::curl
#
# This clas installs cURL and ensures it is installed before
# any S3file resources are evaluated.
class s3file::curl () {
  package { 'curl':
  } -> S3file<| |>
}
