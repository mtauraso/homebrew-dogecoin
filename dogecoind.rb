require 'formula'

class Dogecoind < Formula
    head 'https://github.com/dogecoin/dogecoin.git', :using => :git

    url 'https://github.com/dogecoin/dogecoin/archive/v1.10.0.tar.gz'
    sha256 'e392f4142819fdab313ba921af53fdbd2cf6ee8965d237d0cb5cda8a52c97084'

    depends_on 'automake'
    depends_on 'autoconf'
    depends_on 'libtool'
    depends_on 'miniupnpc'
    depends_on 'openssl'
    depends_on 'pkg-config'
    depends_on 'protobuf'
    depends_on 'qt5'
    depends_on 'berkeley-db' #TODO see about version lock?
    depends_on 'boost' => 'universal'

    def install
        inreplace 'contrib/debian/examples/dogecoin.conf', '#testnet=0', 'testnet=1'
        inreplace 'contrib/debian/examples/dogecoin.conf', '#server=0', 'server=1'
        inreplace 'contrib/debian/examples/dogecoin.conf', '#rpcuser=Ulysseys', 'rpcuser=dogecoinrpc'
        inreplace 'contrib/debian/examples/dogecoin.conf', '#rpcpassword=YourSuperGreatPasswordNumber_DO_NOT_USE_THIS_OR_YOU_WILL_GET_ROBBED_385593', 'rpcpassword=4bEGCHMQqX6PeQyicj9Z9Yq1FQCKYyQS1w8wZERQy3tL'

        cd 'src' do
            system './autogen.sh'
            system './configure --with-gui=qt5'
            system 'make'
        end

        bin.install 'src/dogecoind'
        etc.install 'contrib/debian/examples/dogecoin.conf'
        bash_completion.install 'contrib/dogecoind.bash-completion'
        man1.install 'contrib/debian/manpages/dogecoind.1'
        man5.install 'contrib/debian/manpages/dogecoin.conf.5'

        dogelib=var+'lib/dogecoin'
        dogelib.mkpath unless dogelib.exist?
    end

    test do
        system "#{bin}/dogecoind", '-?'
    end

    def plist; <<-EOS.undent
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>#{plist_name}</string>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <false/>
            <key>ProgramArguments</key>
            <array>
                <string>#{bin}/dogecoind</string>
                <string>-conf=#{etc}/dogecoin.conf</string>
                <string>-pid=#{var}/run/dogecoin.pid</string>
                <string>-datadir=#{var}/lib/dogecoin</string>
            </array>
            <key>WorkingDirectory</key>
            <string>#{HOMEBREW_PREFIX}</string>
        </dict>
        </plist>
        EOS
    end
end
