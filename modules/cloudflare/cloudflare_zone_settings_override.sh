#!/bin/bash

# Cloudflare API endpoint
API_ENDPOINT="https://api.cloudflare.com/client/v4/zones"

# Function to update zone settings
update_zone_settings() {
    local zone_id=$1
    local response=$(curl -s -X PATCH "${API_ENDPOINT}/${zone_id}/settings" \
         -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
         -H "Content-Type: application/json" \
         --data "{
             \"items\": [
                 {\"id\": \"ssl\", \"value\": \"${SSL}\"},
                 {\"id\": \"always_use_https\", \"value\": ${ALWAYS_USE_HTTPS}}
             ]
         }")

    if echo "$response" | grep -q '"success":true'; then
        echo "Successfully updated settings for zone ${zone_id}"
    else
        echo "Failed to update settings for zone ${zone_id}"
        echo "Response: $response"
    fi
}

# Main execution
IFS=',' read -ra ZONE_ID_ARRAY <<< "$ZONE_IDS"
for zone_id in "${ZONE_ID_ARRAY[@]}"; do
    update_zone_settings "$zone_id"
done