#!/bin/bash

# ==== CONFIGURACIÓN ====
FUNCTION_NAME="asistente-gastos"
REGION="us-east-1"
ACCOUNT_ID="039412445563"
REPO_NAME="asistente-gastos"
TAG="v2"

# ==== CONSTRUCCIÓN Y ENVÍO DE LA IMAGEN ====
echo "🔧 Construyendo imagen Docker..."
docker build -t ${REPO_NAME}:latest .

echo "🏷️ Etiquetando imagen..."
docker tag ${REPO_NAME}:latest ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:${TAG}

echo "🔐 Iniciando sesión en ECR..."
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

echo "🚀 Subiendo imagen a ECR..."
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:${TAG}

# ==== ACTUALIZACIÓN DE LA FUNCIÓN LAMBDA ====
echo "🔄 Actualizando Lambda..."
aws lambda update-function-code \
  --function-name ${FUNCTION_NAME} \
  --image-uri ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:${TAG} \
  --region ${REGION}

# ==== CONFIRMACIÓN ====
echo "✅ Despliegue completado. Verificando última actualización..."
aws lambda get-function \
  --function-name ${FUNCTION_NAME} \
  --region ${REGION} \
  --query '{ImageUri: Code.ImageUri, LastModified: Configuration.LastModified}'
