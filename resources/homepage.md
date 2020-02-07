                         (lk(__)lk)        (lb(___)lb)                         
          (lr(_______)lr)(la(_____)la)  (lk(|  | __)lk)(lu(__ _)lu)(lb(\  |_________   ______  _  __)lb)
          (lr(\_  __ \)lr)(la(__  \)la) (lk(|  |/ /)lk)(lu(  |  \)lu)(lb( __ \_  __ \_/ __ \ \/ \/ /)lb)
          (lr( |  | \/)lr)(la(/ __ \)la)(lk(|    <)lk)(lu(|  |  /)lu)(lb( \_\ \  | \/\  ___/\     / )lb)
          (lr( |__|)lr)  (la((______/)la)(lk(__|__\)lk)(lu(____/)lu)(lb(|_____/__|    \_____>\/\_/  )lb)
                                                           (ver()ver)

===============================================================================
                                 DISCLAMER

           This website and rakubrew is still in the test phase.
    There has not been a release yet. The downloads will likely not work.
        Stuff might be broken. So don't use any of this in production.
===============================================================================

rakubrew (called rakudobrew in a previous life) is a (link([Raku][1])link) installation
tool. It allows to have multiple versions of different Raku implementations
installed in parallel and switch between them. It's a (link([perlbrew][2])link) and
(link([plenv][3])link) look alike and supports both flavours of commands.


(h1(Features
========)h1)

(i(-)i) Works about anywhere
    (i(-)i) Windows, MacOS, Linux, BSD
    (i(-)i) Powershell, CMD, Bash, Zsh, Fish, ...
(i(-)i) No dependencies except Perl on Unixy machines
(i(-)i) Can get raku installed and running in seconds
(i(-)i) Autocomplete


(h1(Installation
============)h1)

(platform-linux(
Just copy and paste the following piece of code into a console.

    curl (inline_url(https://rakubrew.org/install-on-perl.sh)inline_url) | sh
)platform-linux)
(platform-win(
On (code(`CMD`)code) you need to download (inline_url(https://rakubrew.org/install-on-cmd.bat)inline_url) and then
execute that script in a CMD terminal.

On (code(`PowerShell`)code) just copy and paste the following piece of code into a
Powershell window (Don't forget the "." at the start of the command!):

    . {iwr -useb https://rakubrew.org/install-on-powershell.ps1 } | iex
)platform-win)
(platform-macos(
Just copy and paste the following piece of code into a console.

    curl (inline_url(https://rakubrew.org/install-on-macos.sh)inline_url) | sh
)platform-macos)


(h1(Bare bones installation
=======================)h1)

If the above installation script somehow doesn't work for you, you can install
rakubrew manually.

First download the right rakubrew executable for your platform:

    Unix-ish: (inline_url(https://rakubrew.org/perl/rakubrew)inline_url)
    Mac OS:   (inline_url(https://rakubrew.org/macos/rakubrew)inline_url)
    Windows:  (inline_url(https://rakubrew.org/win/rakubrew.exe)inline_url)

Put that file into a folder that's in your (code(`PATH`)code) and run

    rakubrew mode shim

That's all!


(h2(`env` mode
----------)h2)

If you want to use (code(`env`)code) mode, use the (code(`shell`)code) command or use auto-completion,
you need to install the shell hook. To get the instructions on how to do that
with

    rakubrew init


(h2(Installation path
-----------------)h2)

To make rakubrew use a different directory to store its files set the
(code(`RAKUBREW_HOME`)code)
environment variable prior to calling it. Put the following into your (code(`.bashrc`)code)
or similar:

    export RAKUBREW_HOME=~/rakubrew (c(# or some other path)c)


(h2(CPAN
----)h2)

Installation via (link([CPAN][4])link) is possible as well. Just use your favorite CPAN
client to install (code(`App::Rakubrew`)code).

    cpanm App::Rakubrew


(h1(How
===)h1)

    (c(# list available versions)c)
    rakubrew list
    
    (c(# download and install the latest Rakudo on MoarVM version)c)
    rakubrew download

    (c(# switch to use that version (substitute the version you just installed))c)
    rakubrew switch moar-2019.11

    raku -e 'say "Now running {$*RAKU.compiler.version}!"'


(h1(global, shell, local
====================)h1)

rakubrew knows three different versions that can be set separately.

The (code(`global`)code) version is the one that is selected when neither the (code(`shell`)code)
version nor the (code(`local`)code) version are active.

The (code(`shell`)code) version changes the active Raku version just in the current shell.
Closing the current shell also looses the (code(`shell`)code) version.

The (code(`local`)code) version is specific to a folder. When CWD is in that folder or a sub
folder that version of Raku is used. Only works in (code(`shim`)code) mode. To unset a
local version one must delete the (code(`.RAKU_VERSION`)code) file in the respective folder.


(h1(Modes
=====)h1)

rakubrew can work in two distinct modes: (code(`env`)code) and (code(`shim`)code)

In (code(`env`)code) mode rakubrew modifies the (code(`$PATH`)code) variable as needed when switching
between versions. This is neat because one then runs the executables directly.
This is the default mode on *nix.

In (code(`shim`)code) mode rakubrew generates wrapper scripts called shims for all
executables it can find in all the different Raku installations. These
shims forward to the actual executable when called. This mechanism allows for
some advanced features, such as local versions. When installing a module that
adds scripts one must make rakubrew aware of these new scripts. This is done
with

    rakubrew rehash

In (code(`env`)code) mode this is not necessary.


(h1(Registering external versions
=============================)h1)

To add a Raku installation to rakubrew that was created outside of rakubrew one
should do:

    rakubrew register name-of-version /path/to/raku/install/directory


(h1(Upgrading
=========)h1)

    rakubrew self-upgrade


(h1(Uninstall
=========)h1)

To remove rakubrew and any Perl 6 implementations it has installed on your
system, delete the  (code(`~/.rakubrew`)code) and (code(`~/.local/share/rakubrew`)code) directories.


(h1(Git annoyances
==============)h1)

(h2(Git not found
-------------)h2)

In case your git binary is not in the (code(`PATH`)code) on your system, you can specify
a custom path to the git binary using the (code(`GIT_BINARY`)code) environment variable:

    GIT_BINARY="%USERPROFILE%\Local Settings\Application Data\GitHub\
        PORTAB~1\bin\git.exe" rakubrew build all


(h2(Git clone failing
-----------------)h2)

When git fails to clone any repositories, it might be you are sitting behind a
firewall that blocks the network protocol / port git uses by default.
You can change the protocol to something that will usually be acceptable to
firewalls by setting the (code(`GIT_PROTOCOL`)code) environment variable:

    (c(# for https)c)
    GIT_PROTOCOL=https rakubrew list-available
    (c(# for ssh)c)
    GIT_PROTOCOL=ssh rakubrew list-available


(h1(Command-line switches
=====================)h1)

(h2(`version` or `current`
----------------------)h2)

Show the currently active Raku version.


(h2(`versions` or `list`
--------------------)h2)

List all installed Raku installations.


(h2(`global [version]` or `switch [version]`
----------------------------------------)h2)

Show or set the globally configured Raku version.


(h2(`shell [--unset|version]`
-------------------------)h2)

Show, set or unset the shell version.


(h2(`local [--unset|version]`
-------------------------)h2)

Show, set or unset the local version.


(h2(`nuke [version]` or `unregister [version]`
------------------------------------------)h2)

Removes an installed or registered version. Versions built by rakubrew are
actually deleted, registered versions are only unregistered but not deleted.


(h2(`rehash`
--------)h2)

Regenerate all shims. Newly installed scripts will not work unless this is
called. This is only necessary in (code(`shim`)code) mode.


(h2(`list-available`
----------------)h2)

List all Raku versions that can be installed.


(h2(`build[-rakudo] [jvm|moar|moar-blead|all] [tag|branch|sha-1] [--configure-opts=]`
---------------------------------------------------------------------------------)h2)

Build a Raku version. The arguments are:
(i(-)i) The backend.
    (i(-)i) (code(`moar-blead`)code) is the moar and nqp backends at the master branch.
    (i(-)i) (code(`all`)code) will build all backends.
(i(-)i) The version to build. Call (code(`list-available`)code) to see a list of available
  versions. When left empty the latest release is built.
  It is also possible to specify a commit sha or branch to build.
(i(-)i) Configure options.


(h2(`triple [rakudo-ver [nqp-ver [moar-ver]]]`
------------------------------------------)h2)

Build a specific set of Rakudo, NQP and MoarVM commits.


(h2(`register <name> <path>`
------------------------)h2)

Register an externaly built / installed Raku version with rakubrew.


(h2(`build-zef`
-----------)h2)

Install Zef into the current Raku version.


(h2(`download[-rakudo] [<%backends%>] [<rakudo-version>]`
-----------------------------------------------------)h2)

Download and install a precompiled release archive.


(h2(`exec <command> [command-args]`
-------------------------------)h2)

Explicitly call an executable. You normally shouldn't need to do this.


(h2(`which <command>`
-----------------)h2)

Show the full path to the executable.


(h2(`whence [--path] <command>`
---------------------------)h2)

List all versions that contain the given command. when (code(`--path`)code) is given the
path of the executables is given instead.


(h2(`mode [env|shim]`
-----------------)h2)

Show or set the mode of operation.


(h2(`self-upgrade`
--------------)h2)

Upgrade rakubrew.


(h2(`init`
------)h2)

Show installation instructions.


(h2(`test [version|all]`
--------------------)h2)

Run tests in the current or given version.


(h1(Bugs'n'Development
==================)h1)

rakubrew is developed on (link([Github][5])link). To report a bug, head over there and
create a new issue.


(h1(Authors
=======)h1)

(i(-)i) Patrick Böker (full rewrite and current maintainer)
(i(-)i) Tadeusz Sośnierz (original author)


(url([1]: https://raku.org/)url)
(url([2]: https://perlbrew.pl/)url)
(url([3]: https://github.com/tokuhirom/plenv)url)
(url([4]: https://metacpan.org/pod/App::Rakubrew)url)
(url([5]: https://github.com/rakubrew/App-Rakubrew/)url)
