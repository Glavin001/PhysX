# Stable runtime libraries for the live server

`vast-city.py` and `physics-env.sh` look here before `physx/bin/` when
`VIBE_CITY_DESTRUCTION=native`. `physx/bin/linux.x86_64/release` is the
development build output and changes every time the SDK is rebuilt; the
PhysXGpu module and the static PhysX inside a game-server binary share a
C++ vtable, so a rebuilt module under an older server binary is an ABI
mismatch that only shows up at the next restart.

Copy a qualified `out/<build>/bin/linux.x86_64/release/*.so` here together
with its `REVISION.txt` whenever the server binary is rebuilt against a new
SDK. Never point the live server at `physx/bin` directly.
