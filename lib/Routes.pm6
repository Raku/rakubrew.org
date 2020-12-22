use Cro::HTTP::Router;
use Cro::WebApp::Template;
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
            content 'text/html', render-template('base.crotmp', {
                content     => $homepage.render('browser', $platform),
                head-matter => '<link rel="stylesheet" href="css/' ~ ($platform eq 'win' ?? 'win.css' !! 'linux.css') ~ '">',
            });
        }

        get -> $platform where any($release-store.platforms), $name where m/rakubrew(\.exe)?/ {
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

        get -> *@path {
            static 'public', @path;
        }
    }
}
