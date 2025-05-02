;;; package -- Init
;;; Commentary:
;;; Code:

;; Enable line number column in prog modes
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Put custom variables to a separate file
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(setq backup-directory-alist `(("." . "~/.emacs-saves"))) ;; Create backup files in some directory

(setq inhibit-startup-message t) ;; No startup message
(scroll-bar-mode -1) ;; No scroll bar
(tool-bar-mode -1) ;; No tool bar
(set-fringe-mode 10) ;; idk, more space or something
(menu-bar-mode -1) ;; No menu bar
(setq ring-bell-function 'ignore) ;; No sound notifications during typing "error"
(setq-default cursor-type 'bar) ;; Cursor as line

(setq mouse-wheel-progressive-speed nil)
(pixel-scroll-precision-mode) ;; Pixel-based (smooth) scrolling
(setq void-text-area-pointer nil) ;; Set pointer style to line-stye in empty areas

(global-visual-line-mode 1)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(set-face-attribute 'default nil :font "Jetbrains Mono-14") ;; Setup main font

;; Specify emacs backup directory
(setq backup-directory-alist '(("." . "~/emacs-backups")))

;; Do not modify last line
(setq mode-require-final-newline nil)

;; Init package manager
(require 'package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("elpa" . "https://elpa.gnu.org/packages/") t)

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

(setq use-package-always-ensure t)

;; Install quelpa
(unless (package-installed-p 'quelpa)
  (package-install 'quelpa))

(require 'quelpa)

;; Install vertico/consult
(use-package vertico
             :ensure t
             :bind (:map minibuffer-local-map
                         ("C-j" . vertico-next)
                         ("C-k" . vertico-previous))
             :init (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position
(use-package savehist
             :init
             (savehist-mode))

;; Use `orderless` completion style.
(use-package orderless
             :custom
             (completion-styles '(orderless basic))
             (completion-category-defaults nil)
             (completion-category-overrides '((file (styles partial-completion)))))

;; Example configuration for Consult
(use-package consult
  :after consult-project-extra
  :bind (("C-x c f" . consult-fd)
	 ("C-x c g" . consult-ripgrep)
	 ("C-x c b" . consult-buffer)
	 ("C-x c p" . consult-project-extra-find))

  ;; TODO: Setup bindings

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  (setq consult-fd-args "fd --full-path --color=never -H -E \".git\"")

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
)


(defun local/org-mode-setup ()
  (org-indent-mode))

(use-package org
  :hook (org-mode . local/org-mode-setup)
  :init
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-agenda-files
	'("~/Documents/org/tasks/todo.org"
	  "~/Documents/org/notes/birthdays.org"))
  (setq org-directory "~/Documents/org")
  (setq org-default-notes-file (concat org-directory "/tasks/todo.org"))
  :config
  (setq org-ellipsis " ▾"))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;; Fix "Package spinner 1.7.3 is unavailable" error
(use-package gnu-elpa-keyring-update)

(use-package all-the-icons
  :if (display-graphic-p))

;; Enable scala-mode for highlighting, indentation and motion commands
(use-package scala-mode
  :interpreter ("scala" . scala-mode))

;; Enable sbt mode for executing sbt commands
(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
   ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
   (setq sbt:program-options '("-Dsbt.supershell=false")))

;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :init (global-flycheck-mode))

(use-package lsp-mode
  :hook  (scala-mode . lsp)
         (lsp-mode . lsp-lens-mode)
  :config
  (setq gc-cons-threshold 100000000) ;; 100mb
  (setq read-process-output-max (* 1024 1024)) ;; 1mb
  (setq lsp-idle-delay 0.500)
  (setq lsp-log-io nil)
  (setq lsp-completion-provider :capf)
  (setq glsp-prefer-flymake nil)

  (define-key lsp-mode-map (kbd "C-f") 'lsp-format-buffer)
  ;; (define-key lsp-mode-map (kbd "g r") 'lsp-ui-peek-find-references)
  (define-key lsp-mode-map (kbd "K") 'lsp-signature-activate)

  (define-key lsp-mode-map (kbd "C-c r") lsp-command-map)

  ;; Makes LSP shutdown the metals server when all buffers in the project are closed.
  ;; https://emacs-lsp.github.io/lsp-mode/page/settings/mode/#lsp-keep-workspace-alive
  (setq lsp-keep-workspace-alive nil))

;; Add metals backend for lsp-mode
(use-package lsp-metals)

(use-package lsp-ui)

(use-package yasnippet)

;; Use company-capf as a completion provider.
(use-package company
  :after lsp-mode
  :hook
  (lsp-mode . company-mode)
  (lsp-mode . yas-minor-mode)
  :config
  (setq lsp-completion-provider :capf)
  :bind (:map company-active-map
	      ("C-j" . company-select-next)
	      ("C-k" . company-select-previous))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

;; completion with icons
(use-package company-box
  :hook (company-mode . company-box-mode))

;; Posframe is a pop-up tool that must be manually installed for dap-mode
(use-package posframe)

;; Use the Debug Adapter Protocol for running tests and debugging
(use-package dap-mode
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode))

;; Quick jump to init.el
(global-set-key (kbd "C-c i") (lambda () (interactive)
  (find-file "~/.emacs.d/init.el")
  (message "Opened:  %s" (buffer-name))))

;; Ctrl-HJKL instead of default Emacs movement bindingsh
(global-set-key (kbd "C-j") 'next-line)
(global-set-key (kbd "C-k") 'previous-line)
(global-set-key (kbd "C-l") 'forward-char)
(global-set-key (kbd "C-h") 'backward-char)

;; Install geiser, Scheme runtime/compiler/etc implementation by MIT
(use-package geiser-mit
  :ensure t
  :config
  (setq geiser-mit-binary "/etc/profiles/per-user/user/bin/scheme")
  (setq geiser-active-implementations '(mit)))

(use-package clojure-mode
  :interpreter ("clojure" . clojure-mode))

(use-package cider
  :ensure t
  :config
  (setq cider-show-error-buffer nil))

;; Smart parens auto-closing
(use-package smartparens
  :ensure smartparens  ;; install the package
  :hook (prog-mode text-mode markdown-mode) ;; add `smartparens-mode` to these hooks
  :config
  ;; load default config
  (require 'smartparens-config))

(use-package nix-mode)

(use-package lua-mode)

;; Plugin for better consult project navigation
;; Allows to use narrow function (hit `consult-narrow-key` and type b/p/f)
(use-package consult-project-extra
  :ensure t)

;; Needed for `:after char-fold' to work in reverse-im setup
(use-package char-fold
  :custom
  (char-fold-symmetric t)
  (search-default-mode #'char-fold-to-regexp))

;; Plugin for using hotkeys with different keyboard languages
(use-package reverse-im
  :ensure t ; install `reverse-im' using package.el
  :demand t ; always load it
  :after char-fold ; but only after `char-fold' is loaded
  :bind
  ("M-T" . reverse-im-translate-word) ; fix a word in wrong layout
  :custom
  ;; cache generated keymaps
  (reverse-im-cache-file (locate-user-emacs-file "reverse-im-cache.el"))
  ;; use lax matching
  (reverse-im-char-fold t)
  (reverse-im-read-char-advice-function #'reverse-im-read-char-include)
  :config
  (reverse-im-mode t)) ; turn the mode on

(defvar my-keys-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-j") 'next-line)
    (define-key map (kbd "C-k") 'previous-line)
    (define-key map (kbd "C-l") 'forward-char)
    (define-key map (kbd "C-h") 'backward-char)
    map)
  "my-keys-minor-mode keymap.")

(define-minor-mode my-keys-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  :init-value t
  :lighter " my-keys")

(my-keys-minor-mode 1)

(use-package org-roam
  :ensure t)

;;; init.el ends here
