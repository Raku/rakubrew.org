use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Cro::WebApp::Template;
use Routes;
use Releases;
use Homepage;

template-location $*PROGRAM.parent.add('templates');

my $release-dir = %*ENV<RELEASE_DIR>;
if !$release-dir {
    $release-dir = $*PROGRAM.parent.add: 'releases';
    $release-dir.mkdir if !$release-dir.e;
}
die "$release-dir is not a directory!" if !$release-dir.d;

my $releases = Releases.new: release-dir => $release-dir;

my $homepage = Homepage.new: :$releases;

my $host = %*ENV<RAKUBREW_ORG_HOST> || 'localhost';
my $port = %*ENV<RAKUBREW_ORG_PORT> || 10000;

my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1 2>,
    host => $host,
    port => $port,
    tls => %(
        private-key-file => %*ENV<RAKUBREW_ORG_TLS_KEY> ||
            %?RESOURCES<fake-tls/server-key.pem> || "resources/fake-tls/server-key.pem",
        certificate-file => %*ENV<RAKUBREW_ORG_TLS_CERT> ||
            %?RESOURCES<fake-tls/server-crt.pem> || "resources/fake-tls/server-crt.pem",
    ),
    application => routes($releases, $homepage),
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
);
$http.start;
say "Listening at https://$host:$port";
react {
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}
