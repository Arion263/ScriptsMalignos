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
        echo "Usuarios de correo:"
        awk -v RS='\n' -v remitente="$remitente" '/^(From:|To:|Delivered-To:)[ \t]+/ {
            if ($0 ~ /^(From:|To:|Delivered-To:)[ \t]+/) {
                buffer = $0
                while(getline line && line ~ /^[[:space:]]/) {
                    buffer = buffer line
                }
                if (buffer ~ /@/) {
                    # Modificación para extraer solo usuarios
                    split(buffer, emails, ",")
                    for (i in emails) {
                        if (match(emails[i], /[^[:space:]<>:]*@/)) {
                            usuario = substr(emails[i], RSTART, RLENGTH-1)
                            gsub(/^[[:space:]]+|[[:space:]]+$/, "", usuario)
                            if (usuario ~ /^[a-z]/ && usuario != substr(remitente, 1, index(remitente, "@")-1)) {
                                print usuario
                            }
                        }
                    }
                }
            }
        }' "$archivo" | sort -u
    done
fi

echo "Búsqueda completada."
