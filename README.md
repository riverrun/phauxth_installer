## Phauxth installer

This repository contains the `phauxth.new` installer, which can be used
to set up authentication, using the [Phauxth authentication
library](https://github.com/riverrun/phauxth), for a Phoenix app.

## Version 2.3.0 & 1.2

The master branch uses version 2.3.0 of Phauxth and is compatible with
Phoenix 1.4.0 and phoenix_ecto 4.0 (ecto 3).

The v1.2 branch uses version 1.2 of Phauxth with version 1.3 of Phoenix.

## Customizing the installer

The `phauxth.new` installer provides a basic starting point for your app.
In many cases, it will be useful to have a different 'starting point',
and you can do this by customizing the installer.

Instructions:

1. Fork or clone this repository.
2. Make any changes you want to make.
3. Build your local copy of the installer:

```elixir
cd phauxth_new
MIX_ENV=prod mix build
cd ../archives
mix archive.install phauxth_new.ez
```
