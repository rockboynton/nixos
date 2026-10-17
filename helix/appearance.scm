;; Display settings stay together; true-color must precede theme/icon loading.
(require "helix/configuration.scm")
(require (prefix-in hx. "helix/commands.scm"))

(provide configure-appearance!)

(define (configure-appearance!)
  (true-color #t)
  (line-number 'relative)
  (rulers '(120))
  (color-modes #t)
  (cursorline #t)
  (bufferline 'multiple)
  (undercurl #t)
  (rainbow-brackets #t)
  (cursor-shape #:normal 'block #:insert 'bar #:select 'underline)

  (statusline
    #:left '(mode spinner file-type-icon file-name read-only-indicator
             file-modification-indicator version-control)
    #:center '(diagnostics spacer workspace-diagnostics)
    #:right '(selections register search-position position position-percentage file-encoding)
    #:mode-normal "NORMAL"
    #:mode-insert "INSERT"
    #:mode-select "SELECT"
    ;; Preserve Helix's existing separator instead of the helper's ASCII default.
    #:separator "│")

  (indent-guides (ig-render #t) (ig-skip-levels 1) (ig-character #\┊))
  ;; ws-render fills every omitted character with "none"; keep partial overrides.
  (set-option! "whitespace.render" (hash 'space "all" 'tab "all"))
  (set-option! "inline-diagnostics.cursor-line" "warning")
  (hx.theme "modified_gruvbox")
  (hx.icons "nerdfonts"))
