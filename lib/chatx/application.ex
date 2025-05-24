defmodule Chatx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChatxWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:chatx, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Chatx.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Chatx.Finch},
      # Start a worker by calling: Chatx.Worker.start_link(arg)
      # {Chatx.Worker, arg},
      # Start to serve requests, typically the last entry
      ChatxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
