use axum::{
    http,
    routing::{get, Router},
};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let port = std::env::var("PORT")?;

    let app = Router::new().route("/", get(index));

    axum::Server::bind(&format!("0.0.0.0:{port}").parse()?)
        .serve(app.into_make_service())
        .await?;

    Ok(())
}

async fn index() -> http::StatusCode {
    http::StatusCode::IM_A_TEAPOT
}
