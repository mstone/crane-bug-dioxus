use dioxus::prelude::*;

pub struct AppProps {}

pub fn app(cx: Scope<AppProps>) -> Element {
    cx.render(rsx!{
        div {
            "Hello, world!"
        }
    }
}

fn main() {
    wasm_logger::init(wasm_logger::Config::default());
    console_error_panic_hook::set_once();

    dioxus_web::launch_with_props(
        app,
        AppProps {},
        dioxus_web::Config::new()
    );
}


