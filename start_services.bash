#!/bin/bash

# List of service names
services=(
  book
  clientapi
  dbhandler
  executionhandler
  hedgeservice
  marketdatagateway
  pricerengine
  riskcalculator
)

# Loop through each service and run it with jolie
for service in "${services[@]}"; do
  echo "Starting $service.ol..."
  gnome-terminal -- bash -c "jolie $service.ol; exec bash"
done