[![CodeFactor](https://www.codefactor.io/repository/github/raku/rakubrew.org/badge)](https://www.codefactor.io/repository/github/raku/rakubrew.org)

rakubrew.org
============

The rakubrew.org website.


Development
-----------

For development you'll need to have Cro installed; you can do so using:

```
zef install --/test cro
```

Then change directory to the app root (the directory containing this
`README.md` file), and run these commands:

    zef install --depsonly .
    cro run


Container
---------

You can also build and run a container image while in the app root using:

    podman build -t rakubrew.org .

To run the container do:

    export RAKUBREW_ORG_RELEASES_DIR=/releases
    podman run --rm -p 10000:10000 --volume=/releases/folder/on/host:/releases:ro rakubrew.org

