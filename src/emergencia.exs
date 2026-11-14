defmodule Emergencia do
  @moduledoc """
  Fachada pública que envía las operaciones al servidor GenServer.
  """

  alias Emergencia.Servidor, as: S

  @doc """
  Inicia el supervisor que mantiene el servidor de la aplicación.
  """
  def iniciar do
    Emergencia.Supervisor.start_link([])
  end

  @doc """
  Conecta al usuario o solicita su registro automático.
  """
  def connect(usuario, clave, nombre, rol, zona) do
    S.llamada({:connect, usuario, clave, nombre, rol, zona})
  end

  @doc """
  Cierra la sesión del usuario indicado.
  """
  def disconnect(usuario) do
    S.llamada({:disconnect, usuario})
  end

  @doc """
  Registra una zona y sus sectores.
  """
  def register_zone(codigo, nombre, nivel, sectores \\ []) do
    S.llamada({:zona, codigo, nombre, nivel, sectores})
  end

  @doc """
  Envía una nueva necesidad con cantidad, prioridad y responsable.
  """
  def register_need(id, tipo, cantidad, prioridad, zona, descripcion, usuario) do
    S.llamada({:necesidad, id, tipo, cantidad, prioridad, zona, descripcion, usuario})
  end

  @doc """
  Registra un recurso en el inventario.
  """
  def register_resource(id, nombre, categoria, cantidad, unidad, ubicacion) do
    S.llamada({:recurso, id, nombre, categoria, cantidad, unidad, ubicacion})
  end

  @doc """
  Solicita una asignación de inventario para una necesidad.
  """
  def assign_resource(need_id, resource_id, cantidad) do
    S.llamada({:asignar, need_id, resource_id, cantidad})
  end

  @doc """
  Registra una persona afectada y su estado inicial.
  """
  def register_persona(id, nombre, documento, edad, zona, estado) do
    S.llamada({:persona, id, nombre, documento, edad, zona, estado})
  end

  @doc """
  Guarda un mensaje destinado a la persona indicada.
  """
  def send_family_message(documento, remitente, contenido) do
    S.llamada({:mensaje, documento, remitente, contenido})
  end

  @doc """
  Registra un reporte de mascota perdida o encontrada.
  """
  def report_pet(id, tipo, especie, nombre, color, tamano, zona, contacto) do
    S.llamada({:mascota, id, tipo, especie, nombre, color, tamano, zona, contacto})
  end

  @doc """
  Solicita posibles coincidencias para el reporte indicado.
  """
  def match_pets(id) do
    S.llamada({:coincidencias, id})
  end

  @doc """
  Registra un albergue con su capacidad.
  """
  def register_shelter(id, nombre, zona, capacidad) do
    S.llamada({:albergue, id, nombre, zona, capacidad})
  end

  @doc """
  Registra el ingreso de una persona al albergue.
  """
  def register_entry(id) do
    S.llamada({:ingreso, id})
  end

  @doc """
  Actualiza el estado de una persona y su historial.
  """
  def update_persona(documento, nuevo_estado) do
    S.llamada({:persona_estado, documento, nuevo_estado})
  end

  @doc """
  Solicita el movimiento de una cantidad de recurso.
  """
  def transfer_resource(id, ubicacion, cantidad) do
    S.llamada({:transferir, id, ubicacion, cantidad})
  end

  @doc """
  Confirma y cierra dos reportes de mascotas relacionados.
  """
  def resolve_pets(id, otro_id) do
    S.llamada({:resolver_mascotas, id, otro_id})
  end

  @doc """
  Registra la salida de una persona del albergue.
  """
  def register_exit(id) do
    S.llamada({:salida, id})
  end

  @doc """
  Devuelve las necesidades ordenadas por prioridad.
  """
  def list_needs do
    S.llamada(:listar_necesidades)
  end

  @doc """
  Solicita el resumen general del estado del sistema.
  """
  def summary do
    S.llamada(:resumen)
  end

  @doc """
  Lanza dos tareas que intentan asignar el mismo recurso.
  """
  def concurrencia_demo do
    tareas = for usuario <- ["laura", "ana"] do
      Task.async(fn -> assign_resource("N-AGUA-#{usuario}", "R-AGUA", 30) end)
    end
    Enum.map(tareas, &Task.await(&1, 5_000))
  end
end
