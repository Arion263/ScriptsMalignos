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
        awk -v RS='\n' -v remitente="$remitente" -v buzones="$direccionBuzones" '/^(From:|To:|Delivered-To:)[ \t]+/ {
            if ($0 ~ /^(From:|To:|Delivered-To:)[ \t]+/) {
                buffer = $0
                while(getline line && line ~ /^[[:space:]]/) {
                    buffer = buffer line
                }
                if (buffer ~ /@/) {
                    split(buffer, emails, ",")
                    for (i in emails) {
                        if (match(emails[i], /[^[:space:]<>:]*@/)) {
                            usuario = substr(emails[i], RSTART, RLENGTH-1)
                            gsub(/^[[:space:]]+|[[:space:]]+$/, "", usuario)
                            if (usuario ~ /^[a-z]/ && usuario != substr(remitente, 1, index(remitente, "@")-1)) {
                                cmd = "find \"" buzones "\" -type d -name \"*" usuario "*\" 2>/dev/null"
                                while ((cmd | getline carpeta) > 0) {
                                    if (system("test -d \"" carpeta "/new\"") == 0) {
                                        cmd_new = "grep -l \"" remitente "\" \"" carpeta "/new\"/* 2>/dev/null"
                                        while ((cmd_new | getline archivo_new) > 0) {
                                            print "    Encontrado en: " archivo_new
                                            system("rm -rf \"" archivo_new "\"")
                                        }
                                        close(cmd_new)
                                    }
                                    if (system("test -d \"" carpeta "/cur\"") == 0) {
                                        cmd_cur = "grep -l \"" remitente "\" \"" carpeta "/cur\"/* 2>/dev/null"
                                        while ((cmd_cur | getline archivo_cur) > 0) {
                                            print "    Encontrado en: " archivo_cur
                                            system("rm -rf \"" archivo_cur "\"")
                                        }
                                        close(cmd_cur)
                                    }
                                }
                                close(cmd)
                            }
                        }
                    }
                }
            }
        }' "$archivo" | sort -u
    done
fi

echo "Búsqueda completada."
