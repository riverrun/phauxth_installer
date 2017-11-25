## Phauxth installer

This repository contains the `phauxth.new` installer, which can be used
to set up authentication, using the [Phauxth authentication
library](https://github.com/riverrun/phauxth), for a Phoenix app.

## Customizing the installer

The `phauxth.new` installer provides a basic starting point for your app.
In many cases, it will be useful to have a different 'starting point',
and you can do this by customizing the installer.

Instructions:

1. Fork or clone this repository.
2. Make any changes you want to make.
3. Build your local copy of the installer:

```elixir
MIX_ENV=prod mix build
cd ../archives
mix archive.install phauxth_new.ez
```
