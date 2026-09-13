#!/bin/bash
set -e

# Load NACOS_VERSION
source .env
CLEAN_VERSION=${NACOS_VERSION#v}
# deal -slim
CLEAN_VERSION=${CLEAN_VERSION%-*}

SCHEMA_URL="https://raw.githubusercontent.com/alibaba/nacos/${CLEAN_VERSION}/plugin-default-impl/nacos-default-datasource-plugin/nacos-datasource-plugin-postgresql/src/main/resources/META-INF/pg-schema.sql"
FALLBACK_URL="https://raw.githubusercontent.com/alibaba/nacos/develop/plugin-default-impl/nacos-default-datasource-plugin/nacos-datasource-plugin-postgresql/src/main/resources/META-INF/pg-schema.sql"

TARGET_DIR="./pg-init"
VERSIONED_FILE="${TARGET_DIR}/${CLEAN_VERSION}-pg-schema.sql"
FINAL_FILE="${TARGET_DIR}/pg-schema.sql"

# Create directory
mkdir -p "${TARGET_DIR}"

# Download schema file (version-specific first, fallback to develop branch)
echo "⬇️  Downloading PostgreSQL schema for Nacos ${CLEAN_VERSION}..."
if ! curl -sSL --fail "$SCHEMA_URL" -o "${VERSIONED_FILE}" 2>/dev/null; then
  echo "⚠️  Version-specific path not found, trying develop branch..."
  curl -sSL --fail "$FALLBACK_URL" -o "${VERSIONED_FILE}"
fi

# Verify download
if [ ! -s "${VERSIONED_FILE}" ]; then
  echo "❌ Failed to download schema file"
  exit 1
fi

# Copy to standard filename for PostgreSQL initialization
cp "${VERSIONED_FILE}" "${FINAL_FILE}"

# Remove versioned file
rm -f "${VERSIONED_FILE}"

echo "✅ Downloaded and prepared: ${FINAL_FILE}"
