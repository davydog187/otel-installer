defmodule Mix.Tasks.OtelInstaller.Install do
  use Igniter.Mix.Task

  @example "mix otel.install --example arg"

  @shortdoc "A short description of your task"
  @moduledoc """
  #{@shortdoc}

  Longer explanation of your task

  ## Example

  ```bash
  #{@example}
  ```

  ## Options

  * `--example-option` or `-e` - Docs for your option
  """

  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      # Groups allow for overlapping arguments for tasks by the same author
      # See the generators guide for more.
      group: :otel_installer,
      # dependencies to add
      adds_deps: [],
      # dependencies to add and call their associated installers, if they exist
      installs: [],
      # An example invocation

      # A list of environments that this should be installed in.
      example: @example,
      only: nil,

      # a list of positional arguments, i.e `[:file]`
      positional: [],
      # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
      # This ensures your option schema includes options from nested tasks
      composes: [],
      # `OptionParser` schema
      schema: [],
      # Default values for the options in the `schema`.
      defaults: [],
      # CLI aliases
      aliases: [],
      # A list of options in the schema that are required
      required: []
    }
  end

  def igniter(igniter, argv) do
    # extract positional arguments according to `positional` above
    {arguments, argv} = positional_args!(argv)
    # extract options according to `schema` and `aliases` above
    options = options!(argv)

    app_name = Igniter.Project.Application.app_name(igniter) |> dbg()
    {app_module, _} = Igniter.Project.Application.app_module(igniter) |> dbg()

    # Do your work here and return an updated igniter
    igniter
    |> Igniter.Project.Deps.add_dep({:opentelemetry_exporter, "~> 1.8"}, append?: true)
    |> Igniter.Project.Deps.add_dep({:opentelemetry, "~> 1.5"}, append?: true)
    |> Igniter.Project.Deps.add_dep({:opentelemetry_api, "~> 1.4"}, append?: true)
    |> Igniter.Project.Config.configure(
      "runtime.exs",
      :opentelemetry,
      [:resource, :service],
      {:code,
       Sourceror.parse_string!("""
       [name: "api", namespace: #{inspect(app_module)}]
       """)}
    )
    |> Igniter.Project.Config.configure(
      "runtime.exs",
      :opentelemetry,
      [:resource, :host],
      {:code,
       Sourceror.parse_string!("""
       [name: System.fetch_env!("HOST")]
       """)}
    )
  end
end
