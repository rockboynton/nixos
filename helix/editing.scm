;; Editing, language-server display, file handling, and VCS preferences.
(require "helix/configuration.scm")

(provide configure-editing!)

(define (configure-editing!)
  (mouse #f)
  (text-width 120)
  (shell '("fish" "-c"))
  (jump-label-alphabet "asdf;lkjghqweruioptyzxc/.,mbn")
  (completion-trigger-len 1)
  (completion-timeout 100)
  (file-picker (fp-hidden #f))
  (lsp (hash 'display-messages #t 'display-inlay-hints #t))

  ;; Use the generic API for Neohelix options without dedicated helpers.
  (set-option! "end-of-line-diagnostics" "hint")
  (set-option! "auto-reload" #t)
  (set-option! "enable-steel" #t)
  (set-option! "inline-blame.show" "never")
  (set-option! "inline-blame.auto-fetch" #t)
  (set-option! "auto-save.focus-lost" #t)
  (set-option! "auto-save.after-delay.enable" #t)
  (set-option! "auto-save.after-delay.timeout" 300))
