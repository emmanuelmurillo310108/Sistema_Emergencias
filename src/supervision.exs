defmodule Emergencia.Supervisor do
  @moduledoc """
  Supervisor que controla el proceso encargado del estado de emergencia.
  """
  use Supervisor

  @doc """
  Inicia el supervisor con nombre registrado.
  """
  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Define el GenServer como hijo y selecciona la estrategia one_for_one.
  """
  def init(:ok) do
    Supervisor.init([{Emergencia.Servidor, []}], strategy: :one_for_one)
  end
end
