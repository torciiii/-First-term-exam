# -First-term-exam
Se debe estar en el entorno virtual:
python -m venv venv
y activar:
.\.venv\Scripts\Activate.ps1 


Este proyecto esta con contraseñas por defecto:
contraseñas por defecto: 1234, 0000, 1111, 123456, password, admin123.

Crear Usuario:
$body = @{ username = "Torci"; password = "uide"; email = "torci@example.com"; is_active = $true } | ConvertTo-Json -Compress
Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:8000/users" -ContentType "application/json" -Body $body

Ver listas de usuarios:
Invoke-RestMethod -Method Get -Uri "http://127.0.0.1:8000/users"

Ejecutar el ataque:
.\attack.ps1 -URL "http://127.0.0.1:8000/login" -USER "Torci"

Ver resultados:
Get-Content .\attack_log.txt

Borrar usuario:
Invoke-RestMethod -Method Delete -Uri "http://127.0.0.1:8000/users/3"
