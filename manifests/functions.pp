class admin::functions {
  define line($file, $line, $ensure = 'present') {
    case $ensure {
      default : { err ( "unknown ensure value ${ensure}" ) }
      present: {
        exec { "/bin/echo '${line}' >> '${file}'":
            unless => "/bin/grep -qFx '${line}' '${file}'"
        }
      }
  
      absent: {
        exec { "/bin/grep -vFx '${line}' '${file}' | /usr/bin/tee '${file}' > /dev/null 2>&1":
          onlyif => "/bin/grep -qFx '${line}' '${file}'"
        }
      }
      uncomment: {
        exec { "/bin/sed -i -e'/${line}/s/#\\+//' '${file}'":
          onlyif => "/bin/grep '${line}' '${file}' | /bin/grep '^#' | /usr/bin/wc -l"
        }
      }
      comment: {
        exec { "/bin/sed -i -e'/${line}/s/\\(.\\+\\)$/#\\1/' `${file}`":
          onlyif => "/usr/bin/test `/bin/grep '${line}' '${file}' | /bin/grep -v '^#' | /usr/bin/wc -l` -ne 0"
        }
      }
    }
  }
  
  define ensure_key_value($file, $key, $value, $delimiter = " ") {
    $key_escaped_slashes = regsubst($key, '(\/)', '\\/', 'G')
    $value_escaped_slashes = regsubst($value, '(\/)', '\\/', 'G')
  
    # append line if "$key" not in "$file"
    exec { "append ${key}${delimiter}${value} ${file}":
      command => "echo '${key}${delimiter}${value}' >> ${file}",
      unless => "grep -qe '^[[:space:]]*${key}[[:space:]]*${delimiter}' -- ${file}",
      path => "/bin:/usr/bin:/usr/local/bin",
      before => Exec["update ${key}${delimiter}${value} ${file}"],
    }
  
    # update it if it already exists...
    exec { "update ${key}${delimiter}${value} ${file}":
      command => "sed --in-place='' --expression='s/^\([[:space:]]*\)${key_escaped_slashes}[[:space:]]*${delimiter}.*$/\1${key_escaped_slashes}${delimiter}${value_escaped_slashes}/g' $file",
      unless => "grep -xqe '[[:space:]]*${key}${delimiter}${value}' -- $file",
      path => "/bin:/usr/bin:/usr/local/bin"
    }
  }
  
  define delete_lines($file, $pattern) {
    $pattern_escaped_slashes = regsubst($pattern, '(\/)', '\\/', 'G')
    exec { "/bin/sed -i -r -e '/${pattern_escaped_slashes}/d' ${file}":
      onlyif => "/bin/grep -E '${pattern}' '${file}'",
    }
  }
  
  define replace($file, $pattern, $replacement) {
    $pattern_escaped_slashes = regsubst($pattern, '(\/)', '\\/', 'G')
    $replacement_escaped_slashes = regsubst($replacement, '(\/)', '\\/', 'G')
  
    exec { "/usr/bin/perl -pi -e 's/${pattern_escaped_slashes}/${replacement_escaped_slashes}/' '${file}'":
      onlyif => "/usr/bin/perl -ne 'BEGIN { \$ret = 1; } \$ret = 0 if /${pattern_escaped_slashes}/ && ! /${replacement_escaped_slashes}/ ; END { exit \$ret; }' '${file}'",
    }
  }
  
  define enable_ssh_key ($user, $key) {
    ssh_authorized_key { $name:
      ensure => present,
      user   => root,
      type   => 'rsa',
      key    => $key,
    }
  }
}
