# 언어 툴체인 경로. 각 도구의 설치 위치만 PATH에 잇는다.
# python은 mise가 버전과 shim을 관리하므로 여기서 다루지 않는다.

# go
export GOPATH="$HOME/.go"
export GOBIN="$HOME/.go/bin"
export PATH="$GOBIN:$PATH"

# rust
export CARGO_BIN="$HOME/.cargo/bin"
export PATH="$CARGO_BIN:$PATH"

# node (npm global)
export NODE_BIN="$HOME/.npm-global/bin"
export PATH="$NODE_BIN:$PATH"
