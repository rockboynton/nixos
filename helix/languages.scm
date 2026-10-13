;; Neohelix language overrides. Imports do not apply settings; startup calls the
;; exported function. Built-in grammars, roots, and unrelated language fields stay intact.
(require "helix/configuration.scm")
(require-builtin helix/core/configuration as configuration.)

(provide configure-languages!)

(define (merge-json-objects base overrides)
  (let ([result (if (hash? base) base (hash))])
    (for-each
      (lambda (key)
        (let ([value (hash-ref overrides key)] [previous (hash-try-get result key)])
          (set! result (hash-insert result key
            (if (hash? value) (merge-json-objects previous value) value)))))
      (hash-keys->list overrides))
    result))

(define (server! name overrides)
  ;; Native set-lsp-config! replaces initialization JSON. Merge it explicitly so
  ;; built-in rust-analyzer inlay-hint and file-watcher settings are not lost.
  (let* ([config (hash-try-get overrides "config")]
         [existing (get-lsp-config name)]
         [base (and (hash? existing) (hash-try-get existing 'config))])
    (set-lsp-config! name
      (if (hash? config)
          (hash-insert overrides "config" (merge-json-objects base config))
          overrides))))

(define (configure-language-servers!)
  (server! "haskell-language-server"
    (hash "command" "haskell-language-server" "args" '("--lsp")))
  (server! "rust-analyzer"
    (hash "config"
      (hash 'cargo (hash 'targetDir #t)
            'check (hash 'command "clippy")
            'workspace (hash 'symbol (hash 'search (hash 'kind "all_symbols"))))))
  (server! "tinymist"
    (hash "config"
      (hash 'exportPdf "onType"
            'outputPath "$root/target/$dir/$name"
            'lint (hash 'enabled #t 'when "onType")
            'formatterMode "typstyle"
            'formatterProseWrap #t
            ;; Use the project's tinymist.lock instead of compiling each imported file.
            'projectResolution "lockDatabase")))
  (server! "rumdl" (hash "command" "rumdl" "args" '("server")))
  (server! "steel-language-server" (hash "command" "steel-language-server")))

(define (language! name overrides)
  ;; Batch native updates, then refresh open documents once at the end.
  (configuration.update-language-config! name (hash-insert overrides "name" name)))

(define (configure-languages!)
  (configure-language-servers!)
  (language! "haskell"
    (hash "indent" (hash "tab-width" 4 "unit" "    ")
          "formatter" (hash "command" "fourmolu" "args" '("-i"))))
  (language! "ld" (hash "file-types" '("ld" "x")))
  (language! "markdown"
    (hash "formatter" (hash "command" "rumdl" "args" '("fmt" "-"))
          "language-servers" '("rumdl")))
  (language! "nix"
    (hash "language-servers" '("nixd")
          "formatter" (hash "command" "nixpkgs-fmt")))
  (language! "rust" (hash "language-servers" '("rust-analyzer")))
  (language! "toml" (hash "formatter" (hash "command" "taplo" "args" '("fmt" "-"))))
  (language! "typst"
    (hash "auto-format" #t "language-servers" '("tinymist")
          "formatter" (hash "command" "typstyle" "args" '("--wrap-text" "--line-width=120"))))
  (language! "scheme" (hash "language-servers" '("steel-language-server")))
  (refresh-all-language-configs!))
