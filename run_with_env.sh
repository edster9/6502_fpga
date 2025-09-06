#!/bin/bash
# Git Bash environment script for OSS CAD Suite
# Equivalent to run_with_env.bat for bash/Unix-like shells

# Save current directory
ORIGINAL_DIR=$(pwd)

# Change to tools/oss-cad-suite directory
cd tools/oss-cad-suite

# Get the absolute path to OSS CAD Suite (Windows format for tools)
if command -v cygpath >/dev/null 2>&1; then
    # If cygpath is available (Git Bash), convert to Windows path
    YOSYSHQ_ROOT=$(cygpath -w "$(pwd)")
    OSS_PATH=$(cygpath "$(pwd)/bin")
else
    # Fallback for other bash environments
    YOSYSHQ_ROOT="$(pwd -W 2>/dev/null || pwd)"
    OSS_PATH="$YOSYSHQ_ROOT/bin"
fi

# Set environment variables (following the PowerShell script pattern)
export YOSYSHQ_ROOT="$YOSYSHQ_ROOT"
export SSL_CERT_FILE="$YOSYSHQ_ROOT/etc/cacert.pem"
export PATH="$OSS_PATH:$YOSYSHQ_ROOT/lib:$PATH"
export PYTHON_EXECUTABLE="$YOSYSHQ_ROOT/lib/python3.exe"
export QT_PLUGIN_PATH="$YOSYSHQ_ROOT/lib/qt5/plugins"
export QT_LOGGING_RULES="*=false"
export GTK_EXE_PREFIX="$YOSYSHQ_ROOT"
export GTK_DATA_PREFIX="$YOSYSHQ_ROOT"
export GDK_PIXBUF_MODULEDIR="$YOSYSHQ_ROOT/lib/gdk-pixbuf-2.0/2.10.0/loaders"
export GDK_PIXBUF_MODULE_FILE="$YOSYSHQ_ROOT/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"

# Return to original directory
cd "$ORIGINAL_DIR"

# If no arguments provided, just export the environment
if [ $# -eq 0 ]; then
    # Output environment setup commands that can be sourced
    echo "export YOSYSHQ_ROOT='$YOSYSHQ_ROOT'"
    echo "export SSL_CERT_FILE='$SSL_CERT_FILE'"
    echo "export PATH='$PATH'"
    echo "export PYTHON_EXECUTABLE='$PYTHON_EXECUTABLE'"
    echo "export QT_PLUGIN_PATH='$QT_PLUGIN_PATH'"
    echo "export QT_LOGGING_RULES='$QT_LOGGING_RULES'"
    echo "export GTK_EXE_PREFIX='$GTK_EXE_PREFIX'"
    echo "export GTK_DATA_PREFIX='$GTK_DATA_PREFIX'"
    echo "export GDK_PIXBUF_MODULEDIR='$GDK_PIXBUF_MODULEDIR'"
    echo "export GDK_PIXBUF_MODULE_FILE='$GDK_PIXBUF_MODULE_FILE'"
else
    # Execute the passed command with the environment
    exec "$@"
fi
