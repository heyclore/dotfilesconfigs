#!/usr/bin/env bash

BIN_DIR="./bin"
LIB_DIR="./lib"

[[ -d "$BIN_DIR" && -d "$LIB_DIR" ]] || exit 1

is_elf() {
    readelf -h "$1" >/dev/null 2>&1
}

targets=(
    $(find "$BIN_DIR" -type f -executable)
    $(find "$LIB_DIR" -maxdepth 1 -type f -name "*.so*")
)

for exe in "${targets[@]}"; do
    missing=$(ldd "$exe" 2>/dev/null | awk '/not found/ {print $1}')
    [[ -z "$missing" ]] && continue

    rpaths=()

    for lib in $missing; do
        orig_lib="$lib"
        lib=$(basename "$lib")

        replacement=""
        found=""

        # 1. Exact match
        found=$(find "$LIB_DIR" -type f -name "$lib" | head -n1)
        [[ -n "$found" ]] && ! is_elf "$found" && found=""

        # 2. Prefix match (libfoo.so.2 -> libfoo.so.2.1.5)
        if [[ -z "$found" ]]; then
            found=$(find "$LIB_DIR" -type f -name "${lib}*" | head -n1)
            [[ -n "$found" ]] && ! is_elf "$found" && found=""
        fi

        # 3. Sanitized match LAST (libfoo.so.2 -> libfoo.so)
        if [[ -z "$found" ]]; then
            sanitized=$(echo "$lib" | sed -E 's/(\.so)(\..*)$/\1/')
            found=$(find "$LIB_DIR" -type f -name "$sanitized" | head -n1)
            [[ -n "$found" ]] && ! is_elf "$found" && found=""
        fi

        [[ -z "$found" ]] && continue

        replacement=$(basename "$found")

        if [[ "$orig_lib" != "$replacement" ]]; then
            patchelf --replace-needed "$orig_lib" "$replacement" "$exe" \
                2>/dev/null || true
        fi

        dir=$(dirname "$found")
        rel=$(realpath --relative-to="$(dirname "$exe")" "$dir")
        rpaths+=("\$ORIGIN/$rel")
    done

    if [[ ${#rpaths[@]} -gt 0 ]]; then
        rpath=$(printf "%s:" "${rpaths[@]}" | sed 's/:$//')
        patchelf --set-rpath "$rpath" "$exe"
    fi
done
