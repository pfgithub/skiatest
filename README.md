a copy of the skia example thing but with zig instead

- 1: https://skia.org/user/download
- 2: `bin/gn gen out/Shared --args='is_official_build=true is_component_build=true'`
- 3: `ninja -C out/Shared` and wait a while. doesn't need too much ram.
- more info on https://skia.org/user/build
- 4: copy `skia/include/c` → `deps/skia/include/c`
- 5: copy `skia/out/Shared/libskia.so` → `/usr/lib/libskia.so` (there is probably a way to statically link this but making a static build has link errors when I try to use skia.a. maybe because then it can't dynamically link 31 other libraries automatically.)
- 6: `zig build run`