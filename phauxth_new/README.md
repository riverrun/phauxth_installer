## mix phauxth.new

Provides `phauxth.new` installer as an archive. To build and install it locally,
run the following commands from within this directory:

```elixir
MIX_ENV=prod mix build
cd ../archives
mix archive.install phauxth_new.ez
```
