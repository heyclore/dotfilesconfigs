#!/usr/bin/env bash

BIN_DIR="./bin"
LIB_DIR="./lib"

[[ -d "$BIN_DIR" && -d "$LIB_DIR" ]] || exit 1

targets=(
    $(find "$BIN_DIR" -type f -executable)
    $(find "$LIB_DIR" -maxdepth 1 -type f -name "*.so*")
)

for exe in "${targets[@]}"; do
    missing=$(ldd "$exe" 2>/dev/null | awk '/not found/ {print $1}')
    [[ -z "$missing" ]] && continue

    rpaths=()

    for lib in $missing; do
        replacement=""
        found=""

        # exact
        found=$(find "$LIB_DIR" -type f -name "$lib" | head -n1)

        if [[ -n "$found" ]]; then
            replacement=$(basename "$found")
        else
            # sanitized
            sanitized=$(echo "$lib" | sed -E 's/(\.so)(\..*)$/\1/')
            found=$(find "$LIB_DIR" -type f -name "$sanitized" | head -n1)

            if [[ -n "$found" ]]; then
                replacement=$(basename "$found")
                patchelf --replace-needed "$lib" "$replacement" "$exe"
            else
                # prefix match
                found=$(find "$LIB_DIR" -type f -name "${lib}*" | head -n1)

                if [[ -n "$found" ]]; then
                    replacement=$(basename "$found")
                    patchelf --replace-needed "$lib" "$replacement" "$exe"
                fi
            fi
        fi

        if [[ -n "$found" ]]; then
            dir=$(dirname "$found")
            rel=$(realpath --relative-to="$(dirname "$exe")" "$dir")
            rpaths+=("\$ORIGIN/$rel")
        fi
    done

    if [[ ${#rpaths[@]} -gt 0 ]]; then
        rpath=$(printf "%s:" "${rpaths[@]}" | sed 's/:$//')
        patchelf --set-rpath "$rpath" "$exe"
    fi
done
