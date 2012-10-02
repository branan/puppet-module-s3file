# Definition: s3file
#
# This definition fetches and keeps synchonized a file stored in S3
#
# Parameters:
# - $name: The local target of the file
# - $source: The bucket and filename on S3
# - $ensure: 'present', 'absent', or 'latest': as the core File resource
# - $s3_domain: s3 server to fetch the file from
#
# Requires:
# - cURL
#
# Sample Usage:
#
#  s3file { '/opt/minecraft/minecraft_server.jar':
#    source => ‘MinecraftDownload/launcher/minecraft_server.jar’,
#    ensure => ‘latest’,
#  }
#
define s3file (
  $source,
  $ensure = 'latest',
  $s3_domain = 's3.amazonaws.com',
)
{
  $valid_ensures = [ 'absent', 'present', 'latest' ]
  validate_re($ensure, $valid_ensures)

  if $ensure == 'absent' {
    # We use a puppet resource here to force the file to absent state
    file { $name:
      ensure => absent
    }
  } else {
    $real_source = "https://${s3_domain}/${source}"

    if $ensure == 'latest' {
      $unless = "[ -e ${name} ] && curl -I ${real_source} | grep ETag | grep `md5sum ${name} | cut -c1-32`"
    } else {
      $unless = "[ -e ${name} ]"
    }

    exec { "fetch ${name}":
      path    => ['/bin', '/usr/bin', 'sbin', '/usr/sbin'],
      command => "curl -L -o ${name} ${real_source}",
      unless  => $unless
    }
  }
}
