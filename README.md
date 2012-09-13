# Puppet S3 File synchronization

Example Usage:

    s3file { '/path/to/destination/file':
      source => 'MyBucket/the/file',
    }

Requirements: `curl` must be installed before any `s3file` resources
are evaluated. This can be done with the following puppet code:

    package { 'curl': }
    Package['curl'] -> S3file<| |>
