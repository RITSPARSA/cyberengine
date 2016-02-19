require 'scoring_engine'

module ScoringEngine
  module Checks

    class NFSDownload < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "NFS Download"
      PROTOCOL = "nfs"
      VERSION = "ipv4"

      def command_str
        share = get_random_property('share')
        raise("Missing share property") unless share
        filename = get_random_property('filename')
        raise("Missing filename property") unless filename
        
        cmd = "tmpdir=$(mktemp -d /tmp/nfs_mount.XXXX) && tmpfile=$(mktemp /tmp/nfs_file.XXXX) "
        cmd << "&& mount -t nfs #{ip}:#{share} $tmpdir "
        cmd << "&& cp $tmpdir/#{filename} $tmpfile "
        cmd << "&& umount $tmpdir "
        cmd << "&& echo OK || echo NOK"

        return cmd
      end

    end
  end
end
