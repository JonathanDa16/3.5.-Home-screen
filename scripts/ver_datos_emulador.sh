#!/usr/bin/env bash
# Consulta los datos del emulador de Cloud Firestore desde la API REST.
#
# Sirve para revisar lo que la app escribió sin abrir la consola del navegador:
#   ./scripts/ver_datos_emulador.sh            # resumen de todos los usuarios
#   ./scripts/ver_datos_emulador.sh <uid>      # detalle de un usuario
#
# El emulador acepta el encabezado "Authorization: Bearer owner" como
# credencial de administrador, así que no hace falta cuenta de Google.
set -u

PROYECTO="${FIREBASE_PROJECT_ID:-demo-cinecatalogo}"
BASE="http://localhost:8080/v1/projects/${PROYECTO}/databases/(default)/documents"
AUTH=(-H "Authorization: Bearer owner")

if ! curl -s -o /dev/null "${AUTH[@]}" "$BASE"; then
  echo "No responde el emulador en $BASE"
  echo "Arráncalo con: firebase emulators:start --only auth,firestore"
  exit 1
fi

UID_FILTRO="${1:-}"

curl -s "${AUTH[@]}" "$BASE/usuarios" | UID_FILTRO="$UID_FILTRO" BASE="$BASE" python3 -c '
import json, os, subprocess, sys

base = os.environ["BASE"]
filtro = os.environ.get("UID_FILTRO", "")
datos = json.load(sys.stdin)


def valor(campo):
    for tipo in ("stringValue", "integerValue", "doubleValue", "timestampValue", "booleanValue"):
        if tipo in campo:
            return campo[tipo]
    return ""


def documentos(uid, coleccion):
    salida = subprocess.run(
        ["curl", "-s", "-H", "Authorization: Bearer owner",
         f"{base}/usuarios/{uid}/{coleccion}"],
        capture_output=True, text=True,
    ).stdout
    try:
        return json.loads(salida).get("documents", [])
    except json.JSONDecodeError:
        return []


for doc in datos.get("documents", []):
    uid = doc["name"].split("/")[-1]
    if filtro and uid != filtro:
        continue
    campos = doc.get("fields", {})
    print(f"usuarios/{uid}")
    print(f"  plataforma      {valor(campos.get("plataforma", {}))}")
    print(f"  creadoEn        {valor(campos.get("creadoEn", {}))}")

    favoritos = documentos(uid, "favoritos")
    print(f"  favoritos/{len(favoritos)}")
    for fav in favoritos:
        c = fav["fields"]
        print("    {:>9}  {:<34} {:>5}".format(
            valor(c.get("peliculaId", {})),
            valor(c.get("titulo", {}))[:34],
            valor(c.get("anio", {})),
        ))

    calificaciones = documentos(uid, "calificaciones")
    print(f"  calificaciones/{len(calificaciones)}")
    for cal in calificaciones:
        c = cal["fields"]
        estrellas = valor(c.get("estrellas", {}))
        print("    {:>9}  {:<34} {:>5} estrellas".format(
            valor(c.get("peliculaId", {})),
            valor(c.get("titulo", {}))[:34],
            estrellas,
        ))
'
