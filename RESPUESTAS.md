# Deber 1 — Manejo de estado y streams en Flutter

**Nombre:** Gabriel Zambrano

## 1. setState

Cuando regresé con el botón atrás, el visor siguió mostrando 3 aunque el valor 4 sí se había guardado.

El 4 quedó guardado en disco, pero el estado de la pantalla Visor quedó desactualizado. Para pasar el contador tuvieron que coordinarse la pantalla Visor, la pantalla Control y la navegación.

## 2. Riverpod

Con Riverpod el botón atrás sí funcionó bien. Al regresar, el visor ya mostraba el valor actualizado.

Esto pasa porque el contador vive en el provider y las dos pantallas usan el mismo estado. Ya no tienen que devolverse el valor entre ellas.

## 3. BlocObserver

Con `BlocObserver` pude ver en la consola cada cambio del contador.

Por ejemplo:

`ContadorCubit: 3 -> 4`

Esto sería útil para encontrar errores y saber en qué momento cambió un estado.

## 4. Prueba de arquitectura

### Tabla 1. Salida de los comandos

| Comando | Resultado |
|---|---|
| `git diff version/setstate version/riverpod -- parte_a_contador/lib/domain parte_a_contador/lib/data` | Sin salida |
| `git diff version/setstate version/bloc -- parte_a_contador/lib/domain parte_a_contador/lib/data` | Sin salida |
| `git diff version/setstate version/bloc --stat -- parte_a_contador/lib/presentation` | 3 archivos cambiaron |

Los dos primeros no muestran diferencias porque `domain` y `data` fueron iguales en las tres versiones.

El tercer comando sí muestra diferencias porque lo que cambiamos fue `presentation`.

Si cambiara Riverpod por otro administrador de estado, tendría que cambiar principalmente `presentation` y `main.dart`.

### Tabla 2. Comparación

| | setState | Riverpod | Cubit |
|---|---|---|---|
| ¿Dónde vive el contador? | En la pantalla | En el provider | En el Cubit |
| ¿Las pantallas se pasan datos? | Sí | No | No |
| Archivos de `presentation` que cambiaron | Visor y Control | Provider, Visor y Control | Cubit, Visor y Control |
| ¿Qué pasa con el botón atrás? | Puede quedar desactualizado | Funciona bien | Funciona bien |
| ¿Tuve que tocar `domain`? | No | No | No |

## 5. ¿Cuál usaría?

Si tuviera una sola pantalla, usaría `setState` porque es más simple.

Si tuviera ocho pantallas compartiendo varios datos, usaría Riverpod porque facilita compartir el estado sin estar pasando datos entre pantallas.

`setState` sí es útil cuando el estado es pequeño y solo pertenece a una pantalla o widget.

## 6. Future

Con `Future`, primero consulté la conexión y apareció Wi-Fi. Después apagué el Wi-Fi y la pantalla siguió mostrando Wi-Fi hasta que presioné otra vez "Consultar ahora".

El dato no era incorrecto. Era un dato correcto de un momento anterior que ya había quedado viejo.

## 7. Cancelar el Stream

Si no se hace `cancel()`, cada vez que se abre la pantalla podría quedar una suscripción activa.

Si el usuario entrara y saliera muchas veces, podrían acumularse suscripciones, recibir eventos repetidos y gastar recursos innecesariamente.

## 8. Future vs Stream

`Future` fue como una foto porque mostró la conexión en el momento en que hice la consulta.

`Stream` fue como una película porque siguió detectando cambios. Al apagar el Wi-Fi cambió solo a "Sin conexión" y al volver a encenderlo regresó solo a "Wi-Fi".

Usaría `Future` para:
- cargar un perfil;
- consultar un producto.

Usaría `Stream` para:
- mensajes de un chat;
- cambios de conexión.