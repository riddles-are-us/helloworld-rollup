# 使用 rust nightly 作为基础镜像
FROM rustlang/rust:nightly-2023-06-01-slim as builder

# 安装必要的构建工具
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    nodejs \
    npm \
    git

# 安装 wasm-pack
RUN curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 安装 npm 依赖
RUN cd ts && npm install

# 构建项目
RUN make build

# 使用轻量级镜像作为最终镜像
FROM node:slim

WORKDIR /app

# 从构建阶段复制必要文件
COPY --from=builder /app/ts/node_modules ./ts/node_modules
COPY --from=builder /app/ts/src ./ts/src
COPY --from=builder /app/src/admin.pubkey ./src/admin.pubkey

# 暴露端口（根据你的应用需求修改）
EXPOSE 3000

# 启动服务
CMD ["node", "./ts/src/service.js"]