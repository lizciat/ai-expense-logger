import json
import os
from datetime import date, datetime
from zoneinfo import ZoneInfo

import dotenv
import google.generativeai as gen

dotenv.load_dotenv()
gen.configure(api_key=os.environ["GEMINI_API_KEY"])
print(os.environ["GEMINI_API_KEY"])
TZ = ZoneInfo("Africa/Nairobi")

MODEL = "models/gemini-2.0-flash"

SYSTEM_PROMPT = """
Eres un asistente que analiza mensajes de gastos y devuelve un JSON con información estructurada.
Tu tarea es interpretar el texto del usuario, incluso si está escrito de forma libre, y clasificarlo correctamente.

Debes:
1. Detectar el monto y la moneda.
2. Convertir el monto a USD (usa tasas aproximadas, no importa si no son exactas).
3. Asignar la categoría más cercana **entre las siguientes**:
   ["comida", "transporte", "vivienda", "salud", "educación", "ocio", "ropa", "servicios", "mascotas","otros"]
   Si el texto no coincide claramente con una de ellas, elige "otros".
4. Crear una descripción corta y clara del gasto.
5. Incluir la fecha en formato YYYY-MM-DD.
6. Responder **solo** con un JSON válido, sin explicaciones, comentarios ni texto adicional.


El JSON DEBE ser exactamente este:
{
  "monto_original": float,
  "moneda_original": string,
  "monto_usd": float,
  "categoria": string,
  "descripcion": string,
  "fecha": "YYYY-MM-DD" | null
}

Reglas:
- Si el usuario menciona una moneda (USD, COP, EUR, GBP, etc.), identifícala.
- Si no menciona una moneda, asume que está en KES.
- Convierte el monto a dólares (USD) usando una tasa de cambio aproximada del día.
- NO inventes fechas.
- Si el usuario NO menciona una fecha explícita (o relativa), devuelve "fecha": null.
- No incluyas comentarios ni texto fuera del JSON."""

def parse_gasto(texto):
    prompt = SYSTEM_PROMPT + "\nUsuario: " + texto

    response = gen.GenerativeModel(
        MODEL,
        generation_config={
            "response_mime_type": "application/json"   # <-- LA CLAVE
        },
    ).generate_content(prompt)

    data = json.loads(response.text)

    # Set default date
    if not data.get("fecha"):
        data["fecha"] = date.today().isoformat()

    # Si no se especificó tasa, dejamos el monto original como USD
    if not data.get("monto_usd"):
        data["monto_usd"] = data.get("monto_original", 0.0)

    return data