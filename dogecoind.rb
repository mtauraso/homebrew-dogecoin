require 'formula'

class Dogecoind < Formula
    head 'https://github.com/dogecoin/dogecoin.git', :using => :git

    url 'https://github.com/dogecoin/dogecoin/archive/1.10.tar.gz'
    sha256 '60cd68699895d0061e0b736a1bb2875dc8f40715cea643f92cd4a87ab48340cc'

    depends_on 'miniupnpc'
    depends_on 'openssl'
    depends_on 'berkeley-db'
    depends_on 'boost' => 'universal'

    def install
        inreplace 'contrib/debian/examples/dogecoin.conf', '#testnet=1', 'testnet=1'
        inreplace 'contrib/debian/examples/dogecoin.conf', '#server=1', 'server=1'
        inreplace 'contrib/debian/examples/dogecoin.conf', '#rpcuser=Ulysseys', 'rpcuser=dogecoinrpc'
        inreplace 'contrib/debian/examples/dogecoin.conf', '#rpcpassword=YourSuperGreatPasswordNumber_385593', 'rpcpassword=4bEGCHMQqX6PeQyicj9Z9Yq1FQCKYyQS1w8wZERQy3tL'
        inreplace 'src/makefile.osx', 'CFLAGS += -stdlib=libstdc++', '#CFLAGS += -stdlib=libstdc++'

        cd 'src' do
            system 'make -f makefile.osx'
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
