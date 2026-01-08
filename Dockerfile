# 多阶段构建：构建阶段
FROM rust:1.75-alpine AS builder

# 安装构建依赖
RUN apk add --no-cache musl-dev

WORKDIR /app

# 先复制依赖配置文件，利用 Docker 缓存
COPY Cargo.toml Cargo.lock ./

# 创建虚拟 src 目录以预编译依赖
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

# 复制实际源代码并重新构建
COPY src ./src
RUN touch src/main.rs && cargo build --release

# 运行阶段：使用最小基础镜像
FROM alpine:3.19

# 安装运行时必要的库（如需要，可选）
RUN apk add --no-cache ca-certificates

# 从构建阶段复制二进制文件
COPY --from=builder /app/target/release/toml /usr/local/bin/toml

# 设置入口点
ENTRYPOINT ["toml"]
