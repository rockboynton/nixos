;; Public entry point. Requiring modules defines functions without applying settings.
(require (prefix-in editing. "editing.scm"))
(require (prefix-in languages. "languages.scm"))
(require (prefix-in appearance. "appearance.scm"))
(require (prefix-in keys. "keybindings.scm"))
(require "plugins/gitlens/gitlens.scm")

(provide configure-neohelix! gitlens-blame gitlens-clear-cache)

(define (configure-neohelix!)
  (editing.configure-editing!)
  (languages.configure-languages!)
  (appearance.configure-appearance!)
  (keys.configure-keybindings!))
