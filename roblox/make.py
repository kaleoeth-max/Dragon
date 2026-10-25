# Génère les fichiers à utiliser dans Roblox Studio :
#   KirasaBuilder.lua : version en pièces Roblox (à coller seul dans la barre de commande)
#   Kirasa.obj + KirasaRig.lua : version maillage 3D, sans jointures (importer puis coller)
# Le maillage est calculé en lançant build.lua hors de Roblox avec l'interpréteur luau
# (chemin dans la variable d'environnement LUAU, sinon « luau » dans le PATH).
import os
import subprocess
from pathlib import Path

here = Path(__file__).parent
src = here / "src"


def embed(text):
    for tag, name in (("BRAIN", "brain.server.lua"), ("POSE", "pose.client.lua")):
        code = (src / name).read_text().rstrip("\n")
        assert "]==]" not in code
        text = text.replace(f"--@@{tag}@@", code)
    return text


(here / "KirasaBuilder.lua").write_text(embed((src / "build.lua").read_text()))

harness = "KIRASA_EXPORT = {}\n" + (here / "tools/mock.lua").read_text() + "\ndo\n" + \
    (src / "build.lua").read_text() + "\nend\n" + (here / "tools/export.lua").read_text()
tmp = here / "tools/.export_run.lua"
tmp.write_text(harness)
try:
    out = subprocess.run([os.environ.get("LUAU", "luau"), str(tmp)], capture_output=True, text=True)
    if out.returncode:
        raise SystemExit(out.stdout[-2000:] + out.stderr)
    out = out.stdout
finally:
    tmp.unlink()
obj = out.split("@@OBJ\n", 1)[1].split("\n@@DATA\n", 1)[0]
data = out.split("\n@@DATA\n", 1)[1].strip()
(here / "Kirasa.obj").write_text(obj + "\n")
(here / "KirasaRig.lua").write_text(embed((src / "rig.lua").read_text()).replace("--@@DATA@@", data))
print("ok :", obj.count("\nf "), "triangles,", obj.count("\no "), "morceaux")
