define s3file (
  $source,
)
{
  $real_source = "https://s3.amazonaws.com/${source}"
  exec { "fetch ${name}":
    path    => ['/bin', '/usr/bin', 'sbin', '/usr/sbin'],
    command => "curl -L -o ${name} ${real_source}",
    unless  => "[ -e ${name} ] && curl -I ${real_source} | grep ETag | grep `md5sum ${name} | cut -c1-32`",
    creates => $name,
  }
}
