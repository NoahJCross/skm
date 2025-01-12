#!/bin/bash

APP_PATH=`echo $0 | awk '{split($0,patharr,"/"); idx=1; while(patharr[idx+1] != "") { if (patharr[idx] != "/") {printf("%s/", patharr[idx]); idx++ }} }'`
APP_PATH=`cd "$APP_PATH"; pwd`

SKM_PATH=`cd "$APP_PATH/.."; pwd`

source "${SKM_PATH}/tools/set_sk_env_vars.sh"

# Set Rust library path
RUST_LIB="${HOME}/.splashkit/cargo"

# Check if Cargo.toml exists
if [ -f "Cargo.toml" ]; then
    sed -i "s|splashkit.*=.*{.*path.*=.*\".*\".*}|splashkit = { path = \"${RUST_LIB}\" }|" Cargo.toml
    
    # If splashkit wasn't found, add it
    if ! grep -q "splashkit.*=.*{.*path.*=.*\".*\".*}" Cargo.toml; then
        # Add empty line if needed
        if [ -s Cargo.toml ]; then
            echo "" >> Cargo.toml
        fi
        echo "splashkit = { path = \"${RUST_LIB}\" }" >> Cargo.toml
    fi
fi

if [ "$SK_OS" = "win64" ]; then
    PATH="$DYLIB_PATH:$PATH" cargo $*
elif [ "$SK_OS" = "macos" ]; then
    DYLD_LIBRARY_PATH="$DYLIB_PATH" cargo $*
elif [ "$SK_OS" = "linux" ]; then
    LD_LIBRARY_PATH="$DYLIB_PATH:$LD_LIBRARY_PATH" cargo $*
else
    echo "Unable to detect operating system..."
    exit 1
fi