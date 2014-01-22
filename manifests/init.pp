# Definition: s3file
#
# This definition fetches and keeps synchonized a file stored in S3
#
# Parameters:
# - $name: The local target of the file
# - $source: The bucket and filename on S3
# - $ensure: 'present', 'absent', or 'latest': as the core File resource
# - $s3_domain: s3 server url to fetch the file from including protocol (D:https://s3.amazonaws.com)
# - $s3_access_key: access key for s3 api service
# - $s3_private_key: private key for s3 signature
# - $logoutput: log the curl output to the screen on puppet run
# Requires:
# - cURL
#
# Sample Usage:
#
#  s3file { '/opt/minecraft/minecraft_server.jar':
#    source => 'MinecraftDownload/launcher/minecraft_server.jar',
#    ensure => 'latest',
#  }
#
define s3file (
  $source,
  $ensure = 'latest',
  $s3_domain = 'https://s3.amazonaws.com',
  $s3_access_key = undef,
  $s3_secret_key = undef,               
  $logoutput = false,
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
    $real_source = "${s3_domain}/${source}"

    if $ensure == 'latest' {
      $unless = "[ -e ${name} ] && curl -I ${real_source} | grep ETag | grep `md5sum ${name} | cut -c1-32`"
    } else {
      $unless = "[ -e ${name} ]"
    }

    if $s3_secret_key == undef or $s3_access_key == undef
    {
      $curl_command = "curl -L -o ${name} ${real_source}"
    }
    else
    {
      # this makes the
      $date = inline_template("<%= Time.now.to_s %>")
      $payload = inline_template("GET\n\n\n<%=@date%>\n/<%= @source -%>")
      $signature = inline_template("<% require 'base64' -%><% require 'openssl' -%><%= Base64.encode64( OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), @s3_secret_key, @payload.encode(Encoding::UTF_8) ) ).strip.to_s-%>")
      $header = inline_template("Authorization: AWS <%=@s3_access_key-%>:<%=@signature-%>")
      $curl_command = "curl -vL -o ${name} -X GET -H \"Date: ${date}\" -H \"${header}\" \"${real_source}\""
    }

    exec { "fetch ${name}":
      path    => ['/bin', '/usr/bin', 'sbin', '/usr/sbin'],
      command => $curl_command,
      logoutput => $logoutput,
      unless  => $unless
    }
  }
}
