#!/bin/bash

remitente="lindsay.gomez@reduc.edu.cu"
direccion="C:/Users/armin.sifontes/Downloads/Busquedabinaria/"
direccionBuzones="C:/Users/armin.sifontes/Downloads/Busquedabinaria/Buzones"

archivos_encontrados=$(find "$direccion" -maxdepth 1 -type f -exec grep -l -i "$remitente" {} \;)

if [ -z "$archivos_encontrados" ]; then
    echo "No se encontraron archivos con el remitente $remitente"
else 
    for archivo in $archivos_encontrados; do
        echo "=== $archivo ==="
        echo "Direcciones de correo:"
        awk -v RS='\n' '/^(Delivered-To|From|To):/ {
            buffer = $0
            while(getline line && line ~ /^[[:space:]]/) {
                buffer = buffer line
            }
            if (buffer ~ /@/) {
                match(buffer, /[^[:space:]<>:]*@[^[:space:]<>:]*/)
                print substr(buffer, RSTART, RLENGTH)
            }
            if (line !~ /^[[:space:]]/) {
                printf "%s\n", line | "cat"
            }
        }' "$archivo" | sort -u
        
        if grep -i "client-ip:" "$archivo" > /dev/null; then
            echo "IPs únicas del cliente:"
            grep -i "client-ip:" "$archivo" | sed 's/.*client-ip:\([^ ]*\).*/\1/' | sort -u
        fi
        echo
    done
fi

echo "Búsqueda completada."
