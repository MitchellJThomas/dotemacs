(setq debug-on-error nil
      byte-compile-debug t)

(require 'package)
(setq package-archives
      (list '("melpa"        . "https://melpa.org/packages/")
            '("gnu"          . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; load emacs customization
(setq custom-file "~/.emacs.d/custom.el")
(if (file-exists-p custom-file)
    (load custom-file))

;;
;; install use-package, which we'll use to load/configure other packages.
;;
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))
(setq use-package-compute-statistics t)
(setq use-package-always-ensure t)
(setq use-package-verbose t)
(load "~/.emacs.d/packages")
(put 'upcase-region 'disabled nil)
