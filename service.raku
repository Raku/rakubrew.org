use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Routes;
use Releases;
use Homepage;

my $release-dir = %*ENV<RAKUBREW_ORG_RELEASES_DIR>;
if !$release-dir {
    $release-dir = $*PROGRAM.parent.add: 'releases';
    $release-dir.mkdir if !$release-dir.e;
}
else {
    $release-dir = $release-dir.IO;
}
die "$release-dir is not a directory!" if !$release-dir.d;

my $releases = Releases.new: release-dir => $release-dir;

my $homepage = Homepage.new: :$releases;

my $host = %*ENV<RAKUBREW_ORG_HOST> || 'localhost';
my $port = %*ENV<RAKUBREW_ORG_PORT> || 10000;

my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    host => $host,
    port => $port,
    application => routes($releases, $homepage),
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
);

$http.start;

say "Listening at http://$host:$port";
react {
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}
