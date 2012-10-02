# Puppet S3 File synchronization

Example Usage:

    include 's3file::curl'
    s3file { '/path/to/destination/file':
      source => 'MyBucket/the/file',
      ensure => 'latest',
    }
