SISTEMA DISTRIBUIDO DE COORDINACIÓN Y GESTIÓN DE EMERGENCIAS

Ejecución interactiva:
1. Abra PowerShell en esta carpeta.
2. Ejecute: iex principal.exs
3. Pruebe: Emergencia.register_zone("Z01", "Centro", :alto)
4. Inicie sesión: Emergencia.connect("laura", "1234", "Laura Pérez", :coordinador, "Z01")
5. Registre una necesidad: Emergencia.register_need("N01", :agua, 30, :critica, "Z01", "Punto de atención", "laura")
6. Registre inventario: Emergencia.register_resource("R01", "Agua", :agua, 50, "litros", "Centro de acopio")
7. Asigne: Emergencia.assign_resource("N01", "R01", 30)
8. Consulte: Emergencia.summary()

Los módulos están separados por responsabilidad. Los datos se guardan en emergencia.txt junto al código. GenServer serializa las asignaciones simultáneas al inventario.
