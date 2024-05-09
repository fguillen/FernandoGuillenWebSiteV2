# Commands

## Run the live server

    bundle exec middleman

## Build the release

    bundle exec middleman build

All the release files will be in `/docs` folder so Github Pages will serve them.

## Using gem middleman-gh-pages

```
# Configuration is in `Rakefile`
rake build
rake publish
```
