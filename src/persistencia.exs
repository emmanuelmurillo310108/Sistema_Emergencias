defmodule Emergencia.Persistencia do
  @moduledoc """
  Funciones para guardar y recuperar el estado desde un archivo de texto.
  """

  @archivo Path.join(__DIR__, "emergencia.txt")

  @doc """
  Serializa el mapa de estado y lo escribe en emergencia.txt.
  """
  def guardar(estado) do
    File.write(@archivo, inspect(estado, pretty: true, limit: :infinity))
  end

  @doc """
  Lee el estado guardado o crea uno vacío si el archivo no está disponible.
  """
  def cargar do
    case File.read(@archivo) do
      {:ok, texto} ->
        {estado, _} = Code.eval_string(texto)
        estado
      {:error, _} ->
        %{usuarios: %{}, sesiones: MapSet.new(), zonas: %{}, necesidades: %{}, recursos: %{}, personas: %{}, mensajes: [], mascotas: %{}, albergues: %{}}
    end
  end
end
