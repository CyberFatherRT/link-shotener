use axum::{
    http,
    routing::{get, Router},
};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let port = std::env::var("PORT").unwrap_or("3000".to_string());
    let addr1 = format!("0.0.0.0:{port}");

    let app = Router::new().route("/", get(index));

    axum::Server::bind(&addr1.parse()?)
        .serve(app.into_make_service())
        .await?;

    Ok(())
}

async fn index() -> http::StatusCode {
    http::StatusCode::IM_A_TEAPOT
}
