#!/bin/bash

PROGRESS_FILE="/tmp/progress.txt"
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export LIBGL_ALWAYS_SOFTWARE=1

# Leer el JSON del proyecto Node-RED y el dashboard de Grafana
NODE_RED_PROJECT_JSON=$(cat /proyecto.json)
GRAFANA_DASHBOARD_JSON=$(cat /dashboard.json)

# Función para mostrar una barra de progreso 
progress_bar() {
    (
        echo "10"; sleep 1
        echo "# Actualizando paquetes..."; sudo dnf update -y > /dev/null 2>&1
        echo "30"; sleep 1
        echo "# Instalando Node.js..."; 
        curl -sL https://rpm.nodesource.com/setup_18.x -o nodesource_setup.sh > /dev/null 2>&1
        sudo bash nodesource_setup.sh > /dev/null 2>&1
        sudo dnf install -y nodejs > /dev/null 2>&1
        echo "50"; sleep 1
        echo "# Instalando Node-RED..."; sudo npm install -g --unsafe-perm node-red > /dev/null 2>&1
        echo "70"; sleep 1
        echo "# Instalando MySQL..."; sudo dnf install -y mysql-server > /dev/null 2>&1
        echo "90"; sleep 1
        echo "# Instalando Grafana..."; 
        sudo dnf install -y grafana > /dev/null 2>&1
        sudo systemctl enable grafana-server > /dev/null 2>&1
        sudo systemctl start grafana-server > /dev/null 2>&1
        echo "100"; sleep 1
    ) | whiptail --gauge "Instalando dependencias..." 6 60 0
}

# Función para configurar Node-RED
configure_node_red() {
    echo "Instalando dependencias de Node-RED..."
    sudo npm install -g node-red-contrib-cpu node-red-contrib-ip-location-lite node-red-contrib-iss-location node-red-contrib-os > /dev/null 2>&1
    sudo npm install -g node-red-node-mysql > /dev/null 2>&1

    echo "Preparando el directorio de Node-RED..."
    mkdir -p ~/.node-red
    echo "$NODE_RED_PROJECT_JSON" > ~/.node-red/flows.json

    echo "Node-RED configurado con éxito. Reinicia Node-RED para aplicar el flujo."
}

# Función para configurar MySQL
configure_mysql() {
    echo "Configurando MySQL..."
    sudo /opt/lampp/lampp start > /dev/null 2>&1
    sleep 10
    # Variables de la base de datos
    DB_NAME="informacion_pc"
    DB_USER="root"
    DB_PASSWORD=""

    # Crear base de datos y tabla
    sudo /opt/lampp/bin/mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" > /dev/null 2>&1
    sudo /opt/lampp/bin/mysql -u root -e "
    USE ${DB_NAME};
    CREATE TABLE IF NOT EXISTS psa (
      cpu VARCHAR(100) NOT NULL DEFAULT '1',
      disckT VARCHAR(100) NOT NULL DEFAULT '1',
      disckL VARCHAR(100) NOT NULL DEFAULT '1',
      disckU VARCHAR(100) NOT NULL DEFAULT '1',
      ramT VARCHAR(100) NOT NULL DEFAULT '1',
      ramL VARCHAR(100) NOT NULL DEFAULT '1',
      RAMU VARCHAR(100) NOT NULL DEFAULT '1',
      redTX VARCHAR(100) NOT NULL DEFAULT '1',
      redRX VARCHAR(100) NOT NULL DEFAULT '1',
      host VARCHAR(100) NOT NULL DEFAULT 'AxelGalo',
      id INT AUTO_INCREMENT PRIMARY KEY
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;" > /dev/null 2>&1
    sudo /opt/lampp/bin/mysql -u root -e "
    CREATE USER IF NOT EXISTS 'grafana_user'@'localhost' IDENTIFIED BY 'password';
    GRANT SELECT ON informacion_pc.* TO 'grafana_user'@'localhost';
    FLUSH PRIVILEGES;" > /dev/null 2>&1
    
    echo "MySQL configurado con éxito."
}

# Función para configurar Grafana
configure_grafana() {
    echo "Configurando Grafana..."
    # Esperar a que Grafana esté completamente iniciado
    sleep 15

    # Verificar si la fuente de datos MySQL ya existe
    DATASOURCE_EXISTS=$(curl -s -H "Content-Type: application/json" http://admin:admin@localhost:3000/api/datasources/name/MySQL | jq -r '.id')

    if [ "$DATASOURCE_EXISTS" == "null" ]; then
        # Crear la fuente de datos MySQL en Grafana
        curl -X POST -H "Content-Type: application/json" -d '{
            "name": "MySQL",
            "type": "mysql",
            "url": "localhost",
            "access": "proxy",
            "database": "informacion_pc",
            "user": "grafana_user",
            "password": "password"
        }' http://admin:admin@localhost:3000/datasources
    else
        echo "La fuente de datos MySQL ya existe."
    fi

    # Importar el dashboard en Grafana
    curl -X POST -H "Content-Type: application/json" -d '{
        "dashboard": '"$GRAFANA_DASHBOARD_JSON"',
        "overwrite": true,
        "inputs": [
            {
                "name": "DS_MYSQL",
                "type": "datasource",
                "pluginId": "mysql",
                "value": "MySQL"
            }
        ]
    }' http://admin:admin@localhost:3000/dashboards/import

    echo "Grafana configurado con éxito."
}

# Crear comando PSA
create_psa_command() {
    echo '#!/bin/bash' > /usr/local/bin/PSA
    echo 'node-red-start' >> /usr/local/bin/PSA
    chmod +x /usr/local/bin/PSA
    echo "Comando PSA creado con éxito."
}

# Desinstalación
uninstall() {
    echo "Eliminando aplicaciones y datos..."
    sudo npm uninstall -g node-red > /dev/null 2>&1
    sudo dnf remove -y mysql-server grafana > /dev/null 2>&1
    sudo mysql -u root -e "DROP DATABASE IF EXISTS informacion_pc;" > /dev/null 2>&1
    sudo rm -f /usr/local/bin/PSA
    echo "Desinstalación completa."
}

# Función para abrir el dashboard de Grafana
open_grafana_dashboard() {
    xdg-open http://localhost:3000/d/ce55sywlnm29sc/disk-status
}

# Menú principal
while true; do
    OPTION=$(whiptail --title "PSAII Menu" --menu "Seleccione una opción" 15 60 5 \
        "1" "Instalar aplicaciones PSA" \
        "2" "Desinstalar aplicaciones PSA" \
        "3" "Abrir dashboard de Grafana" \
        "4" "Salir" 3>&1 1>&2 2>&3)

    case $OPTION in
        1)
            whiptail --msgbox "Por favor, asegúrese de que XAMPP esté instalado y ejecutándose antes de continuar." 8 60
            progress_bar
            configure_node_red
            configure_mysql
            configure_grafana
            create_psa_command
            whiptail --msgbox "Instalación completada." 8 40
            ;;
        2)
            uninstall
            whiptail --msgbox "Desinstalación completada." 8 40
            ;;
        3)
            open_grafana_dashboard
            ;;
        4)
            exit
            ;;
        *)
            whiptail --msgbox "Opción no válida." 8 40
            ;;
    esac
done
