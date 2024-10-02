#!/bin/bash

# Cloudflare API endpoint
API_ENDPOINT="https://api.cloudflare.com/client/v4/zones"

# Function to update zone settings
update_zone_settings() {
    local response=$(curl -s -X PATCH "${API_ENDPOINT}/${ZONE_ID}/settings" \
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
}

# Main execution
update_zone_settings