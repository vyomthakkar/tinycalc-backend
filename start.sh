#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  echo "Loading environment variables from .env"
  source .env
else
  echo "Warning: .env file not found. Make sure to set your environment variables!"
fi

# Start the Phoenix server
echo "Starting Tinycalc server..."
mix phx.server