#!/usr/bin/ruby

require 'yaml'
require 'net/http'
require 'uri'
require 'logger'

LOGGER = Logger.new(STDOUT)

def load_config
  config = YAML.load_file "/etc/arch-mirror/config.yml"
  [ config['excludes'], config['sync'] ]
end

def create_excludes(arch)
  returned = []
  return << "*/#{arch}"
  return << "pool/*/*-#{arch}.pkg.tar.xz"
  return << "pool/*/*-#{arch}.pkg.tar.gz"
  returned
end

def create_rsync_excludes(excludes)
  final_file = []
  final_file << 'iso' if excludes['iso']
  final_file += create_excludes("i686") if excludes['32bits']
  final_file += create_excludes("x86_64") if excludes['64bits']
  File.write "/etc/arch-mirror/excludes.txt", final_file.join("\n")
end

def every_to_seconds(value)
  case value
    when 'minutes'
      60
    when 'hours'
      3600
    when 'days'
      86400
  end
end

def get_mirror_lastupdate(mirror)
  Net::HTTP.get(URI.parse("#{mirror}/lastupdate")).to_i
end

def check_for_updates(mirror)
  mirror_lastupdate = get_mirror_lastupdate
  local_update = File.read("/var/mirror/lastupdate").to_i
  if mirror_update > local_update
    do_sync mirror, local_update
  end
end

def do_sync(mirror, local_update)
  rsync_log = "/etc/arch-mirror/logs/log-from-#{local_update}.log"
  rsync_bin = ''
  rsync_params = ''
  output = `#{rsync_bin} #{rsync_params}`
  File.write(rsync_log, output) 
end

def start_processes(sync)
  pid_nginx = fork do
    LOGGER.info "Starting HTTP server : nginx"
    exec "/usr/sbin/nginx"
  end
  sleep_period = every_to_seconds sync['every']
  skip = sync['skip_first']
  LOGGER.info "Syncing every #{sleep_period} seconds"
  while true
    if skip
      LOGGER.info "Skipping initial check..."
      skip = false
    else
      LOGGER.info "Checking for updates..."
      check_for_updates sync['mirror']
    end
    sleep sleep_period
  end
end

def main
  excludes, sync = create_config
  create_rsync_excludes excludes
  start_processes timer
end

main
