use Cro::HTTP::Router;
use Releases;

sub routes($release-store) is export {
    route {
        get -> {
            content 'text/html', "<h1> rakubrew.org </h1>";
        }

        get -> $platform where any($release-store.platforms) {
            my %release = $release-store.get-latest-bin: $platform;
            given response {
                .append-header: 'Content-Type', 'application/octet-stream';
                .append-header: 'Content-Disposition', 'attachment; filename="' ~ %release<filename> ~ '"';
                .append-header: 'Content-Length', %release<path>.s;
                .set-body:  %release<path>.slurp(:bin);
                .status = 200;
            }
        }

        get -> 'releases' {
            content 'application/json', $release-store.get-index;
        }
    }
}
