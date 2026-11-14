# Carga los módulos del sistema desde esta misma carpeta.
Code.require_file("datos.exs", __DIR__)
Code.require_file("persistencia.exs", __DIR__)
Code.require_file("dominio.exs", __DIR__)
Code.require_file("servidor.exs", __DIR__)
Code.require_file("supervision.exs", __DIR__)
Code.require_file("emergencia.exs", __DIR__)

# Inicia el árbol de supervisión y el servidor.
{:ok, _pid} = Emergencia.iniciar()
IO.puts("Sistema de emergencias listo para usar")
IO.puts("Primero ejecute iex principal.exs para usar el sistema")
