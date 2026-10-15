;; Binding data is separate from installation. Only the installer is exported.
(require "helix/keymaps.scm")

(provide configure-keybindings!)

(define space-bindings
  (hash
    "x" ":buffer-close"
    "X" ":buffer-close-others"
    "A-f" "file_picker_in_current_buffer_directory"
    "A-y" ":clipboard-yank-join"
    "." ":toggle-option file-picker.git-ignore"
    "n" ":new"
    "l" ":lsp-restart"
    "q" ":quit-all"
    "i" ":toggle lsp.display-inlay-hints"
    "t" ":toggle soft-wrap.enable"
    "E" "file_explorer_in_current_buffer_directory"
    "K" "goto_hover"
    "B" ":gitlens-blame"
    "H" "select_register_history"))

;; Keep external-tool commands literal: Helix expands their % expressions.
(define yazi-commands
  (list
    ":sh rm -f /tmp/unique-ca1ea106"
    ":insert-output yazi \"%{buffer_name}\" --chooser-file=/tmp/unique-ca1ea106"
    ":sh printf \"\\x1b[?1049h\\x1b[?2004h\" > /dev/tty"
    ":open %sh{cat /tmp/unique-ca1ea106}"
    ":redraw"
    ":set mouse false"
    ":set mouse true"))

(define diff-bindings
  (hash
    "i" ":sh zellij run --floating -x 5%% -y 6%% --height 88%% --width 91%% -n 'Diff (Inline)' -- jj diff --tool neohelix-inline"
    "s" ":sh zellij run --floating -x 5%% -y 6%% --height 88%% --width 91%% -n 'Diff (Split)' -- jj diff"))

(define vcs-bindings
  (hash
    "t" (list
          ":sh zellij run --floating -x 5%% -y 6%% --height 88%% --width 91%% --close-on-exit -- jjui"
          ":reload-all")
    "b" ":blame-toggle"
    "u" ":sh gh browse -n '%{buffer_name}:%{selection_line_start}-%{selection_line_end}' | pbcopy"
    "o" ":sh gh browse '%{buffer_name}:%{selection_line_start}-%{selection_line_end}'"
    "d" diff-bindings
    "c" ":sh zellij action write-chars '/<<<<<<<' && zellij action write 13"))

(define tool-bindings
  (hash
    "y" yazi-commands
    "r" ":reset-diff-change"
    "g" vcs-bindings
    "'" ":sh zellij action new-pane --floating -x 5% -y 6% --height 88% --width 91%"))

(define normal-bindings
  (hash
    "tab" "move_parent_node_end"
    "S-tab" "move_parent_node_start"
    "C-u" (list "page_cursor_half_up" "align_view_center")
    "C-d" (list "page_cursor_half_down" "align_view_center")
    "A-y" (list ":yank-join")
    "A-o" "jump_backward"
    "A-i" "jump_forward"
    "A-c" "copy_selection_on_prev_line"
    "A-H" "goto_previous_buffer"
    "A-L" "goto_next_buffer"
    "}" "goto_next_paragraph"
    "{" "goto_prev_paragraph"
    "X" "extend_line_above"
    "D" (list "move_char_left" "delete_selection")
    "H" "jump_view_left"
    "L" "jump_view_right"
    "A-f" ":format"
    "A-r" ":reload-all"
    "A-R" ":reflow"
    "A-W" "move_next_sub_word_start"
    "A-B" "move_prev_sub_word_start"
    "A-E" "move_next_sub_word_end"
    "ret" "goto_word"
    "C-S" "save_selection"
    "space" space-bindings
    "'" tool-bindings))

(define insert-bindings
  (hash
    "S-tab" "move_parent_node_start"
    "A-left" "move_prev_word_start"
    "A-right" (list "move_next_word_end" "move_char_right")
    "C-left" "move_prev_word_start"
    "C-right" (list "move_next_word_end" "move_char_right")
    "A-p" "command_palette"))

(define selection-bindings
  (hash
    "tab" "extend_parent_node_end"
    "S-tab" "extend_parent_node_start"
    "X" "select_line_above"
    "A-W" "extend_next_sub_word_start"
    "A-B" "extend_prev_sub_word_start"
    "A-E" "extend_next_sub_word_end"))

(define (configure-keybindings!)
  (add-global-keybinding
    (hash
      "normal" normal-bindings
      "insert" insert-bindings
      "select" selection-bindings)))
