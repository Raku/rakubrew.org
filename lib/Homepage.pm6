use HTML::Escape;

enum COLOR <
    black
    red
    green
    yellow
    blue
    magenta
    cyan
    white
    bright-black
    bright-red
    bright-green
    bright-yellow
    bright-blue
    bright-magenta
    bright-cyan
    bright-white
>;

class Colorizer {
    method color(COLOR $color, $text, :$ul, :$bold) { ... }
}

class HTMLColorizer is Colorizer {
    method color(COLOR $color, $text, :$ul, :$bold) {
        "<span class='{$color}{$ul ?? " underline" !! ""}{$bold ?? " bold" !! ""}'>{$text}</span>"
    }
}

my %color-map =
    black          => 30,
    red            => 31,
    green          => 32,
    yellow         => 33,
    blue           => 34,
    magenta        => 35,
    cyan           => 36,
    white          => 37,
    bright-black   => 90,
    bright-red     => 91,
    bright-green   => 92,
    bright-yellow  => 93,
    bright-blue    => 94,
    bright-magenta => 95,
    bright-cyan    => 96,
    bright-white   => 97,
;
class ConsoleColorizer is Colorizer {
    method color(COLOR $color, $text, :$ul, :$bold) {
        27.chr ~ '['
        ~ ($bold ?? '1;' !! '')
        ~ ($ul   ?? '4;' !! '')
        ~ %color-map{$color}
        ~ 'm'
        ~ $text
        ~ 27.chr ~ '[0m';
    }
}

class Homepage {
    has $!template = %?RESOURCES<homepage.md>.slurp;
    has $!console-colorizer = ConsoleColorizer.new;
    has $!html-colorizer = HTMLColorizer.new;
    has $.releases is required;

    method !colorify($platform, $client, $c) {
        my $page = $!template;

        $page = escape-html $page if $client eq 'browser';

        my $ver-str = 'v' ~ $!releases.get-latest-version;
        $page ~~ s:g[ \(ver\(\)ver\) ] = ' ' x (4 - $ver-str.elems) ~ $ver-str;

        $page ~~ s:g[ \n \(platform\-(\w+)\( (.+?) \n \)platform\-$0\) ] = $platform eq $0 ?? $1 !! '';

        sub c($marker, $color, :$bold, :$ul) {
            $page ~~ s:g[ \( $marker \( (.+?) \) $marker \) ] = $c.color($color, $0, :$bold, :$ul);
        }
        c 'h1', cyan, :bold;
        c 'h2', cyan;
        c 'c', bright-blue;
        c 'l', yellow;
        c 'i', yellow;
        c 'lr', green, :bold;
        c 'la', red, :bold;
        c 'lk', yellow, :bold;
        c 'lu', bright-blue, :bold;
        c 'lb', magenta, :bold;

        if $client eq 'browser' {
            my %urls;
            $page ~~ s:g[ \(url\( \[ (\d+) \]\: ' ' (.+?) \)url\) ] = {
                %urls{$0} = $1;
                "[<a name=\"link-$0\">{$c.color(green, $0)}</a>]: <a href=\"$1\">{$c.color(magenta, $1)}</a>";
            }();

            $page ~~ s:g[ \(link\( \[ (.+?) \]\[ (.+?) \] \)link\) ]
                = "[<a href=\"%urls{$1}\">{$c.color(bright-magenta, $0, :ul)}</a>][<a href=\"#link-$1\">{$c.color(green, $1)}</a>]";

            my $html-tick = escape-html('`');
            $page ~~ s:g[ \(code\( $html-tick (.+?) $html-tick \)code\) ]
                = $c.color(green, "`$0`", :bold);
        }
        else {
            $page ~~ s:g[ \(url\( \[ (\d+) \]\: ' ' (.+?) \)url\) ]
                = "[{$c.color(green, $0)}]: {$c.color(magenta, $1)}";

            $page ~~ s:g[ \(link\( \[ (.+?) \]\[ (.+?) \] \)link\) ]
                = "[{$c.color(bright-magenta, $0, :ul)}][{$c.color(green, $1)}]";

            $page ~~ s:g[ \(code\( \` (.+?) \` \)code\) ]
                = $c.color(green, "`$0`", :bold);
        }

        $page;
    }

    method render($client, $platform) {
        given $client {
            when 'console' {
                return self!colorify: $platform, $client, $!console-colorizer;
            }
            when 'browser' {
                return '<div class="console-div"><pre>' ~ self!colorify($platform, $client, $!html-colorizer) ~ '</pre></div>';
            }
        }
    }
}
