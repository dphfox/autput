<p align="center">
<img src="./gh-assets/autput.svg" alt="Autput logo">
</p>
<h3 align="center">
Log Rust prints and panics to Luau for easy debugging.
</h3>

## Install

```
cargo add autput
```

## Brief

When embedding Rust in Luau via Wasynth, there's no good default error handler
or printing functionality. Rust panics cause mysterious error messages and
printed messages go nowhere.

Autput aims to be a minimal useful product for sending panics and prints to Luau
from Rust. You need only initialise Autput, and all the relevant panic handling
and printing features are turned on for you automatically, so you can get to
work right away.

```Rust
fn main() {
	autput::connect();
	info!("This is an info message.");
	warn!("This is a warning message.");
	error!("This is an error message.");
	panic!("This is a panic.");
}
```

- Compatible with the `log` crate
- Send to `print()`, `warn()` (Roblox only), or your own Luau log functions
- Rust panics are redirected to Luau's `error()`

## A note about `println!`

It isn't possible to redirect where standard output goes in Rust. As a result,
Autput can't restore `println!()` functionality, or other similar hardcoded
printing procedures.

Instead, you should use the `log` crate and its macros: `info!()`, `warn!()`
etc.

## License

Licensed the same way as all of my open source projects: BSD 3-Clause + Security Disclaimer.

As with all other projects, you accept responsibility for choosing and using this project.

See [LICENSE](./LICENSE) or [the license summary](https://github.com/dphfox/licence) for details.
