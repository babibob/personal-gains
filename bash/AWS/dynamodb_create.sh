aws dynamodb create-table \
    --table-name TABLE_NAME \
    --attribute-definitions \
        AttributeName=PK,AttributeType=S \
        AttributeName=ConsumerId,AttributeType=S \
        AttributeName=Provider,AttributeType=S \
    --key-schema \
        AttributeName=PK,KeyType=HASH \
        AttributeName=ConsumerId,KeyType=RANGE \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --local-secondary-indexes \
        "[
            {
                \"IndexName\": \"ProviderIndex\",
                \"KeySchema\": [
                    {\"AttributeName\":\"PK\",\"KeyType\":\"HASH\"},
                    {\"AttributeName\":\"Provider\",\"KeyType\":\"RANGE\"}
                ],
                \"Projection\":{
                    \"ProjectionType\":\"KEYS_ONLY\"
                }
            }
        ]"