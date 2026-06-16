# SistemaMisiones

Framework de misiones/quests para proyectos en **Godot 4**, listo para integrar en cualquier videojuego RPG, aventura o similar.

---

## ¿Qué puede hacer este sistema?

### ✅ Gestión de misiones
- Definir misiones con título, descripción, icono, categoría y prioridad.
- Estados de misión: `bloqueada`, `activo`, `completada`, `fallida`.
- Soporte para tiempo límite por misión (`tiempoLimiteSegundos`).
- Detectar automáticamente cuando todos los objetivos de una misión están completados y cambiar su estado a `"completada"`.

### ✅ Sistema de objetivos
- **Colección**: recoger X unidades de un tipo de objeto (implementado).
- Estructura preparada para ampliar con: **Eliminación**, **Interacción**, **Entrega** y más.
- Seguimiento de progreso individual por objetivo (`progreso` / `cantidad`).
- Auto-completado al alcanzar la cantidad requerida.

### ✅ Sistema de recompensas
- Ejecutar recompensas automáticamente al completar una misión.
- Tipos implementados:
  - `ImprimirPorConsola` – imprime un mensaje en la consola.
  - `AbrirPuerta` – activa la apertura de una puerta por su ID.
- Arquitectura extensible: añade nuevos tipos heredando de `PlantillaRecompensas`.

### ✅ Persistencia en JSON
- Toda la información de misiones, objetivos y recompensas se almacena en archivos JSON editables:
  - `data/misiones.json`
  - `data/objetivos.json`
  - `data/recompensas.json`
- No requiere base de datos externa.

### ✅ Managers globales (Autoloads)
Accesibles desde cualquier script sin instanciarlos:

| Autoload | Función principal |
|---|---|
| `misionManager` | Leer, filtrar y actualizar misiones |
| `objetivosManager` | Controlar progreso de objetivos |
| `recompensasManager` | Ejecutar recompensas |
| `varGlobales` | Rutas y enumeraciones compartidas |
| `utils` | Utilidades generales |

### ✅ Sistema de ítems recogibles
- Plantilla `PlantillaItems` con campos `id`, `tipo`, `nombre`, `descripción`, `icono`.
- Componente `ItemRecogible` (Button) que actualiza el progreso de la misión correspondiente al recoger el ítem.

### ✅ Escenas de interfaz de usuario
- `inicio.tscn` – pantalla principal con lista de misiones activas.
- `InformacionMision.tscn` – vista detallada de una misión.
- `AvanzarMisionPrueba.tscn` – escena de prueba con botones para avanzar objetivos.
- `ListarMisiones.tscn` – componente reutilizable: tarjeta con icono, título y estado de objetivos.

### ✅ Plugin de editor (GestorDeMisiones)
Panel integrado en el editor de Godot para:
- Crear y editar misiones con interfaz gráfica.
- Asignar objetivos y recompensas a misiones.
- Crear nuevos objetivos y recompensas.
- Consultar y previsualizar el contenido de los JSON.

---

## ¿Qué se puede ampliar fácilmente?

| Funcionalidad | Cómo añadirla |
|---|---|
| Nuevo tipo de objetivo | Crear script heredando de `PlantillaObjetivos` y registrarlo en `objetivos.json` |
| Nuevo tipo de recompensa | Crear script heredando de `PlantillaRecompensas` y añadirlo a `RECOMPENSAS_POR_TIPO` en `RecompensasManager` |
| Guardar/cargar progreso del jugador | Serializar el estado de `misiones.json` al perfil del jugador |
| Misiones encadenadas | Añadir campo `prerequisitos` en el JSON y validarlo en `MissionManager` |
| Temporizadores activos | Implementar cuenta regresiva usando `tiempoLimiteSegundos` y `tiempoRestante` |

---

## Estructura del proyecto

```
/Script
  ├── Manager/        ← Managers globales (misiones, objetivos, recompensas)
  ├── Plantillas/     ← Clases base extensibles
  ├── Objetivos/      ← Implementaciones de tipos de objetivo
  ├── Recompensas/    ← Implementaciones de tipos de recompensa
  ├── Misiones/       ← Lógica por tipo de misión
  ├── Items/          ← Componente de ítem recogible
  └── Escenas/        ← Scripts de interfaz de usuario
/data                 ← JSON: misiones, objetivos, recompensas
/Escenas              ← Archivos .tscn de las escenas UI
/Items                ← Recursos de ítems (.tres)
/resources            ← Imágenes e iconos
/addons/GestorDeMisiones ← Plugin del editor
```

---

## Requisitos

- **Godot 4.x** (probado con 4.5)
- No requiere plugins de terceros