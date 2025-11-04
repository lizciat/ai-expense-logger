# ==== CONFIGURACIÓN ====
FUNCTION_NAME="asistente-gastos"
REGION="us-east-1"
ACCOUNT_ID="039412445563"
REPO_NAME="asistente-gastos"
TAG="v3"
LAMBDA_URL="https://ora23oenhh4wjykdc4nqazxgt40vrfrh.lambda-url.us-east-1.on.aws/"


# ==== PRUEBA AUTOMÁTICA ====
echo ""
echo "🧪 Probando Lambda con mensaje de ejemplo..."
curl -s -X POST "${LAMBDA_URL}" \
  -H "Content-Type: application/json" \
  -d '{"message":{"text":"gasté 50 EUR en comida","chat":{"id":7505991076}}}' \
  | jq

echo ""
echo "📜 Para ver los logs más recientes:"
echo "aws logs get-log-events --log-group-name /aws/lambda/${FUNCTION_NAME} --log-stream-name \$(aws logs describe-log-streams --log-group-name /aws/lambda/${FUNCTION_NAME} --order-by LastEventTime --descending --limit 1 --query 'logStreams[0].logStreamName' --output text) --limit 30 --region ${REGION}"