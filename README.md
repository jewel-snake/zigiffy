# zigiffy
Rust FFI with Zig

This is a project grown out of curiosity in Rust and Zig. The idea is to make Rust interact with Zig code.
This works, because both languages have the ability to make use of C FFI.

The name `zigiffy` is a combination of `Zig` and `FFI`.
<br>
The counterpart, `rustiffy` also exists: [rustiffy](https://github.com/DutchGhost/rustiffy)

# Build
This projects works in Windows under the WSL.
In order for `build.rs` to call the zig compiler, one needs to set `ZIG_COMPILER` as an environment variable to the full path of where your zig compiler is located:
```
export ZIG_COMPILER=$(which zig)
```
<br>
updated for zig version 0.11.0
