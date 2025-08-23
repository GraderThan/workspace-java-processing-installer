#!/usr/bin/env bash
set -euo pipefail

# Config
URL="${URL:-https://github.com/processing/processing4/releases/download/processing-1306-4.4.6/processing-4.4.6-linux-x64-portable.zip}"

# Extract version from URL (matches patterns like 4.4.6)
VERSION=$(echo "$URL" | grep -oE 'processing-[0-9]+\.[0-9]+\.[0-9]+' | tail -1 | cut -d'-' -f2)
if [ -z "$VERSION" ]; then
  echo "Error: Could not extract version from URL"
  exit 1
fi
echo "Detected Processing version: $VERSION"

PROCESSING_BASE_DIR="/opt/processing"
INSTALL_DIR="$PROCESSING_BASE_DIR/processing-$VERSION"
BIN_LINK="/usr/local/bin/processing"
DESKTOP_FILE="/usr/share/applications/processing.desktop"
CACHE_DIR="$HOME/.processing"
ZIP_PATH="$CACHE_DIR/processing-$VERSION.zip"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure cache dir exists
mkdir -p "$CACHE_DIR"

# Download zip into ~/.processing if not already present
if [ -f "$ZIP_PATH" ]; then
  echo "Found existing ZIP at $ZIP_PATH — skipping download."
else
  echo "Downloading Processing ZIP to $ZIP_PATH ..."
  curl -L "$URL" -o "$ZIP_PATH"
fi

# Extract and install
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

unzip -q "$ZIP_PATH" -d "$TMPDIR"

# Create base processing directory if it doesn't exist
mkdir -p "$PROCESSING_BASE_DIR"

# The archive extracts to a folder named Processing
if [ -d "$INSTALL_DIR" ]; then
  echo "Removing existing install at $INSTALL_DIR ..."
  rm -rf "$INSTALL_DIR"
fi

mv "$TMPDIR/Processing" "$INSTALL_DIR"

# Symlink for terminal launch
rm -f "$BIN_LINK"
ln -sf "$INSTALL_DIR/bin/Processing" "$BIN_LINK"

# Copy template and p5j-new to /opt/processing
if [ -d "$SCRIPT_DIR/template" ]; then
  cp -r "$SCRIPT_DIR/template" "$PROCESSING_BASE_DIR/"
  echo "Copied template directory to $PROCESSING_BASE_DIR/template"
else
  echo "⚠ Template directory not found at $SCRIPT_DIR/template"
fi

if [ -f "$SCRIPT_DIR/p5j-new" ]; then
  cp "$SCRIPT_DIR/p5j-new" "$PROCESSING_BASE_DIR/"
  chmod +x "$PROCESSING_BASE_DIR/p5j-new"
  echo "Copied p5j-new to $PROCESSING_BASE_DIR/"
else
  echo "⚠ p5j-new script not found at $SCRIPT_DIR/p5j-new"
fi

# Create symlink for p5j-new
CREATE_PROJECT_LINK="/usr/local/bin/p5j-new"
if [ -f "$PROCESSING_BASE_DIR/p5j-new" ]; then
  rm -f "$CREATE_PROJECT_LINK"
  ln -sf "$PROCESSING_BASE_DIR/p5j-new" "$CREATE_PROJECT_LINK"
  echo "Created p5j-new command at $CREATE_PROJECT_LINK"
else
  echo "⚠ p5j-new not found at $PROCESSING_BASE_DIR/p5j-new"
fi

# Create desktop entry only if it does not already exist
if [ ! -f "$DESKTOP_FILE" ]; then
  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=$VERSION
Name=Processing
Comment=Processing IDE
Exec=$INSTALL_DIR/bin/Processing
Icon=$INSTALL_DIR/lib/Processing.png
Terminal=false
Type=Application
Categories=Development;Education;Graphics;
EOF

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database >/dev/null 2>&1 || true
  fi
fi

# Create desktop icon if desktop directory exists
DESKTOP_DIR="$HOME/Desktop"
if [ -d "$DESKTOP_DIR" ]; then
  DESKTOP_ICON="$DESKTOP_DIR/Processing.desktop"
  if [ ! -f "$DESKTOP_ICON" ]; then
    cp "$DESKTOP_FILE" "$DESKTOP_ICON"
    chmod +x "$DESKTOP_ICON"
    echo "Created desktop icon at $DESKTOP_ICON"
  else
    echo "Desktop icon already exists at $DESKTOP_ICON"
  fi
else
  echo "Desktop directory not found at $DESKTOP_DIR, skipping desktop icon creation"
fi


# Locate Processing core JAR (Processing 4 names it like core-<version>-<hash>.jar)
CORE_JAR_PATH=$(find "$INSTALL_DIR" -type f \( -name core.jar -o -name "core-*.jar" \) 2>/dev/null | head -n1 || true)

if [ -n "$CORE_JAR_PATH" ]; then
  echo "Found core jar: $CORE_JAR_PATH"

  # Save the core JAR path for p5j-new
  CORE_JAR_CONFIG="$PROCESSING_BASE_DIR/processing-core-jar-path"
  echo "$CORE_JAR_PATH" > "$CORE_JAR_CONFIG"
  echo "Saved core JAR path to $CORE_JAR_CONFIG"

else
  echo "⚠ Could not find a Processing core jar. Try:"
  echo "    find $INSTALL_DIR -type f \( -name core.jar -o -name 'core-*.jar' \)"
fi
