defmodule Mix.Tasks.Phauxth.New do
  use Mix.Task

  import Phauxth.New.Generator

  @moduledoc """
  Create modules for basic authorization.

  ## Options and arguments

  There are four options:

    * `:api` - create files to authenticate an api instead of a html application
      * the default is false
    * `:confirm` - create files for email / phone confirmation and password resetting
      * the default is false
    * `:remember` - add functions to enable `remember_me` functionality
      * the default is false
    * `:backups` - if a file already exists, save the old version as a backup file
      * the default is true
      * the old version will be saved with the `.bak` extension

  ## Examples

  In the root directory of your project, run the following command:

      mix phauxth.new

  To create files for an api, run the following command:

      mix phauxth.new --api

  To add email / phone confirmation:

      mix phauxth.new --confirm

  """

  @phx_base [
    {:eex, "auth_case.ex", "test/support/auth_case.ex"},
    {:eex, "repo_seeds.exs", "priv/repo/seeds.exs"},
    {:eex, "user.ex", "/accounts/user.ex"},
    {:eex, "user_migration.exs", "priv/repo/migrations/timestamp_create_users.exs"},
    {:eex, "accounts.ex", "/accounts/accounts.ex"},
    {:eex, "accounts_test.exs", "test/namespace/accounts/accounts_test.exs"},
    {:eex, "session.ex", "/sessions/session.ex"},
    {:eex, "session_migration.exs", "priv/repo/migrations/timestamp_create_sessions.exs"},
    {:eex, "sessions.ex", "/sessions/sessions.ex"},
    {:eex, "sessions_test.exs", "test/namespace/sessions/sessions_test.exs"},
    {:eex, "router.ex", "_web/router.ex"},
    {:eex, "authorize.ex", "_web/controllers/authorize.ex"},
    {:eex, "session_controller.ex", "_web/controllers/session_controller.ex"},
    {
      :eex,
      "session_controller_test.exs",
      "test/namespace_web/controllers/session_controller_test.exs"
    },
    {:eex, "session_view.ex", "_web/views/session_view.ex"},
    {:eex, "user_controller.ex", "_web/controllers/user_controller.ex"},
    {:eex, "user_controller_test.exs", "test/namespace_web/controllers/user_controller_test.exs"},
    {:eex, "user_view.ex", "_web/views/user_view.ex"},
    {:eex, "phx_token.ex", "_web/auth/token.ex"}
  ]

  @phx_api [
    {:eex, "fallback_controller.ex", "_web/controllers/fallback_controller.ex"},
    {:eex, "auth_view.ex", "_web/views/auth_view.ex"},
    {:eex, "changeset_view.ex", "_web/views/changeset_view.ex"}
  ]

  @phx_html [
    {:eex, "layout_view.ex", "_web/views/layout_view.ex"},
    {:text, "layout_app.html.eex", "_web/templates/layout/app.html.eex"},
    {:text, "page_index.html.eex", "_web/templates/page/index.html.eex"},
    {:eex, "session_new.html.eex", "_web/templates/session/new.html.eex"},
    {:text, "edit.html.eex", "_web/templates/user/edit.html.eex"},
    {:text, "index.html.eex", "_web/templates/user/index.html.eex"},
    {:text, "new.html.eex", "_web/templates/user/new.html.eex"},
    {:text, "form.html.eex", "_web/templates/user/form.html.eex"},
    {:text, "show.html.eex", "_web/templates/user/show.html.eex"}
  ]

  @phx_confirm [
    {:eex, "email.ex", "_web/email.ex"},
    {:eex, "mailer.ex", "_web/mailer.ex"},
    {:eex, "email_test.exs", "test/namespace_web/email_test.exs"},
    {:eex, "confirm_login.ex", "_web/auth/login.ex"},
    {:eex, "confirm_controller.ex", "_web/controllers/confirm_controller.ex"},
    {
      :eex,
      "confirm_controller_test.exs",
      "test/namespace_web/controllers/confirm_controller_test.exs"
    },
    {:eex, "password_reset_controller.ex", "_web/controllers/password_reset_controller.ex"},
    {
      :eex,
      "password_reset_controller_test.exs",
      "test/namespace_web/controllers/password_reset_controller_test.exs"
    },
    {:eex, "password_reset_view.ex", "_web/views/password_reset_view.ex"}
  ]

  @phx_api_confirm [{:eex, "confirm_view.ex", "_web/views/confirm_view.ex"}]

  @phx_html_confirm [
    {:text, "password_reset_new.html.eex", "_web/templates/password_reset/new.html.eex"},
    {:text, "password_reset_edit.html.eex", "_web/templates/password_reset/edit.html.eex"}
  ]

  @phx_remember [{:eex, "auth_utils.ex", "_web/auth/utils.ex"}]

  root = Path.expand("../../../templates", __DIR__)

  all_files =
    @phx_base ++
      @phx_api ++
      @phx_html ++ @phx_confirm ++ @phx_api_confirm ++ @phx_html_confirm ++ @phx_remember

  for {_, source, _} <- all_files do
    @external_resource Path.join(root, source)
    def render(unquote(source)), do: unquote(File.read!(Path.join(root, source)))
  end

  @doc false
  def run(args) do
    check_directory()
    switches = [api: :boolean, confirm: :boolean, remember: :boolean, backups: :boolean]
    {opts, _, _} = OptionParser.parse(args, switches: switches)

    {api, confirm, remember, backups} = {
      opts[:api] == true,
      opts[:confirm] == true,
      opts[:remember] == true,
      opts[:backups] != false
    }

    files =
      @phx_base ++
        case {api, confirm} do
          {true, true} -> @phx_api ++ @phx_confirm ++ @phx_api_confirm
          {true, _} -> @phx_api
          {_, true} -> @phx_html ++ @phx_confirm ++ @phx_html_confirm
          _ -> @phx_html
        end ++ if remember, do: @phx_remember, else: []

    base_name = base_name()
    base = base_name |> Macro.camelize()

    copy_files(
      files,
      base_name: base_name,
      base: base,
      api: api,
      confirm: confirm,
      remember: remember,
      backups: backups
    )

    update_mix(confirm)
    update_config(confirm, base_name, base)

    Mix.shell().info("""

    We are almost ready!

    argon2_elixir has been added to the mix.exs file as a dependency.
    If you want to use bcrypt_elixir or pbkdf2_elixir instead, edit
    the mix.exs file, replacing argon2_elixir with the hashing library
    you want to use.

    #{confirm_deps_message(confirm)}

    For more information about authorization, see the authorize.ex file
    in the controllers directory. You can see how the `user_check` and
    `id_check` functions are used in the user_controller.ex file.

    To run the tests:

        mix test

    And to start the server:

        iex -S mix phx.server

    """)
  end

  defp copy_files(files, opts) do
    for {format, source, target} <- files do
      name = base_name()

      target =
        case target do
          "priv/repo/seeds" ->
            target

          "priv/repo/migrations/timestamp_create_users.exs" ->
            String.replace(target, "timestamp", timestamp(0))

          "priv/repo/migrations/timestamp_create_sessions.exs" ->
            String.replace(target, "timestamp", timestamp(2))

          "test/namespace" <> _ ->
            String.replace(target, "test/namespace", "test/#{name}")

          "test" <> _ ->
            target

          _ ->
            "lib/#{name}" <> target
        end

      contents =
        case format do
          :text -> render(source)
          :eex -> EEx.eval_string(render(source), opts)
        end

      create_file(target, contents, opts[:backups])
    end
  end
end
