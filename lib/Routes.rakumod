use Cro::HTTP::Router;
use Releases;
use Homepage;

sub routes($release-store, $homepage) is export {
    route {
        get -> :$user-agent is header where m:i/wget|curl/ {
            content 'text/plain', $homepage.render('console', 'linux');
        }
        get -> :$user-agent is header, :$platform is copy {
            if !$platform.defined || $platform !~~ / linux | win | macos / {
                $platform = $user-agent ~~ m:i/Windows/ ?? 'win'
                    !! $user-agent ~~ m:i/ os \s x | Macintosh | iPhone | iPad | iPod / ?? 'macos'
                    !! 'linux';
            }
            content 'text/html', $homepage.render('browser', $platform);
        }

        get -> $platform where any($release-store.platforms), $name where m/rakubrew(\.exe)?/ {
            CATCH {
                when X::UnknownPlatform { bad-request 'text/plain', "Unknown platform" }
                when X::FileNotFound    { not-found 'text/plain', "File not found" }
                when X::ReleaseNotFound { request.status = 500; content 'text/plain', 'No releases  found' }
            }
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

        get -> 'files', $version, $platform, $filename {
            CATCH {
                when X::UnknownPlatform { bad-request 'text/plain', "Unknown platform" }
                when X::FileNotFound    { not-found 'text/plain', "File not found" }
                when X::ReleaseNotFound { not-found 'text/plain', 'Release not found' }
            }
            my %release = $release-store.get-bin: $version, $platform;
            given response {
                .append-header: 'Content-Type', 'application/octet-stream';
                .append-header: 'Content-Disposition', 'attachment; filename="' ~ %release<filename> ~ '"';
                .append-header: 'Content-Length', %release<path>.s;
                .set-body:  %release<path>.slurp(:bin);
                .status = 200;
            }
        }

        get -> *@path {
            static 'public', @path;
        }
    }
}
