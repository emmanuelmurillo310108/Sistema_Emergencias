SISTEMA DISTRIBUIDO DE COORDINACIÓN Y GESTIÓN DE EMERGENCIAS

Antes que nada, al momento de ejecutar los comandos, escriba lo que se encuentra entre las comillas (""). NO COPIE LAS COMILLAS, SOLO LO DE ADENTRO

Ejecución interactiva:
1. Abra PowerShell en la carpeta raíz del proyecto (Terminal)

2. Ejecute: "cd .\src" y luego "iex.bat -r .\principal.exs" o puede simplemente usar "iex.bat -r .\src\principal.exs"
    A. Compruebe que el servidor está funcionando y se encuentra activo mediante "Process.whereis(Emergencia.Servidor)". Si está funcionando, debe salir un PID: "#PID<0.137.0>" | Si no está funcionando, debe salir: "nil"
    
3. Pruebe: "Emergencia.register_zone("Z01", "Centro", :alto)"
    R: Debe esperar: "{:ok, "Z01"}"

4. Inicie sesión: "Emergencia.connect("laura", "1234", "Laura Pérez", :coordinador, "Z01")"
    R: La primera vez debe esperar: "{:ok, :registrado}". En caso de que Laura ya exista y la contraseña coincide, debe esperar: "{:ok, :conectado}"

5. Registre una necesidad: "Emergencia.register_need("N01", :agua, 30, :critica, "Z01", "Punto de atención", "laura")"
    R: Debe esperar: "{:ok, "N01"}"

6. Registre inventario: "Emergencia.register_resource("R01", "Agua", :agua, 50, "litros", "Centro de acopio")"
    R: Debe esperar: "{:ok, "R01"}"

7. Asigne: "Emergencia.assign_resource("N01", "R01", 30)"
    R: Debe esperar: "{:ok, :asignada}"

8. Consulte: "Emergencia.summary()"
    R: Compruebe que R01 conserva 20 litros y que necesidades_pendientes vale 0, porque N01 cambió a estado asignada.

9. Registre una persona localizada: "Emergencia.register_persona("P01", "Andrés", "DOC01", 25, "Z01", :localizada)"
    R: Debe esperar: "{:ok, "P01"}"

10. Envíe un mensaje familiar: "Emergencia.send_family_message("DOC01", "Laura", "Andrés está localizado")"
    R: Debe esperar: "{:ok, :guardado}"

11. Registre una mascota perdida: "Emergencia.report_pet("M01", :perdida, "perro", "Luna", "negro", "mediano", "Z01", "555-0101")"
    R: Debe esperar: "{:ok, "M01"}"

12. Registre una mascota encontrada: "Emergencia.report_pet("M02", :encontrada, "perro", "desconocido", "negro", "mediano", "Z01", "555-0102")"
    R: Debe esperar: "{:ok, "M02"}"

13. Busque posibles coincidencias: "Emergencia.match_pets("M01")"
    R: Debe aparecer M02 entre las posibles coincidencias

14. Confirme la coincidencia: "Emergencia.resolve_pets("M01", "M02")"
    R: Debe esperar: ":ok"

15. Registre un albergue: "Emergencia.register_shelter("A01", "Albergue Norte", "Z01", 150)"
    R: Debe esperar: "{:ok, "A01"}"

16. Registre el ingreso de una persona: "Emergencia.register_entry("A01")"
    R: Debe esperar: ":ok"

17. Registre la salida de una persona: "Emergencia.register_exit("A01")"
    R: Debe esperar: ":ok"

18. Conecte a Ana para la prueba concurrente: "Emergencia.connect("ana", "5678", "Ana Ruiz", :voluntario, "Z01")"
    R: La primera vez debe esperar: "{:ok, :registrado}". En caso de que Ana ya exista y la contraseña coincide, debe esperar: "{:ok, :conectado}"

19. Registre el recurso de la prueba concurrente: "Emergencia.register_resource("R-AGUA", "Agua para prueba de concurrencia", :agua, 50, "litros", "Centro de acopio")"
    R: Debe esperar: "{:ok, "R-AGUA"}"

20. Registre la necesidad de Laura: "Emergencia.register_need("N-AGUA-laura", :agua, 30, :critica, "Z01", "Solicitud de Laura", "laura")"
    R: Debe esperar: "{:ok, "N-AGUA-laura"}"

21. Registre la necesidad de Ana: "Emergencia.register_need("N-AGUA-ana", :agua, 30, :alta, "Z01", "Solicitud de Ana", "ana")"
    R: Debe esperar: "{:ok, "N-AGUA-ana"}"

22. Ejecute las asignaciones simultáneas: "Emergencia.concurrencia_demo()"
    R: Debe obtener una asignación exitosa y otra respuesta de inventario insuficiente. El orden puede variar. No se deben asignar 60 litros cuando solo hay 50.
