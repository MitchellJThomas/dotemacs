;;; package --- Managing installed packages and their configuration
;;; Commentary: This was Hai's package.el file and now its being
;;; subverted into mine (over time) provides env variables for emacs
;;; when starting from macOS UI

(use-package bind-key)

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config
  ;; python env needed for lsp-pyls to work w/ pipenv
  (setq exec-path-from-shell-variables '("PATH" "MANPATH" "PYENV_ROOT" "PIPENV_PYTHON"))
  (exec-path-from-shell-initialize))

;; ---------------------
;; general customization
;; ---------------------
(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results nil)
  (auto-package-update-maybe))

;; Need to install icons: M-x all-the-icons-install-fonts
;; (use-package all-the-icons)

;; (use-package doom-modeline
;;   :pin melpa-stable
;;   :init (doom-modeline-mode 1)
;;   :config
;;   (setq doom-modeline-buffer-encoding nil
;;         doom-modeline-buffer-file-name-style 'buffer-name
;;         doom-modeline-buffer-modification-icon t
;;         doom-modeline-buffer-state-icon nil
;;         doom-modeline-minor-modes t
;;         doom-modeline-vcs-max-length 20))

;; (use-package material-theme
;;   :pin melpa-stable
;;   :config
;;   (load-theme 'material t)
;;   (set-face-attribute 'mode-line nil :box '(:line-width 1 :color "grey75" :style "released-button")))

;; (use-package winum :config (winum-mode))
;; (use-package time
;;   :config
;;   (setq display-time-string-forms `(24-hours ":" minutes))
;;   (display-time-mode))

(use-package diminish)
(diminish 'abbrev-mode)
(diminish 'eldoc-mode)
(diminish 'isearch-mode)

(use-package autorevert
  :config
  (setq auto-revert-mode-text " ↺"
        auto-revert-tail-mode-text " ↓"))

;; ----------
;; util stuff
;; ----------
``
;; reuse buffer in dired mode
(use-package dired-single
  :preface
  (defun dired-single-keybind ()
     "Bunch of stuff to run for dired, either immediately or when it's loaded."
     (define-key dired-mode-map [return] 'dired-single-buffer)
     (define-key dired-mode-map [mouse-1] 'dired-single-buffer-mouse)
     (define-key dired-mode-map "^"
       (function
        (lambda nil (interactive) (find-alternate-file "..")))) )
  :config
  ;; if dired is already loaded, then the keymap will be bound
  (if (boundp 'dired-mode-map)
      ;; just add our bindings
      (dired-single-keybind)
    ;; otherwise add our bindings to the load-hook
    (add-hook 'dired-load-hook 'dired-single-keybind)))

;; org mode
(use-package org
  :hook (org-mode . turn-on-auto-fill)
  :config (setq org-startup-folded t))
(use-package org-bullets
  :hook (org-mode . (lambda () (org-bullets-mode 1))))
;; slide presentation with org files
;; (use-package zpresent :init (require 'cl))

;; completion with comp[lete]any[thing]
(use-package company
  :diminish " →"
  :hook ((prog-mode . company-mode))
  :config
  (setq company-idle-delay .3
        company-tooltip-idle-delay .5
        company-tooltip-limit 20
        company-minimum-prefix-length 1
	company-show-quick-access t
	;; cancel selections by typing non-matching characters
        company-require-match 'never
        ;; disable downcase candidates with dabbrev
        company-dabbrev-downcase nil)
  (define-key company-active-map [escape] 'company-abort)
  (define-key company-active-map [tab] 'company-complete-common-or-cycle))

(use-package company-quickhelp
  :disabled
  :after company :config (company-quickhelp-mode))

(use-package markdown-mode
  :mode ("\\.md\\'" "\\.mkd\\'" "\\.markdown\\'"))

(use-package smartparens :config (smartparens-global-mode))

(use-package yaml-mode :mode ("\\.yml\\'" "\\.yaml\\'"))
(use-package yasnippet
  ;;:diminish yas-minor-mode
  :hook ((prog-mode . yas-minor-mode))
  :config (yas-reload-all))

(use-package flx)

;; ivy is a generic completion mechanism for emacs
(use-package ivy
  :diminish " \u2766"
  ;; :bind (:map ivy-minibuffer-faces
  ;;             ("TAB" . ivy-partial))
  :config
  (ivy-mode)
  ;; see https://emacs.stackexchange.com/questions/44455/how-do-i-prevent-autocompletion-when-trying-to-save-a-file
  (setq ivy-initial-inputs-alist nil
        ivy-magic-slash-non-match-action nil
        ivy-use-virtual-buffers t
        enable-recursive-minibuffers t)

  ;; use fuzzy matching everywhere except in swiper
  (setq ivy-re-builders-alist
      '((swiper . ivy--regex-plus)
        (t      . ivy--regex-fuzzy))))

(use-package swiper :bind ("C-s" . swiper))
(use-package counsel
  :diminish ""
  :config (counsel-mode 1))

;; projectile
(use-package projectile
  :diminish (projectile-mode . " ∏")
  :bind-keymap (("s-p" . projectile-command-map)
                ("C-c p" . projectile-command-map))
  :config
  (setq projectile-completion-system 'ivy
        projectile-project-search-path '("~/working")
        projectile-globally-ignored-files '(".DS_Store" "*.jar" "*~")
        projectile-globally-ignored-directories (cl-union projectile-globally-ignored-directories
                                                          '("build"
                                                            "builddir"
                                                            "node_modules"
                                                            "out")))
  (projectile-register-project-type 'gradlew '("gradlew")
                                    :compile "./gradlew build"
                                    :test "./gradlew test"
                                    :test-suffix "Test"
                                    :test-prefix "Test")
  (projectile-mode +1))

;; since [s-p] is used as keymap prefix, make sure emacs can get it on Windows
(if (string-equal system-type "windows-nt")
    (w32-register-hot-key [s-p]))

(use-package treemacs) ; used by lsp-java
(use-package hydra) ; used by dap-mode

;; -----------
;; programming
;; -----------

(use-package highlight-indentation
  :hook ((prog-mode . highlight-indentation-current-column-mode)
         (yaml-mode . highlight-indentation-current-column-mode)))
(use-package smart-shift
  :config (global-smart-shift-mode 1))
(use-package sh-script
  :config
  (setq-default sh-indentation 2
                sh-basic-offset 2))

;; magit
(use-package magit
  :config
  (global-set-key (kbd "C-x m") 'magit-status)
  (use-package magit-section))

(use-package magit-find-file)
(use-package magit-filenotify)

;; (use-package gradle-run-mode
;;   :load-path "site-packages"
;;   :diminish gradle-run-mode
;;   :config (gradle-run-mode))

(use-package flycheck
  :diminish " √"
  :config
  ;; disable JHint because ESLint is better
  (setq-default flycheck-disabled-checkers '(javascript-jshint))
  (global-flycheck-mode))

(use-package cc-mode
  :preface
  (defun my:java-mode-hook ()
    (setq c-basic-offset 2)
    (c-set-offset 'inline-open 0)
    (c-set-offset 'arglist-intro '+)
    (c-set-offset 'arglist-close 0)
    ;; Regex for parsing java compilation errors from gradle output
    (add-to-list 'compilation-error-regexp-alist '("\\(.*compile.*?Java\\)?\\(.*\\):\\([0-9]+\\): \\(\\(warning\\)\\|error\\)" 2 3 nil (5)))
    (add-to-list 'write-file-functions 'delete-trailing-whitespace))
  (defun my:c++-mode-hook ()
    (c-set-offset 'inline-open 0)
    (c-set-offset 'brace-list-open '*)
    (c-set-offset 'block-open 0)
    (c-set-offset 'case-label '*)
    (c-set-offset 'access-label '/))
  :hook ((java-mode . my:java-mode-hook)
         (c++-mode . my:c++-mode-hook)))

(use-package clojure-mode)

(use-package lsp-mode
  :hook ((java-mode . lsp)
	 (clojure-mode . lsp)
	 (clojurescript-mode . lsp)
	 (clojurec-mode . lsp))
  ;; Most generic way to hook a language... but not all languages have
  ;; a language server e.g. emacs-lisp (prog-mode . lsp-deferred)
  
  ;; see https://emacs-lsp.github.io/lsp-mode/tutorials/clojure-guide for clojure specifics
  :commands (lsp lsp-deferred)
  ;; to save space since doom-modeline provides lsp state
  :diminish ""
  ;; can't bind with lsp-keymap-prefix. see https://github.com/emacs-lsp/lsp-mode/issues/1532
  :bind-keymap ("C-c l" . lsp-command-map)
  :config
   (setq lsp-enable-file-watchers nil
	lsp-lens-enable t
	lsp-enable-indentation nil
        lsp-enable-on-type-formatting nil
        lsp-idle-delay 0.5
	lsp-enable-links nil
        ;; nil to shutdown the LSP server when all of its buffers are closed
        lsp-keep-workspace-alive nil
        ;; non-nil to print messages from/to lang server to *lsp-log* buffer
        lsp-log-io nil
        lsp-server-trace nil)
  ;; Settings for performance. See https://github.com/emacs-lsp/lsp-mode#performance
  (setq gc-cons-threshold (* 10 1024 1024); 10mb (default is 800000)
        ;; 1mb (default is 4k)
        read-process-output-max (* 1024 1024)))

(use-package lsp-ui
  ;:hook (lsp-mode . lsp-ui-mode)
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-enable nil
        lsp-ui-doc-delay 1.5
        lsp-ui-sideline-enable t
        lsp-ui-sideline-delay 1.0
        lsp-ui-sideline-ignore-duplicate t
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-symbol nil
        lsp-ui-sideline-update-mode 'line))
  ;; :bind (:map lsp-ui-mode-map
  ;;             ("C-c C-l u a" . lsp-ui-sideline-apply-code-action)))

(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-error-list)

(use-package company-lsp
  :disabled ;; since lsp-mode v6.+; prefer lsp-mode's company-capf
  :after company
  :commands company-lsp
  :config
  (push 'company-lsp company-backends)
  (setq company-lsp-async t
        company-lsp-cache-candidates 'auto
        company-lsp-enable-recompletion t
        company-lsp-enable-snippet t))

;; lsp-java needs treemacs to compile
(use-package lsp-java
  :after lsp-mode
  :config
  (setq lsp-java-completion-favorite-static-members ["com.google.common.base.Preconditions.*"
                                                     "org.testng.Assert.*"
                                                     "org.junit.Assert.*"
                                                     "org.junit.Assume.*"
                                                     "org.junit.jupiter.api.Assertions.*"
                                                     "org.junit.jupiter.api.Assumptions.*"
                                                     "org.junit.jupiter.api.DynamicContainer.*"
                                                     "org.junit.jupiter.api.DynamicTest.*"
                                                     "org.mockito.Mockito.*"]
        lsp-java-import-gradle-enabled t
        lsp-java-completion-import-order ["com.tripwire"
                                          "tw"
                                          "java"
                                          "javax"
                                          "static"]
        ;;lsp-java-java-path "~/opt/jdk-11.0.2.jdk/Contents/Home/bin/java")
        lsp-java-java-path "java"
        lsp-java-signature-help-enabled nil))

;; https://github.com/pwalsh/pipenv.el
(use-package pipenv
  :hook (python-mode . pipenv-mode)
  :init
  (setq
   pipenv-projectile-after-switch-function
   #'pipenv-projectile-after-switch-extended))

(use-package lsp-python-ms
  :init (setq lsp-python-ms-auto-install-server t)
  :hook (python-mode . (lambda ()
                          (require 'lsp-python-ms)
                          (lsp-deferred))))  ; or lsp

(use-package dap-mode)

(use-package protobuf-mode :mode ("\\.proto\\'"))

(use-package groovy-mode
  :mode ("\\.gradle\\'" "\\.groovy\\'")
  :config
  (setq groovy-indent-offset 2)
  (add-to-list 'lsp-language-id-configuration '(groovy-mode . "groovy")))

(use-package js
  :hook (js-mode . (lambda () (setq-local mode-name "js")))
  :config (setq js-indent-level 2))

(use-package typescript-mode
  :hook (typescript-mode . (lambda () (setq-local mode-name "ts")))
  :config (setq typescript-indent-level 2))

(use-package web-mode
  :mode ("\\.html?\\'" "\\.tsx\\'" "\\.jsx\\'")
  :config
  (setq web-mode-comment-style 1
        web-mode-code-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-markup-indent-offset 2

        web-mode-enable-auto-closing t
        web-mode-enable-auto-indentation nil
        web-mode-enable-auto-pairing t
        web-mode-enable-comment-interpolation t
        web-mode-enable-control-block-indentation nil
        web-mode-enable-css-colorization t
        web-mode-enable-current-column-highlight t
        web-mode-enable-current-element-highlight t
        web-mode-enable-current-element-highlight t)

  ;; set up html-helpter-timestamp
  (autoload 'hhmts-mode "hhmts" " hhmts" t)
  (setq html-helper-timestamp-hook
        `(lambda () (insert "Last updated: " (format-time-string "%Y-%m-%d %T %z")))))

(use-package terraform-mode
  :mode ("\\.tf\\'")
  :hook (terraform-mode . terraform-format-on-save-mode))
(use-package company-terraform :config (company-terraform-init))

(use-package dockerfile-mode
  :mode ("Dockerfile\\'")
  :config
  (put 'dockerfile-image-name 'safe-local-variable #'stringp))

(use-package kubernetes-helm)

(use-package rego-mode)

(use-package restclient)

;; clojure
(use-package smartparens
  :config (smartparens-global-strict-mode))
(use-package cider)

(use-package json-mode)

(use-package graphql-mode)


;; (provide (quote packages))
;;; packages.el ends here

