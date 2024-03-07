# nix-esp32-hello-world

this repo does not use rust standard library (no_std)

- [x] cargo build/run - esp32c3
- [ ] cargo build/run - esp32 (requires espup support for nixos)
- [ ] nix build - fails
- [ ] nix run - fails

## current issue

```sh
nix build
```
= note: x86_64-unknown-linux-gnu-gcc: error: unrecognized command-line option '-flavor'
       >           x86_64-unknown-linux-gnu-gcc: error: unrecognized command-line option '--as-needed'; did you mean '-mno-needed'?
       >           x86_64-unknown-linux-gnu-gcc: error: unrecognized command-line option '--gc-sections'; did you mean '--data-sections'?
       >           
       >
       > error: could not compile `hello_world` (bin "hello_world") due to 1 previous error
