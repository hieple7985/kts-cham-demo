#!/bin/bash
# Build Flutter Web for production with build timestamp

BUILD_DATE=$(date +%Y-%m-%d)
BUILD_TIME=$(date +%H:%M:%S)

echo "=========================================="
echo "CUCA App - Build Web (Production)"
echo "Build Date: $BUILD_DATE"
echo "Build Time: $BUILD_TIME"
echo "=========================================="

flutter build web \
  --dart-define=SUPABASE_URL=https://nqydrdguessrwhiiteen.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xeWRyZGd1ZXNzcndoaWl0ZWVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzOTIyMDUsImV4cCI6MjA3OTk2ODIwNX0.98CGGnSqrrgpvZbzoKIhqDlB6hbmkYaOXgNSKUNDv3o \
  --dart-define=CUCA_USE_SUPABASE_AUTH=true \
  --dart-define=CUCA_NODE_API_BASE_URL=http://localhost:4000 \
  --dart-define=BUILD_DATE=$BUILD_DATE \
  --dart-define=BUILD_TIME=$BUILD_TIME

echo "Build complete! Output: build/web/"
