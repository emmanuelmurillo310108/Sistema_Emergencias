defmodule Emergencia.Servidor do
  @moduledoc """
  GenServer que conserva el estado y procesa las operaciones del sistema.
  """

  use GenServer
  alias Emergencia.{Datos, Dominio, Persistencia}

  @doc """
  Inicia el GenServer con el estado recuperado desde persistencia.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, Persistencia.cargar(), name: __MODULE__)
  end

  @doc """
  Entrega el estado inicial al ciclo de vida de GenServer.
  """
  def init(estado), do: {:ok, estado}

  @doc """
  Envía un comando síncrono al servidor registrado.
  """
  def llamada(comando) do
    GenServer.call(__MODULE__, comando)
  end

  @doc """
  Procesa los comandos recibidos, valida los datos y devuelve respuestas al cliente.
  """
  def handle_call({:connect, usuario, clave, nombre, rol, zona}, _from, estado) do
    usuarios = estado.usuarios
    case Map.get(usuarios, usuario) do
      nil ->
        nuevo = Datos.usuario(usuario, clave, nombre, rol, zona)
        responder({:ok, :registrado}, %{estado | usuarios: Map.put(usuarios, usuario, nuevo), sesiones: MapSet.put(estado.sesiones, usuario)})
      %{clave: ^clave} -> responder({:ok, :conectado}, %{estado | sesiones: MapSet.put(estado.sesiones, usuario)})
      _ -> {:reply, {:error, :credenciales}, estado}
    end
  end

  def handle_call({:disconnect, usuario}, _from, estado) do
    responder(:ok, %{estado | sesiones: MapSet.delete(estado.sesiones, usuario)})
  end

  def handle_call({:zona, codigo, nombre, nivel, sectores}, _from, estado) do
    zona = Map.merge(Datos.zona(codigo, nombre, nivel), %{sectores: sectores})
    responder({:ok, codigo}, %{estado | zonas: Map.put(estado.zonas, codigo, zona)})
  end

  def handle_call({:necesidad, id, tipo, cantidad, prioridad, zona, descripcion, usuario}, _from, estado) do
    with :ok <- Dominio.validar_cantidad(cantidad),
         true <- MapSet.member?(estado.sesiones, usuario),
         false <- Map.has_key?(estado.necesidades, id) do
      necesidad = Datos.necesidad(id, tipo, cantidad, prioridad, zona, descripcion, usuario)
      responder({:ok, id}, %{estado | necesidades: Map.put(estado.necesidades, id, necesidad)})
    else
      {:error, motivo} -> {:reply, {:error, motivo}, estado}
      false -> {:reply, {:error, :usuario_no_conectado_o_id_existente}, estado}
      true -> {:reply, {:error, :id_existente}, estado}
    end
  end

  def handle_call({:recurso, id, nombre, categoria, cantidad, unidad, ubicacion}, _from, estado) do
    with :ok <- Dominio.validar_cantidad(cantidad),
         false <- Map.has_key?(estado.recursos, id) do
      recurso = Datos.recurso(id, nombre, categoria, cantidad, unidad, ubicacion)
      responder({:ok, id}, %{estado | recursos: Map.put(estado.recursos, id, recurso)})
    else
      {:error, motivo} -> {:reply, {:error, motivo}, estado}
      true -> {:reply, {:error, :id_existente}, estado}
    end
  end

  def handle_call({:asignar, necesidad_id, recurso_id, cantidad}, _from, estado) do
    with :ok <- Dominio.validar_cantidad(cantidad),
         %{estado: :pendiente} = necesidad <- Map.get(estado.necesidades, necesidad_id),
         %{cantidad: disponible} = recurso <- Map.get(estado.recursos, recurso_id),
         true <- cantidad <= disponible do
      recursos = Map.put(estado.recursos, recurso_id, %{recurso | cantidad: disponible - cantidad})
      actualizada = necesidad |> Map.put(:estado, :asignada) |> Map.put(:recurso, recurso_id)
      necesidades = Map.put(estado.necesidades, necesidad_id, actualizada)
      responder({:ok, :asignada}, %{estado | recursos: recursos, necesidades: necesidades})
    else
      {:error, motivo} -> {:reply, {:error, motivo}, estado}
      nil -> {:reply, {:error, :no_encontrado}, estado}
      false -> {:reply, {:error, :inventario_insuficiente}, estado}
      _ -> {:reply, {:error, :necesidad_no_pendiente}, estado}
    end
  end

  def handle_call({:persona_estado, documento, nuevo_estado}, _from, estado) do
    case Map.get(estado.personas, documento) do
      nil -> {:reply, {:error, :no_encontrada}, estado}
      persona ->
        actualizada = %{persona | estado: nuevo_estado, historial: [nuevo_estado | persona.historial]}
        responder(:ok, %{estado | personas: Map.put(estado.personas, documento, actualizada)})
    end
  end

  def handle_call({:persona, id, nombre, documento, edad, zona, estado_persona}, _from, estado) do
    persona = %{id: id, nombre: nombre, documento: documento, edad: edad, zona: zona, estado: estado_persona, historial: [estado_persona]}
    responder({:ok, id}, %{estado | personas: Map.put(estado.personas, documento, persona)})
  end

  def handle_call({:mensaje, documento, remitente, contenido}, _from, estado) do
    mensaje = %{documento: documento, remitente: remitente, destinatario: documento, contenido: contenido, fecha: DateTime.utc_now(), estado: :pendiente}
    responder({:ok, :guardado}, %{estado | mensajes: [mensaje | estado.mensajes]})
  end

  def handle_call({:transferir, recurso_id, ubicacion, cantidad}, _from, estado) do
    case Map.get(estado.recursos, recurso_id) do
      %{cantidad: disponible} = recurso when cantidad > 0 and cantidad <= disponible ->
        actualizado = %{recurso | cantidad: disponible - cantidad, ubicacion: ubicacion}
        responder(:ok, %{estado | recursos: Map.put(estado.recursos, recurso_id, actualizado)})
      nil -> {:reply, {:error, :no_encontrado}, estado}
      _ -> {:reply, {:error, :inventario_insuficiente_o_cantidad_invalida}, estado}
    end
  end

  def handle_call({:mascota, id, tipo, especie, nombre, color, tamano, zona, contacto}, _from, estado) do
    mascota = %{id: id, tipo: tipo, especie: especie, nombre: nombre, color: color, tamano: tamano, zona: zona, contacto: contacto, estado: :activa, coincidencia: nil}
    responder({:ok, id}, %{estado | mascotas: Map.put(estado.mascotas, id, mascota)})
  end

  def handle_call({:resolver_mascotas, id, otro_id}, _from, estado) do
    with %{estado: :activa} = a <- Map.get(estado.mascotas, id),
         %{estado: :activa} = b <- Map.get(estado.mascotas, otro_id),
         true <- a.tipo != b.tipo do
      a = a |> Map.put(:estado, :resuelta) |> Map.put(:coincidencia, otro_id)
      b = b |> Map.put(:estado, :resuelta) |> Map.put(:coincidencia, id)
      mascotas = estado.mascotas |> Map.put(id, a) |> Map.put(otro_id, b)
      responder(:ok, %{estado | mascotas: mascotas})
    else
      _ -> {:reply, {:error, :coincidencia_invalida}, estado}
    end
  end

  def handle_call({:coincidencias, id}, _from, estado) do
    case Map.get(estado.mascotas, id) do
      nil -> {:reply, {:error, :no_encontrada}, estado}
      mascota ->
        resultados = Enum.filter(estado.mascotas, fn {otro_id, otro} -> otro_id != id and otro.tipo != mascota.tipo and otro.estado == :activa and Dominio.puntaje(mascota, otro) >= 3 end)
        {:reply, resultados, estado}
    end
  end

  def handle_call({:albergue, id, nombre, zona, capacidad}, _from, estado) do
    with :ok <- Dominio.validar_cantidad(capacidad), false <- Map.has_key?(estado.albergues, id) do
      albergue = %{id: id, nombre: nombre, zona: zona, capacidad: capacidad, ocupacion: 0}
      responder({:ok, id}, %{estado | albergues: Map.put(estado.albergues, id, albergue)})
    else
      {:error, motivo} -> {:reply, {:error, motivo}, estado}
      true -> {:reply, {:error, :id_existente}, estado}
    end
  end

  def handle_call({:ingreso, id}, _from, estado) do
    case Map.get(estado.albergues, id) do
      %{ocupacion: ocupacion, capacidad: capacidad} = albergue when ocupacion < capacidad -> responder(:ok, %{estado | albergues: Map.put(estado.albergues, id, %{albergue | ocupacion: ocupacion + 1})})
      nil -> {:reply, {:error, :no_encontrado}, estado}
      _ -> {:reply, {:error, :sin_cupos}, estado}
    end
  end

  def handle_call({:salida, id}, _from, estado) do
    case Map.get(estado.albergues, id) do
      %{ocupacion: ocupacion} = albergue when ocupacion > 0 -> responder(:ok, %{estado | albergues: Map.put(estado.albergues, id, %{albergue | ocupacion: ocupacion - 1})})
      nil -> {:reply, {:error, :no_encontrado}, estado}
      _ -> {:reply, {:error, :ocupacion_cero}, estado}
    end
  end

  def handle_call(:listar_necesidades, _from, estado) do
    prioridad = %{critica: 0, alta: 1, media: 2, baja: 3}
    lista = estado.necesidades |> Map.values() |> Enum.sort_by(&Map.get(prioridad, &1.prioridad, 4))
    {:reply, lista, estado}
  end

  def handle_call(:resumen, _from, estado) do
    resumen = %{zonas: map_size(estado.zonas), necesidades_pendientes: Enum.count(estado.necesidades, fn {_, n} -> n.estado == :pendiente end), recursos: estado.recursos, personas_localizadas: Dominio.recorrer_personas(Map.values(estado.personas)), sectores: Dominio.recorrer_sectores(Map.values(estado.zonas))}
    {:reply, resumen, estado}
  end

  # Guarda el nuevo estado antes de devolver la respuesta.
  defp responder(respuesta, estado) do
    :ok = Persistencia.guardar(estado)
    {:reply, respuesta, estado}
  end
end