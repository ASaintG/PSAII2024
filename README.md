# PSAII Project

Este proyecto tiene como objetivo configurar un entorno de desarrollo que incluye Node-RED, MySQL y Grafana. El script automatiza la instalación y configuración de estas herramientas, así como la importación de un flujo de Node-RED y un dashboard de Grafana.

## Requisitos

- **XAMPP**: Asegúrese de que XAMPP esté instalado y ejecutándose antes de continuar con la instalación. Puede descargar XAMPP desde Apache Friends.

## Instalación

Siga estos pasos para instalar y configurar el entorno:

1. **Clone el repositorio**:
    ```bash
    git clone https://github.com/tu-usuario/tu-repositorio.git
    cd tu-repositorio
    ```

2. **Asegúrese de que XAMPP esté instalado y ejecutándose**:
    - Descargue e instale XAMPP desde Apache Friends.
    - Ejecute XAMPP:
        ```bash
        sudo /opt/lampp/lampp start
        ```

3. **Ejecute el script de instalación**:
    ```bash
    chmod +x PASII1.sh
    ./PASII1.sh
    ```

## Uso

El script proporciona un menú con las siguientes opciones:

1. **Instalar aplicaciones PSA**:
    - Instala Node.js, Node-RED, MySQL y Grafana.
    - Configura Node-RED con el flujo especificado en `proyecto.json`.
    - Configura Grafana con el dashboard especificado en `dashboard.json`.

2. **Desinstalar aplicaciones PSA**:
    - Desinstala Node-RED, MySQL y Grafana.
    - Elimina la base de datos `informacion_pc`.

3. **Abrir dashboard de Grafana**:
    - Abre el dashboard de Grafana en el navegador.

4. **Salir**:
    - Sale del menú.

## Notas Importantes

- **XAMPP**: Es crucial que XAMPP esté instalado y ejecutándose antes de ejecutar el script de instalación. XAMPP se utiliza para gestionar MySQL.
- **Archivos JSON**: Asegúrese de que los archivos `proyecto.json` y `dashboard.json` estén en la carpeta `PASII` antes de ejecutar el script.

## Contribuciones

Las contribuciones son bienvenidas. Por favor, haga un fork del repositorio y envíe un pull request con sus cambios.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT. Consulte el archivo `LICENSE` para obtener más detalle
