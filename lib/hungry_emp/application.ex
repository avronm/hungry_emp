defmodule HungryEmp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HungryEmpWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:hungry_emp, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: HungryEmp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: HungryEmp.Finch},
      # Start a worker by calling: HungryEmp.Worker.start_link(arg)
      # {HungryEmp.Worker, arg},
      # Start to serve requests, typically the last entry
      HungryEmpWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HungryEmp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HungryEmpWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
