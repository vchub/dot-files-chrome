;;; init.el --- Emacs configuration -*- lexical-binding: t -*-

;;; Commentary:

;; Save the contents of this file to ~/.config/emacs/init.el and
;; you're ready to boot up Emacs.

;; Hack this file! One of the best ways to get started with Emacs is
;; to look at other peoples' configurations and extract the pieces
;; that work for you. That's where this configuration started. I
;; encourage you to read through the code in this file and explore the
;; functions and variables using the built-in help system (details
;; below). Happy hacking!

;; "C-<chr>  means hold the CONTROL key while typing the character <chr>.
;; Thus, C-f would be: hold the CONTROL key and type f." (Emacs tutorial)
;;
;; - C-h t: Start the Emacs tutorial
;; - C-h o some-symbol: Describe symbol
;; - C-h C-q: Pull up the quick-help cheatsheet

;;; Code:

;; work around for emac 28
;; https://emacs.stackexchange.com/questions/69066/problem-loading-packages-with-emacs-28
                                        ; (setq find-file-visit-truename nil)



;; Performance tweaks for modern machines
(setq gc-cons-threshold 100000000) ; 100 mb
(setq read-process-output-max (* 1024 1024)) ; 1mb

;; Remove extra UI clutter by hiding the scrollbar, menubar, and toolbar.
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Set the font. Note: height = px * 100
;; (set-face-attribute 'default nil :font "Courier New" :height 120)
(set-face-attribute 'default nil  :height 120)

;; Add unique buffer names in the minibuffer where there are many
;; identical files. This is super useful if you rely on folders for
;; organization and have lots of files with the same name,
;; e.g. foo/index.ts and bar/index.ts.
(require 'uniquify)

;; Automatically insert closing parens
(electric-pair-mode t)

;; Visualize matching parens
(show-paren-mode 1)

;; Prefer spaces to tabs
(setq-default indent-tabs-mode nil)

;; Automatically save your place in files
(save-place-mode t)

;; Save history in minibuffer to keep recent commands easily accessible
(savehist-mode t)

;; Keep track of open files
(recentf-mode t)

;; Keep files up-to-date when they change outside Emacs
(global-auto-revert-mode t)

;; Display line numbers only when in programming modes
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; The `setq' special form is used for setting variables. Remember
;; that you can look up these variables with "C-h v variable-name".
(setq uniquify-buffer-name-style 'forward
      window-resize-pixelwise t
      frame-resize-pixelwise t
      load-prefer-newer t
      backup-by-copying t
      ;; Backups are placed into your Emacs directory, e.g. ~/.config/emacs/backups
      backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
      ;; I'll add an extra note here since user customizations are important.
      ;; Emacs actually offers a UI-based customization menu, "M-x customize".
      ;; You can use this menu to change variable values across Emacs. By default,
      ;; changing a variable will write to your init.el automatically, mixing
      ;; your hand-written Emacs Lisp with automatically-generated Lisp from the
      ;; customize menu. The following setting instead writes customizations to a
      ;; separate file, custom.el, to keep your init.el clean.
      custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Bring in package utilities so we can install packages from the web.
(require 'package)


;;; PACKAGE LIST
(setq package-install-upgrade-built-in t)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("elpa" . "https://elpa.gnu.org/packages/")
        ;; ("gnu-devel" . "https://elpa.gnu.org/devel/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

;;; BOOTSTRAP USE-PACKAGE
(package-initialize)

;; Unless we've already fetched (and cached) the package archives,
;; refresh them.
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

                                        ;
(require 'use-package)

;; Add the :vc keyword to use-package, making it easy to install
;; packages directly from git repositories.
                                        ; (unless (package-installed-p 'vc-use-package)
                                        ;   (package-vc-install "https://github.com/slotThe/vc-use-package"))
                                        ; (require 'vc-use-package)

;; A quick primer on the `use-package' function (refer to
;; "C-h f use-package" for the full details).
;;
;; (use-package my-package-name
;;   :ensure t    ; Ensure my-package is installed
;;   :after foo   ; Load my-package after foo is loaded (seldom used)
;;   :init        ; Run this code before my-package is loaded
;;   :bind        ; Bind these keys to these functions
;;   :custom      ; Set these variables
;;   :config      ; Run this code after my-package is loaded

;; A package with a great selection of themes:
;; https://protesilaos.com/emacs/ef-themes
;; (use-package ef-themes
;;   :ensure t
;;   :config
;;   (ef-themes-select 'ef-duo-light))

;; Minibuffer completion is essential to your Emacs workflow and
;; Vertico is currently one of the best out there. There's a lot to
;; dive in here so I recommend checking out the documentation for more
;; details: https://elpa.gnu.org/packages/vertico.html. The short and
;; sweet of it is that you search for commands with "M-x do-thing" and
;; the minibuffer will show you a filterable list of matches.
(use-package vertico
  :ensure t
  :custom
  (vertico-cycle t)
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t)
  (completion-styles '(basic substring partial-completion))
  :init

  ;; (use-package orderless
  ;;   :ensure t
  ;;   :commands (orderless)
  ;;   :custom (completion-styles '(orderless flex)))

  (vertico-mode)
  )


(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless flex))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Improve the accessibility of Emacs documentation by placing
;; descriptions directly in your minibuffer. Give it a try:
;; "M-x find-file".
(use-package marginalia
  :after vertico
  :ensure t
  :init
  (marginalia-mode))

;; Adds intellisense-style code completion at point that works great
;; with LSP via Eglot. You'll likely want to configure this one to
;; match your editing preferences, there's no one-size-fits-all
;; solution.
(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)
  ;; You may want to play with delay/prefix/styles to suit your preferences.
  (corfu-auto-delay 0)
  (corfu-auto-prefix 0)
  (completion-styles '(flex))
  )

;; Adds LSP support. Note that you must have the respective LSP
;; server installed on your machine to use it with Eglot. e.g.
;; rust-analyzer to use Eglot with `rust-mode'.
                                        ; (use-package eglot
                                        ;   :ensure t
                                        ;   :bind (("s-<mouse-1>" . eglot-find-implementation)
                                        ;          ("C-c ." . eglot-code-action-quickfix)))

;; Add extra context to Emacs documentation to help make it easier to
;; search and understand. This configuration uses the keybindings 
;; recommended by the package author.
(use-package helpful
  :ensure t
  :bind (("C-h f" . #'helpful-callable)
         ("C-h v" . #'helpful-variable)
         ("C-h k" . #'helpful-key)
         ("C-c C-d" . #'helpful-at-point)
         ("C-h F" . #'helpful-function)
         ("C-h C" . #'helpful-command)))


;; An extremely feature-rich git client. Activate it with "C-c g".
(use-package magit
  :ensure t
  ;; :bind (("C-c g" . magit-status))
  )


;; Key and chords ================

;; ESC Cancels All
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; use ibuffer for buffer management
(global-set-key (kbd "C-x C-b" ) 'ibuffer)

(use-package undo-tree
  :init
  (global-undo-tree-mode 1))

;; (defun dw/evil-hook ()
;;   (dolist (mode '(custom-mode
;;                   eshell-mode
;;                   git-rebase-mode
;;                   erc-mode
;;                   circe-server-mode
;;                   circe-chat-mode
;;                   circe-query-mode
;;                   sauron-mode
;;                   term-mode))
;;   (add-to-list 'evil-emacs-state-modes mode)))


;; Adds vim emulation. Activate `evil-mode' to swap your default Emacs
;; keybindings with the modal editor of great infamy. There's a ton of
;; keybindings that Evil needs to modify, so this configuration also
;; includes `evil-collection' to fill in the gaps.

(use-package evil
  :ensure t

  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-undo-system 'undo-tree)

  ;; no vim insert bindings
  (setq evil-disable-insert-state-bindings t)

  (setq evil-respect-visual-line-mode t)
  (setq evil-want-Y-yank-to-eol t)
  (setq evil-split-window-below t)
  (setq evil-split-window-right t)

  :config
  ;; (add-hook 'evil-mode-hook 'dw/evil-hook)
  (evil-mode 1)
  (evil-set-leader 'normal " ")


  ;; Use visual line motions even outside of visual-line-mode buffers
  ;; (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  ;; (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  :bind (:map evil-normal-state-map
              ;; ("C-s" . consult-line)
              ;; Better lisp bindings
              ("(" . evil-previous-open-paren)
              (")" . evil-next-close-paren)
              ("<leader>/" . evil-ex-nohighlight)
              ;; ("C-n" . evil-next-line)
              ;; ("C-p" . evil-previous-line)
              :map evil-operator-state-map
              ("(" . evil-previous-open-paren)
              (")" . evil-previous-close-paren)
              :map evil-insert-state-map
              ("C-g" . evil-normal-state)
              ("C-h" . evil-delete-backward-char-and-join)
              ("C-d" . evil-delete-char)

              )
  
  )

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(evil-commentary-mode)
(evil-surround-mode)


;; Key and chords end ================

;; In addition to installing packages from the configured package
;; registries, you can also install straight from version control
;; with the :vc keyword argument. For the full list of supported
;; fetchers, view the documentation for the variable
;; `vc-use-package-fetchers'.
;;
;; Breadcrumb adds, well, breadcrumbs to the top of your open buffers
;; and works great with project.el, the Emacs project manager.
;;
;; Read more about projects here:
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Projects.html
                                        ; (use-package breadcrumb
                                        ;   :vc (:fetcher github :repo joaotavora/breadcrumb)
                                        ;   :init (breadcrumb-mode))

;; As you've probably noticed, Lisp has a lot of parentheses.
;; Maintaining the syntactical correctness of these parentheses
;; can be a pain when you're first getting started with Lisp,
;; especially when you're fighting the urge to break up groups
;; of closing parens into separate lines. Luckily we have
;; Paredit, a package that maintains the structure of your
;; parentheses for you. At first, Paredit might feel a little
;; odd; you'll probably need to look at a tutorial (linked
;; below) or read the docs before you can use it effectively.
;; But once you pass that initial barrier you'll write Lisp
;; code like it's second nature.
;; http://danmidwood.com/content/2014/11/21/animated-paredit.html
;; https://stackoverflow.com/a/5243421/3606440
(use-package paredit
  :ensure t
  :hook ((emacs-lisp-mode . enable-paredit-mode)
         (lisp-mode . enable-paredit-mode)
         (ielm-mode . enable-paredit-mode)
         (lisp-interaction-mode . enable-paredit-mode)
         (scheme-mode . enable-paredit-mode)
         (racket-mode . enable-paredit-mode)
         ))

;; for sly
(setq inferior-lisp-program "ros run")
;; (setq inferior-lisp-program "sbcl")
(put 'dired-find-alternate-file 'disabled nil)


;; terminal =============================
(use-package vterm
  :ensure t
  :bind (("C-x v t" . vterm)
         :map vterm-mode-map
         ("M-p" . vterm-send-up)
         ("M-n" . vterm-send-down))

  :commands vterm
  :custom (vterm-max-scrollback 10000)
  )

;; terminal end =============================

;; Get environment variables such as $PATH from the shell
(require 'exec-path-from-shell) ;; if not using the ELPA package
(exec-path-from-shell-initialize)



;; Keybinding Panel (which-key) ==============
;; which-key is great for getting an overview of what keybindings are available based on the prefix keys you entered. Learned about this one from Spacemacs.

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; Keybinding Panel end ==============


;; Projectile =====================
;; Initial Setup

;; (defun dw/switch-project-action ()
;;   "Switch to a workspace with the project name and start `magit-status'."
;;   (persp-switch (projectile-project-name))
;;   (magit-status))


;; (use-package projectile
;;   :diminish projectile-mode
;;   :config (projectile-mode)
;;   :demand t
;;   ;; :bind ("C-M-p" . projectile-find-file)
;;   :bind-keymap
;;   ("C-c p" . projectile-command-map)
;;   :init
;;   (when (file-directory-p "~/code")
;;     (setq projectile-project-search-path '("~/code")))
;;   ;; (setq projectile-switch-project-action #'dw/switch-project-action)
;;   )

;; (use-package counsel-projectile
;;   :disabled
;;   :after projectile
;;   :config
;;   (counsel-projectile-mode))

;; (dw/leader-key-def
;;   "pf"  'projectile-find-file
;;   "ps"  'projectile-switch-project
;;   "pF"  'consult-ripgrep
;;   "pp"  'projectile-find-file
;;   "pc"  'projectile-compile-project
;;   "pd"  'projectile-dired)

;; Adding Custom Project Types
;; If a project you are working on is recognized incorrectly or you want to add your own type of projects you can add following to your Emacs initialization code
;; (projectile-register-project-type 'npm '("package.json")
;;                                   :project-file "package.json"
;; 				  :compile "npm install"
;; 				  :test "npm test"
;; 				  :run "npm start"
;; 				  :test-suffix ".spec")

;; Projectile end =====================

;; javascript ===================
(use-package js2-mode)

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.mjs\\'" . js2-mode))

(add-hook 'js2-mode-hook 'prettier-mode)

;; (add-hook 'js2-mode-hook 'js2-mode-)

(use-package skewer
  :bind (:map skewer-mode
              ("C-c C-c" . skewer-load-buffer)))

;; skewer-mode and js2-mode-hook
(add-hook 'js2-mode-hook 'skewer-mode)
(add-hook 'css-mode-hook 'skewer-css-mode)
(add-hook 'html-mode-hook 'skewer-html-mode)

;; javascript end ===================




;; python staff ===================

;; Use pyvenv to activate the virtual environment
(require 'pyvenv)
(pyvenv-activate "~/jupyter")


;; ;; devdocs
;; (use-package devdocs
;;   :bind ("C-h D" 'devdocs-lookup) 
;;   )
;; (global-set-key (kbd "C-h D") 'devdocs-lookup)


(use-package elpy
  :ensure t
  :init
  (elpy-enable))


;; ruff format
(add-hook 'python-mode-hook 'ruff-format-on-save-mode)
(add-hook 'elpy-mode-hook 'ruff-format-on-save-mode)


;; end python staff ===================

;; Browser inter-ops =================

;; GhostText makes the input on Emacs is reflected to the browser instantly and continuously.
;; You can use both the browser and Emacs at the same time. They are updated to the same content bi-directionally.
(require 'atomic-chrome)
;; (atomic-chrome-start-server)
;; Browser inter ops end =================
