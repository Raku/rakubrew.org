my %platforms =
    win   => { bin => 'rakubrew.exe' },
    macos => { bin => 'rakubrew' },
    pp    => { bin => 'rakubrew' },
;

class Release {
    has UInt $.version;
    has Str $.changes;
    has IO::Path $.dir is required;

    submethod TWEAK() {
        $!version = $!dir.basename.Int;
        $!changes = $!dir.add('changes').slurp;
    }

    method get-bin($platform) {
        die 'unknown platform' unless %platforms{$platform}:exists;
        my $bin = $!dir.add($platform).add(%platforms{$platform}<bin>);
        die 'file not found' unless $bin.f;
        $bin;
    }
}

class Releases {
    has $.release-dir is required;
    has @!releases;

    submethod TWEAK() {
        @!releases.push: Release.new(dir => $_) for $!release-dir.dir;
        @!releases.sort: { $^b leg $^a };
    }

    method get-latest-bin($platform) {
        die 'no releases found' unless @!releases.elems;
        {
            filename => %platforms{$platform}<bin>,
            path     => @!releases[0].get-bin($platform),
        }
    }

    method get-latest-version() {
        @!releases[0].version;
    }

    method get-index() {
        my %index;
        for @!releases -> $release {
            %index<releases>.push: {
                version => $release.version,
                changes => $release.changes,
            }
            %index<latest> //=  $release.version;
            %index<latest> max= $release.version;
        }
        %index<releases> .= sort: { $^b<version> leg $^a<version> };
        %index;
    }

    method platforms() {
        %platforms.keys;
    }
}
