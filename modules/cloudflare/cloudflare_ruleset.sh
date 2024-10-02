#!/bin/bash

# Function to update zone settings
response=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/settings" \
        -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
        -H "Content-Type: application/json" \
        --data "{
            \"items\": [
                {\"id\": \"ssl\", \"value\": \"${SSL}\"},
                {\"id\": \"always_use_https\", \"value\": \"${ALWAYS_USE_HTTPS}\"}
            ]
        }")

if echo "$response" | grep -q '"success":true'; then
    echo "Successfully updated settings for zone ${ZONE_ID}"
else
    echo "Failed to update settings for zone ${ZONE_ID}"
    echo "Response: $response"
fi