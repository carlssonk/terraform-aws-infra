#!/bin/bash
max_attempts=2
attempt=1

while [ $attempt -le $max_attempts ]; do
  echo "Attempt $attempt of $max_attempts"
  if eval "$@"; then
    echo "Command succeeded"
    exit 0
  else
    echo "Command failed"
    if [ $attempt -lt $max_attempts ]; then
      echo "Retrying in 15 seconds..."
      sleep 15
    fi
  fi
  attempt=$((attempt + 1))
done

echo "All attempts failed"
exit 1