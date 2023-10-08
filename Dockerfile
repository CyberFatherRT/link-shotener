ARG PORT
ARG APP_NAME

FROM lukemathwalker/cargo-chef:latest-rust-1.73.0 AS planner

WORKDIR /app
COPY . .
RUN cargo chef prepare --recipe-path recipe.json


FROM lukemathwalker/cargo-chef:latest-rust-1.73.0 AS cacher
WORKDIR /app

RUN rustup target add x86_64-unknown-linux-musl
RUN apt update && apt install -y musl-tools musl-dev
RUN update-ca-certificates

COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json --target x86_64-unknown-linux-musl


FROM rust:1.73.0 AS builder
WORKDIR /app

RUN rustup target add x86_64-unknown-linux-musl
RUN apt update && apt install -y musl-tools musl-dev
RUN update-ca-certificates

ENV USER=cyberfather
ENV UID=10001

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"


COPY . .
COPY --from=cacher /app/target target
COPY --from=cacher /usr/local/cargo /usr/local/cargo

RUN cargo build --target x86_64-unknown-linux-musl --release

FROM scratch AS final
WORKDIR /app
ENV PORT=${PORT}

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/${APP_NAME} .

USER cyberfather:cyberfather

ENTRYPOINT [ "./${APP_NAME}" ]
