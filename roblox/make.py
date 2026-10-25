# Assemble KirasaBuilder.lua : le constructeur avec les deux scripts intégrés.
from pathlib import Path
here = Path(__file__).parent
out = (here / "src/build.lua").read_text()
for tag, name in (("BRAIN", "brain.server.lua"), ("POSE", "pose.client.lua")):
    code = (here / "src" / name).read_text().rstrip("\n")
    assert "]==]" not in code
    out = out.replace(f"--@@{tag}@@", code)
(here / "KirasaBuilder.lua").write_text(out)
