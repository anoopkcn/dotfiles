(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)

(setq visible-bell nil)

(set-face-attribute 'default nil :font "Berkeley Mono Variable" :height 120)

(setq inhibit-startup-message t)
(setq mouse-drag-copy-region t)

;; slate theme (ported from nvim/colors/slate.lua)
(add-to-list 'custom-theme-load-path
             (expand-file-name "" (file-name-directory load-file-name)))
(load-theme 'slate t)

;; Line numbers (relative, matching a vim-style workflow)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(dolist (mode '(term-mode-hook shell-mode-hook eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; ido — built-in completion
(ido-mode 1)
(ido-everywhere 1)
(setq ido-enable-flex-matching t
      ido-use-virtual-buffers t)
(fido-mode -1) ; ensure ido, not fido, owns completing-read

;; Package management (MELPA) for third-party packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; evil — vim keybindings
(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Dired — detailed listing (permissions, size, creation date)
(use-package dired
  :ensure nil                     ; built-in, don't fetch from MELPA
  :config
  ;; ls flags:
  ;;  -l  long format: permissions, links, owner, group, size, date
  ;;  -a  show dotfiles
  ;;  -h  human-readable sizes (K/M/G)
  ;;  --time=birth  show creation date instead of modification date
  ;;  --group-directories-first  directories on top
  (setq dired-listing-switches
        "-alh --time=birth --group-directories-first")
  (setq dired-dwim-target t                        ; copy/move to the other pane
        dired-kill-when-opening-new-dired-buffer t ; no buffer pileup
        dired-recursive-copies 'always
        dired-recursive-deletes 'always)
  ;; keep the listing in sync with the filesystem automatically
  (add-hook 'dired-mode-hook #'auto-revert-mode))

