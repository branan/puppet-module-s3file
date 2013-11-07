# Puppet S3 File synchronization

Example Usage:

    include 's3::curl'
    s3::file { '/path/to/destination/file':
      source => 'MyBucket/the/file',
      ensure => 'latest',
    }
