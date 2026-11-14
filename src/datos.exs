defmodule Emergencia.Datos do
  @moduledoc """
  Módulo con constructores de mapas para las entidades principales.
  """

  @doc """
  Crea el mapa con los datos de un usuario y su estado inicial de conexión.
  """
  def usuario(nombre, clave, completo, rol, zona) do
    %{usuario: nombre, clave: clave, nombre: completo, rol: rol, zona: zona, conectado: true}
  end

  @doc """
  Crea una zona con su lista inicial de sectores vacía.
  """
  def zona(codigo, nombre, nivel) do
    %{codigo: codigo, nombre: nombre, nivel: nivel, sectores: []}
  end

  @doc """
  Construye una necesidad nueva con estado pendiente.
  """
  def necesidad(id, tipo, cantidad, prioridad, zona, descripcion, usuario) do
    %{id: id, tipo: tipo, cantidad: cantidad, prioridad: prioridad, zona: zona, descripcion: descripcion, responsable: usuario, estado: :pendiente}
  end

  @doc """
  Crea el mapa que representa un recurso disponible.
  """
  def recurso(id, nombre, categoria, cantidad, unidad, ubicacion) do
    %{id: id, nombre: nombre, categoria: categoria, cantidad: cantidad, unidad: unidad, ubicacion: ubicacion}
  end

end
