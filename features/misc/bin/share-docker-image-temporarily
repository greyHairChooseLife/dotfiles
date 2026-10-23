#!/bin/bash

set -euo pipefail

# 사용법: ./share-docker-image-temporarily.sh [시간]
# 예시: ./share-docker-image-temporarily.sh 2h (입력 없으면 기본 1h)

IMAGE_NAME="greyhairchooselife"
EXPIRE_TIME=${1:-1h}
FULL_NAME="ttl.sh/${IMAGE_NAME}:${EXPIRE_TIME}"

echo "### STEP 1: 빌드 (Image: ${IMAGE_NAME}) ###"
docker build -t "$IMAGE_NAME" .

echo "### STEP 2: 태그 및 푸시 ###"
docker tag "$IMAGE_NAME" "$FULL_NAME"
docker push "$FULL_NAME"

echo "----------------------------------------"
echo "### 업로드 정보 ###"
echo "-   이미지 이름: ${IMAGE_NAME}"
echo "-   만료 시간  : ${EXPIRE_TIME}"
echo "-   전체 주소  : ${FULL_NAME}"
echo ""
echo "### 실행/가져오기 명령어 ###"
echo "docker pull ${FULL_NAME}"
echo ""
echo "### 로컬 이미지 삭제 (Cleanup) ###"
echo "docker rmi ${IMAGE_NAME} ${FULL_NAME}"
echo "----------------------------------------"
