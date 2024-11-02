;;; package -- Init
;;; Commentary:
;;; Code:

;; Enable line number column in prog modes
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Put custom variables to a separate file
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(set-fringe-mode 10)
(menu-bar-mode -1)
(setq ring-bell-function 'ignore) ;; No sound notifications during typing "error"

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(set-face-attribute 'default nil :font "Roboto Mono-14:weight=light") ;; Setup main font


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

;; Install evil-mode
(use-package evil
  :init
  (setq evil-want-C-i-jump nil) ;; org-mode tab cycle support
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo))


(with-eval-after-load 'evil
  (define-key evil-motion-state-map (kbd "C-f") nil)
  (define-key evil-motion-state-map (kbd "K") nil)
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "g c") 'comment-or-uncomment-region)
  (define-key global-map (kbd "C-f") nil))


;; Install ivy completion framework
(use-package swiper)
(use-package counsel)
(use-package ivy
  :ensure t
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config (ivy-mode 1))


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

;; Setup nano theme
;; (quelpa
;; '(nano-theme
;;   :fetcher github
;;   :repo "rougier/nano-theme"))
;; (require 'nano-theme)
;; (load-theme 'nano-light t)

;; Setup Stimmung theme
(use-package stimmung-themes
  :demand t
  :ensure t
  :config (stimmung-themes-load-light))

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

;; Set move bindings for flycheck lsp error messages
;; (with-eval-after-load 'flycheck
;;   (with-eval-after-load 'evil
;;     (define-key flycheck-mode-map (kbd "]d") 'flycheck-next-error)
;;     (define-key flycheck-mode-map (kbd "[d") 'flycheck-previous-error)))

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

;;; init.el ends here
