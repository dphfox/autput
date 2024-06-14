<p align="center">
<img src="./gh-assets/autput.svg" alt="Autput logo">
</p>
<h3 align="center">
Log Rust prints and panics to Luau for easy debugging.
</h3>

## Install

WIP

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

## Contributions and maintenance

This is [a certified Daniel P H Fox Side Project™](https://fluff.blog/2024/04/10/i-dont-want-to-be-a-maintainer.html), which I am sharing because I personally wanted it to exist in the world. I might maintain it. I might not.
Contributions are welcome, but I do not make guarantees about those either.

Feel free to use Autput, but if you're about to depend on it big time, the security audit's on you. If, for whatever reason, you end up in a spot of bother, you should probably not have used a random project from someone's GitHub without inspecting what it does properly. I take no responsibility for that.