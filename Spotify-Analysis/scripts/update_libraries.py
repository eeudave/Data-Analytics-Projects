import subprocess
# Obtener la lista de librerías desactualizadas
outdated = subprocess.run(
    ["pip", "list", "--outdated", "--format=freeze"],
    capture_output=True, text=True
).stdout.splitlines()

# Filtrar y actualizar cada librería
for line in outdated:
    if not line.startswith("-e"):
        library = line.split("==")[0]
        subprocess.run(["pip", "install", "-U", library])