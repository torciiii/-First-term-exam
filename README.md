<img width="563" height="153" alt="Captura de pantalla 2025-10-02 140023" src="https://github.com/user-attachments/assets/15d5c79e-422f-45aa-b6ae-c1e0ab5be133" /># -First-term-exam
- Primero se debe crear una carpeta con un main.py y el attack.sh
En el powershell:
- Se debe crear el entorno virtual con: python -m venv .venv
- Lo activas con: .\.venv\Scripts\Activate.ps1
- Se debe instalar: python -m pip install --upgrade pip ; python -m pip install fastapi "uvicorn[standard]" sqlmodel requests
- Se corre con: python -m uvicorn main:app --reload
En el git:
- Debes entrar a tu carpeta de tu proyecto
- Debes ingresar este códgio para tu attack: sed -i 's/\r$//' attack.sh
- Debes darle permisos de ejecucion: chmod +x attack.sh
- Para ejecutar el ataque debes: ./attack.sh

Cuando creas tu usuario con contraseña en la URL:  http://127.0.0.1:8000/docs. Ejecutas el ataque y te da un resultado en git como este:
<img width="563" height="153" alt="Captura de pantalla 2025-10-02 140023" src="https://github.com/user-attachments/assets/6bf3d681-b223-449b-9b79-f34fcd269430" />


