# Assemble KirasaBuilder.lua : le constructeur avec le script d'animation intégré.
from pathlib import Path
here = Path(__file__).parent
build = (here / "src/build.lua").read_text()
anim = (here / "src/animate.server.lua").read_text().rstrip("\n")
assert "]==]" not in anim
(here / "KirasaBuilder.lua").write_text(build.replace("--@@ANIMATE@@", anim))
