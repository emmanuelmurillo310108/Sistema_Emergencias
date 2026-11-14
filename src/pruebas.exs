ExUnit.start()
Code.require_file("datos.exs", __DIR__)
Code.require_file("dominio.exs", __DIR__)

defmodule Emergencia.DominioTest do
  @moduledoc """
  Módulo de pruebas unitarias para las funciones puras del dominio.
  """
  use ExUnit.Case
  alias Emergencia.Dominio

  # Comprueba el rechazo de cero y cantidades negativas.
  test "rechaza cantidades no positivas" do
    assert Dominio.validar_cantidad(0) == {:error, :cantidad_invalida}
    assert Dominio.validar_cantidad(-1) == {:error, :cantidad_invalida}
  end

  # Comprueba que una cantidad positiva sea válida.
  test "acepta cantidad positiva" do
    assert Dominio.validar_cantidad(1) == :ok
  end

  # Verifica el conteo de sectores anidados.
  test "cuenta sectores de forma recursiva" do
    zonas = [%{sectores: [%{sectores: [%{nombre: "Punto"}]}]}]
    assert Dominio.recorrer_sectores(zonas) == 2
  end

  # Verifica el puntaje de coincidencia de mascotas.
  test "calcula similitud usando atributos de mascota" do
    a = %{especie: "perro", color: "negro", tamano: "mediano", zona: "norte"}
    b = %{especie: "perro", color: "negro", tamano: "grande", zona: "norte"}
    assert Dominio.puntaje(a, b) == 3
  end
end
