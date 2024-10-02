#!/bin/bash

# Cloudflare API endpoint
API_ENDPOINT="https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/rulesets"

# Function to create or update ruleset
method="POST"
endpoint="${API_ENDPOINT}"

# Check if ruleset already exists
existing_ruleset=$(curl -s -X GET "${API_ENDPOINT}?phase=${PHASE}" \
        -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
        -H "Content-Type: application/json")

if echo "$existing_ruleset" | jq -e '.result[0]' > /dev/null; then
    ruleset_id=$(echo "$existing_ruleset" | jq -r '.result[0].id')
    method="PUT"
    endpoint="${API_ENDPOINT}/${ruleset_id}"
fi

# Prepare the rules JSON
rules_json=$(echo $RULESET_RULES | jq -c '
    [.[] | {
        action: .action,
        action_parameters: (
            if .action_parameters.ssl != null then
                {ssl: .action_parameters.ssl}
            else
                {}
            end
        ),
        expression: .expression,
        description: .description
    }]
')

# Send request to create or update ruleset
response=$(curl -s -X $method "$endpoint" \
        -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
        -H "Content-Type: application/json" \
        --data "{
            \"name\": \"Dynamic Main Ruleset\",
            \"description\": \"Dynamic ruleset for managing app settings\",
            \"kind\": \"${KIND}\",
            \"phase\": \"${PHASE}\",
            \"rules\": ${rules_json}
        }")

if echo "$response" | grep -q '"success":true'; then
    echo "Successfully managed ruleset for zone ${ZONE_ID}"
else
    echo "Failed to manage ruleset for zone ${ZONE_ID}"
    echo "Response: $response"
fi