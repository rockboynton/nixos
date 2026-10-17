# Loaded into the packaged jjui launcher; binary paths are supplied by Nix.
# Keep this independently runnable for PTY integration tests.
: "${NEOHELIX_JJUI_BIN:?missing real jjui executable}"
: "${NEOHELIX_HX_BIN:?missing Neohelix executable}"

export HELIX_DIFF_WORKER="${HELIX_DIFF_WORKER:-1}"
# User AND trusted project config must not depend on initial COLUMNS, LINES,
# DFT_WIDTH or the shell's PWD spelling. Set this to 0 to retain width/env
# isolation; demand-started workers still work, without speculative warmup.
export HELIX_DIFF_WORKER_SHARED_VIEWPORT="${HELIX_DIFF_WORKER_SHARED_VIEWPORT:-1}"
export JJUI=1

neohelix_jjui_location() {
    # Match Go flag parsing: options precede the first positional location.
    # Unknown/new options safely skip warmup; jjui still receives original args.
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -help|--help|-h|--version|-version|-config|--config|-install-lua-types|--install-lua-types)
                return 1 ;;
            -r|--r|-revset|--revset|-n|--n|-limit|--limit|-p|--p|-period|--period)
                [ "$#" -ge 2 ] || return 1
                shift 2 ;;
            -r=*|--r=*|-revset=*|--revset=*|-n=*|--n=*|-limit=*|--limit=*|-p=*|--p=*|-period=*|--period=*)
                shift ;;
            --)
                shift
                printf '%s\n' "${1:-.}"
                return ;;
            -*) return 1 ;;
            *) printf '%s\n' "$1"; return ;;
        esac
    done
    printf '.\n'
}

if [ "$HELIX_DIFF_WORKER" = 1 ] && [ "$HELIX_DIFF_WORKER_SHARED_VIEWPORT" = 1 ]; then
    if neohelix_location=$(neohelix_jjui_location "$@"); then
        (
            cd -- "$neohelix_location" || exit 0
            # A workspace root already identifies itself; avoid a redundant JJ
            # process competing with jjui's own startup root query.
            if [ -d .jj/working_copy ]; then
                neohelix_root=$(pwd -P) || exit 0
            else
                neohelix_root=$(jj root --ignore-working-copy --color never) || exit 0
            fi
            cd -- "$neohelix_root" || exit 0
            # No viewport guessing: the explicitly shared worker adapts each
            # request to jjui's real preview/full-diff width. No revision loaded.
            exec "$NEOHELIX_HX_BIN" --diff-worker-warm --width 100
        ) </dev/null >/dev/null 2>&1 &
    fi
fi

exec "$NEOHELIX_JJUI_BIN" "$@"
