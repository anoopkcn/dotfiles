;;; slate-theme.el --- soft pastel-on-slate dark theme -*- lexical-binding: t; -*-

;; Port of the neovim/ghostty "slate" theme: lifted cool-slate background,
;; soft off-white text, desaturated pastel accents. Port: @anoopkcn
;; Colours mirror nvim/colors/slate.lua so every surface renders identically.

;;; Commentary:
;; A dark theme easy on the eyes for long sessions.

;;; Code:

(deftheme slate "Soft pastel-on-slate dark theme.")

(let ((class '((class color) (min-colors 89)))
      ;; Neutral slate ramp (lifted off black -> soft cool white)
      (bg-1    "#1d2029") ; deepest (popup / float depth)
      (bg      "#14161d") ; Normal background
      (bg1     "#2a2f3d") ; CursorLine / hl-line
      (bg2     "#32384a") ; NonText / separators / mode-line
      (bg3     "#303a54") ; menu / tab selection (blue-tinted)
      (sel     "#3c4e7a") ; visual/region selection
      (bg4     "#4d5566") ; fold / conceal / sign chrome
      (gutter  "#5b647b") ; line numbers
      (fg      "#e0e2ea") ; Normal text
      (fg1     "#f0f1f6") ; emphasised text
      (fdim    "#b5bbc4") ; secondary text / punctuation
      (white   "#ffffff")
      ;; Soft pastel accents
      (comment "#828c9e") ; muted slate-gray
      (blue    "#88a0c8") ; keywords / control flow
      (purple  "#c099ff") ; control / headings (airy lilac)
      (green   "#a0ddac") ; strings
      (green2  "#8cc570") ; diff-add / raw
      (cyan    "#a0def3") ; types / builtins / functions
      (orange  "#ef9f64") ; numbers / constants
      (yellow  "#ecbe70") ; preproc / labels
      (red     "#f7768e") ; errors / self
      (pink    "#db9fd6") ; escapes / special
      ;; Diff block tints
      (diff-add    "#2d4a38")
      (diff-change "#2a3145")
      (diff-text   "#3a4a6a")
      (diff-delete "#4e3638"))

  (custom-theme-set-faces
   'slate

   ;; Base UI
   `(default             ((,class (:foreground ,fg :background ,bg))))
   `(cursor              ((,class (:background ,fg))))
   `(fringe              ((,class (:foreground ,bg4 :background ,bg))))
   `(region              ((,class (:background ,sel :extend t))))
   `(highlight           ((,class (:background ,bg3))))
   `(hl-line             ((,class (:background ,bg1 :extend t))))
   `(secondary-selection ((,class (:background ,bg2 :extend t))))
   `(shadow              ((,class (:foreground ,comment))))
   `(match               ((,class (:foreground ,bg :background ,green))))
   `(vertical-border     ((,class (:foreground ,bg2))))
   `(window-divider      ((,class (:foreground ,bg2))))
   `(window-divider-first-pixel ((,class (:foreground ,bg2))))
   `(window-divider-last-pixel  ((,class (:foreground ,bg2))))
   `(minibuffer-prompt   ((,class (:foreground ,blue :weight bold))))
   `(link                ((,class (:foreground ,purple :underline t))))
   `(link-visited        ((,class (:foreground ,pink :underline t))))
   `(button              ((,class (:foreground ,purple :underline t))))
   `(escape-glyph        ((,class (:foreground ,pink))))
   `(trailing-whitespace ((,class (:background ,red))))
   `(error               ((,class (:foreground ,red :weight bold))))
   `(warning             ((,class (:foreground ,yellow :weight bold))))
   `(success             ((,class (:foreground ,green :weight bold))))
   `(tooltip             ((,class (:foreground ,fg :background ,bg-1))))

   ;; Line numbers
   `(line-number              ((,class (:foreground ,gutter :background ,bg))))
   `(line-number-current-line ((,class (:foreground ,yellow :background ,bg1 :weight bold))))

   ;; Mode line (StatusLine: fg on bg2)
   `(mode-line          ((,class (:foreground ,fg :background ,bg2 :box nil))))
   `(mode-line-active   ((,class (:foreground ,fg :background ,bg2 :box nil))))
   `(mode-line-inactive ((,class (:foreground ,comment :background ,bg1 :box nil))))
   `(mode-line-highlight ((,class (:foreground ,purple))))
   `(mode-line-buffer-id ((,class (:foreground ,fg1 :weight bold))))
   `(header-line        ((,class (:foreground ,fg :background ,bg1))))

   ;; Font lock (syntax)
   `(font-lock-comment-face              ((,class (:foreground ,comment :slant italic))))
   `(font-lock-comment-delimiter-face    ((,class (:foreground ,comment :slant italic))))
   `(font-lock-doc-face                  ((,class (:foreground ,comment :slant italic))))
   `(font-lock-doc-markup-face           ((,class (:foreground ,pink))))
   `(font-lock-string-face               ((,class (:foreground ,green))))
   `(font-lock-keyword-face              ((,class (:foreground ,blue :weight bold))))
   `(font-lock-builtin-face              ((,class (:foreground ,cyan))))
   `(font-lock-function-name-face        ((,class (:foreground ,cyan))))
   `(font-lock-function-call-face        ((,class (:foreground ,cyan))))
   `(font-lock-variable-name-face        ((,class (:foreground ,fg))))
   `(font-lock-variable-use-face         ((,class (:foreground ,fg))))
   `(font-lock-type-face                 ((,class (:foreground ,cyan))))
   `(font-lock-constant-face             ((,class (:foreground ,orange))))
   `(font-lock-number-face               ((,class (:foreground ,orange))))
   `(font-lock-negation-char-face        ((,class (:foreground ,red))))
   `(font-lock-preprocessor-face         ((,class (:foreground ,yellow))))
   `(font-lock-regexp-grouping-backslash ((,class (:foreground ,pink))))
   `(font-lock-regexp-grouping-construct ((,class (:foreground ,pink))))
   `(font-lock-warning-face              ((,class (:foreground ,red :weight bold))))
   `(font-lock-property-name-face        ((,class (:foreground ,fg))))
   `(font-lock-property-use-face         ((,class (:foreground ,fg))))
   `(font-lock-operator-face             ((,class (:foreground ,fdim))))
   `(font-lock-punctuation-face          ((,class (:foreground ,fdim))))
   `(font-lock-bracket-face              ((,class (:foreground ,fdim))))
   `(font-lock-delimiter-face            ((,class (:foreground ,fdim))))
   `(font-lock-escape-face               ((,class (:foreground ,pink))))

   ;; Search
   `(isearch        ((,class (:foreground ,bg :background ,yellow :weight bold))))
   `(isearch-fail   ((,class (:foreground ,bg :background ,red))))
   `(lazy-highlight  ((,class (:foreground ,bg :background ,purple))))
   `(query-replace  ((,class (:foreground ,bg :background ,yellow))))

   ;; Parens
   `(show-paren-match         ((,class (:foreground ,cyan :background ,bg3 :weight bold))))
   `(show-paren-mismatch      ((,class (:foreground ,white :background ,red :weight bold))))
   `(show-paren-match-expression ((,class (:background ,bg1))))

   ;; Completion (default *Completions*, completion-preview)
   `(completions-common-part      ((,class (:foreground ,purple :weight bold))))
   `(completions-first-difference ((,class (:foreground ,fg1 :weight bold))))
   `(completions-annotations      ((,class (:foreground ,comment :slant italic))))
   `(completion-preview           ((,class (:foreground ,comment))))
   `(completion-preview-common    ((,class (:foreground ,comment))))

   ;; Isearch/occur/compilation
   `(compilation-error   ((,class (:foreground ,red :weight bold))))
   `(compilation-warning ((,class (:foreground ,yellow))))
   `(compilation-info    ((,class (:foreground ,green))))
   `(compilation-line-number ((,class (:foreground ,yellow))))

   ;; Tab bar / tab line
   `(tab-bar             ((,class (:foreground ,comment :background ,bg1))))
   `(tab-bar-tab         ((,class (:foreground ,fg1 :background ,bg3 :weight bold))))
   `(tab-bar-tab-inactive ((,class (:foreground ,comment :background ,bg1))))
   `(tab-line            ((,class (:foreground ,comment :background ,bg1))))

   ;; Whitespace / fill
   `(whitespace-space     ((,class (:foreground ,bg2))))
   `(whitespace-tab       ((,class (:foreground ,bg2))))
   `(whitespace-newline   ((,class (:foreground ,bg2))))
   `(whitespace-trailing  ((,class (:background ,red))))
   `(whitespace-line      ((,class (:foreground ,red :background ,bg1))))
   `(fill-column-indicator ((,class (:foreground ,bg1))))

   ;; Diff / ediff
   `(diff-added        ((,class (:foreground ,green2 :background ,diff-add :extend t))))
   `(diff-removed      ((,class (:foreground ,red :background ,diff-delete :extend t))))
   `(diff-changed      ((,class (:foreground ,yellow :background ,diff-change :extend t))))
   `(diff-refine-added   ((,class (:background ,diff-text))))
   `(diff-refine-removed ((,class (:background ,diff-delete))))
   `(diff-header       ((,class (:foreground ,blue :background ,bg1))))
   `(diff-file-header  ((,class (:foreground ,purple :weight bold))))
   `(diff-hunk-header  ((,class (:foreground ,cyan :background ,bg1))))
   `(ediff-current-diff-A ((,class (:background ,diff-delete))))
   `(ediff-current-diff-B ((,class (:background ,diff-add))))
   `(ediff-fine-diff-A    ((,class (:background ,diff-delete))))
   `(ediff-fine-diff-B    ((,class (:background ,diff-text))))

   ;; Org mode
   `(org-level-1     ((,class (:foreground ,purple :weight bold))))
   `(org-level-2     ((,class (:foreground ,cyan :weight bold))))
   `(org-level-3     ((,class (:foreground ,green :weight bold))))
   `(org-level-4     ((,class (:foreground ,yellow :weight bold))))
   `(org-level-5     ((,class (:foreground ,orange :weight bold))))
   `(org-level-6     ((,class (:foreground ,blue :weight bold))))
   `(org-level-7     ((,class (:foreground ,pink :weight bold))))
   `(org-level-8     ((,class (:foreground ,fg :weight bold))))
   `(org-document-title ((,class (:foreground ,purple :weight bold :height 1.3))))
   `(org-todo        ((,class (:foreground ,red :weight bold))))
   `(org-done        ((,class (:foreground ,green2 :weight bold))))
   `(org-headline-done ((,class (:foreground ,comment))))
   `(org-code        ((,class (:foreground ,green2))))
   `(org-verbatim    ((,class (:foreground ,green2))))
   `(org-block       ((,class (:background ,bg-1 :extend t))))
   `(org-block-begin-line ((,class (:foreground ,comment :background ,bg-1 :extend t))))
   `(org-block-end-line   ((,class (:foreground ,comment :background ,bg-1 :extend t))))
   `(org-link        ((,class (:foreground ,purple :underline t))))
   `(org-date        ((,class (:foreground ,cyan :underline t))))
   `(org-table       ((,class (:foreground ,fdim))))
   `(org-quote       ((,class (:foreground ,comment :slant italic))))
   `(org-special-keyword ((,class (:foreground ,yellow))))

   ;; Markdown
   `(markdown-header-face-1   ((,class (:foreground ,purple :weight bold))))
   `(markdown-header-face-2   ((,class (:foreground ,cyan :weight bold))))
   `(markdown-header-face-3   ((,class (:foreground ,green :weight bold))))
   `(markdown-header-face-4   ((,class (:foreground ,yellow :weight bold))))
   `(markdown-code-face       ((,class (:foreground ,green2 :background ,bg-1 :extend t))))
   `(markdown-inline-code-face ((,class (:foreground ,green2))))
   `(markdown-link-face       ((,class (:foreground ,purple))))
   `(markdown-url-face        ((,class (:foreground ,cyan :underline t))))
   `(markdown-list-face       ((,class (:foreground ,yellow))))
   `(markdown-blockquote-face ((,class (:foreground ,comment :slant italic))))

   ;; Dired
   `(dired-directory ((,class (:foreground ,purple :weight bold))))
   `(dired-symlink   ((,class (:foreground ,cyan))))
   `(dired-header    ((,class (:foreground ,purple :weight bold))))
   `(dired-flagged   ((,class (:foreground ,red))))
   `(dired-marked    ((,class (:foreground ,yellow))))
   `(dired-perm-write ((,class (:foreground ,green2))))

   ;; VC / eglot / flymake / flycheck
   `(flymake-error   ((,class (:underline (:style wave :color ,red)))))
   `(flymake-warning ((,class (:underline (:style wave :color ,yellow)))))
   `(flymake-note    ((,class (:underline (:style wave :color ,cyan)))))
   `(flycheck-error   ((,class (:underline (:style wave :color ,red)))))
   `(flycheck-warning ((,class (:underline (:style wave :color ,yellow)))))
   `(flycheck-info    ((,class (:underline (:style wave :color ,cyan)))))
   `(eglot-highlight-symbol-face ((,class (:background ,bg2))))

   ;; Which-key / vertico / orderless / company (common third-party)
   `(vertico-current      ((,class (:background ,bg3 :extend t))))
   `(orderless-match-face-0 ((,class (:foreground ,purple :weight bold))))
   `(orderless-match-face-1 ((,class (:foreground ,cyan :weight bold))))
   `(orderless-match-face-2 ((,class (:foreground ,green :weight bold))))
   `(orderless-match-face-3 ((,class (:foreground ,yellow :weight bold))))
   `(company-tooltip            ((,class (:foreground ,fg :background ,bg-1))))
   `(company-tooltip-selection  ((,class (:foreground ,fg1 :background ,bg3))))
   `(company-tooltip-common     ((,class (:foreground ,purple :weight bold))))
   `(company-tooltip-annotation ((,class (:foreground ,comment))))
   `(company-scrollbar-bg       ((,class (:background ,bg2))))
   `(company-scrollbar-fg       ((,class (:background ,bg4))))
   `(which-key-key-face         ((,class (:foreground ,yellow))))
   `(which-key-command-description-face ((,class (:foreground ,fg))))
   `(which-key-group-description-face   ((,class (:foreground ,purple))))

   ;; Misc
   `(highlight-numbers-number ((,class (:foreground ,orange))))
   `(hl-todo         ((,class (:foreground ,yellow :weight bold))))
   `(widget-field    ((,class (:background ,bg1 :foreground ,fg))))
   `(custom-group-tag ((,class (:foreground ,purple :weight bold))))
   `(custom-variable-tag ((,class (:foreground ,cyan :weight bold))))
   `(custom-state    ((,class (:foreground ,green)))))

  ;; Terminal colours (ANSI 0-15), mirroring slate.lua's terminal_color_*
  (custom-theme-set-variables
   'slate
   `(ansi-color-names-vector
     [,bg2 ,red ,green ,yellow ,blue ,purple ,cyan ,fg])))

(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'slate)

;;; slate-theme.el ends here
