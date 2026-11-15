defmodule Emergencia.Dominio do
  @moduledoc """
  Funciones puras de validación, recursividad y comparación de reportes.
  """

  @doc """
  Acepta cantidades enteras positivas y devuelve error para los demás valores.
  """
  def validar_cantidad(cantidad) when is_integer(cantidad) and cantidad > 0, do:
    :ok

  def validar_cantidad(_) do
    {:error, :cantidad_invalida}
  end

  @doc """
  Cuenta sectores y subsectores recorriendo la jerarquía.
  """
  def recorrer_sectores([]), do: 0

  def recorrer_sectores([sector | resto]) when is_map(sector) do
    1 + recorrer_sectores(Map.get(sector, :sectores, []) ++ resto)
  end

  def recorrer_sectores([_sector | resto]) do
    1 + recorrer_sectores(resto)
  end

  @doc """
  Cuenta las personas con estado localizada.
  """
  def recorrer_personas([]), do: 0

  def recorrer_personas([persona | resto]) do
    (if persona.estado == :localizada, do: 1, else: 0) + recorrer_personas(resto)
  end

  @doc """
  Obtiene el mayor valor de una lista mediante un acumulador.
  """
  def recorrer_mayor([], mayor), do: mayor

  def recorrer_mayor([valor | resto], mayor) do
    recorrer_mayor(resto, max(valor, mayor))
  end

  @doc """
  Busca por id en una lista de mapas y devuelve nil si no hay coincidencias
  """
  def recorrer_busqueda([], _id), do: nil

  def recorrer_busqueda([%{id: id} = elemento | _], id), do: elemento

  def recorrer_busqueda([_ | resto], id) do
    recorrer_busqueda(resto, id)
  end

  @doc """
  Cuenta coincidencias en especie, color, tamaño y zona entre dos mascotas.
  """
  def puntaje(a, b) do
    Enum.count([:especie, :color, :tamano, :zona], fn campo -> Map.get(a, campo) == Map.get(b, campo) end)
  end
end
