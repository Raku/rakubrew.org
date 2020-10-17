my %platforms =
    win   => { bin => 'rakubrew.exe' },
    macos => { bin => 'rakubrew' },
    perl  => { bin => 'rakubrew' },
;

class Release {
    has UInt $.version;
    has Str $.changes;
    has IO::Path $.dir is required;

    submethod TWEAK() {
        $!version = $!dir.basename.Int;
        $!changes = $!dir.add('changes').slurp.trim;
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

    method !get-releases() {
        my @releases;
        @releases.push: Release.new(dir => $_) for $!release-dir.dir;
        @releases .= sort: { $^b.version <=> $^a.version };
        @releases;
    }

    method get-latest-bin($platform) {
        my @releases = self!get-releases;
        die 'no releases found' unless @releases.elems;
        {
            filename => %platforms{$platform}<bin>,
            path     => @releases[0].get-bin($platform),
        }
    }

    method get-latest-version() {
        self!get-releases()[0].version;
    }

    method get-index() {
        my %index;
        for self!get-releases -> $release {
            %index<releases>.push: {
                version => $release.version,
                changes => $release.changes,
            }
            %index<latest> //=  $release.version;
            %index<latest> max= $release.version;
        }
        %index;
    }

    method platforms() {
        %platforms.keys;
    }
}
