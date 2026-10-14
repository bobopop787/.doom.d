;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)
;; Specify both a dark and light theme, like so and Doom will choose which one
;; to load based on your system light/dark setting:
;;
;;   (setq doom-theme '(doom-one   . doom-one-light))   ; (DARK . LIGHT)
;;
;; If you want more pro-active theme switching based on OS light/dark mode, look
;; up the `auto-dark' package.

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Set custom org-roam directory
(after! org-roam
  (setq org-roam-directory (file-truename "~/org/roam/")
        org-roam-db-location (file-truename "~/org/roam/org-roam.db")))

;; !! Old org-roam directory checkout code

;; (defvar org-roam-library
;;   (mapcar #'expand-file-name
;;           `("~/org/roam/"
;;             "~/org/obj-roam/")))

;; (defun org-roam-directory-to-db-path (roam-dir) (concat roam-dir "org-roam.db"))

;; (defun org-roam-checkout ()
;;   "Switches the active roam directory to one of org-roam-library"
;;   (interactive)
;;   (require 'org-roam)
;;   (let* ((old (expand-file-name org-roam-directory))
;;          (new (if (= (length org-roam-library) 1)
;;                   (progn
;;                     (message "There is only one choice for org-roam-directory defined in ~/.doom.d/config.el (see org-roam-library)")
;;                     (car org-roam-library))
;;                 (completing-read "Choose a roam directory: " org-roam-library nil t))))
;;     (setq org-roam-directory new
;;           org-roam-db-location (expand-file-name "org-roam.db" new))
;;     (unless (equal old new)
;;       (org-roam-db-sync)
;;       (org-roam-node-find))))

;; (map! :leader
;;       :desc "Switch roam directory" "n r c" #'org-roam-checkout)

;; org-roam-library persistence and checkout

(defvar org-roam-library-file (expand-file-name "roam-library.eld" doom-user-dir)
  "File where `org-roam-library' is saved between sessions.")

(defun org-roam-library--load ()
  "Return the list saved in `org-roam-library-file', or nil if there isn't one."
  (when (file-exists-p org-roam-library-file)
    (with-temp-buffer
      (insert-file-contents org-roam-library-file)
      (read (current-buffer)))))

(defun org-roam-library--save ()
  "Write `org-roam-library' to `org-roam-library-file'."
  (with-temp-file org-roam-library-file
    (insert ";; Saved by org-roam-library-create. Safe to edit by hand.\n")
    (pp org-roam-library (current-buffer))))

(defvar org-roam-library
  (or (org-roam-library--load)
      ;; Used only until the first save; after that the file is the source of truth.
      (mapcar #'file-truename
              '("~/org/roam/")))
  "Directories that `org-roam-checkout' can switch between.")

;; org-roam directory-switching commands

(defun org-roam-checkout (&optional dir)
  "Switch the active roam directory to DIR, or to one chosen from `org-roam-library'."
  (interactive)
  (require 'org-roam)
  (let* ((old (file-name-as-directory (file-truename org-roam-directory)))
         (new (cond
               (dir dir)
               ((= (length org-roam-library) 1)
                (message "There is only one choice for org-roam-directory (see %s)"
                         org-roam-library-file)
                (car org-roam-library))
               (t (completing-read "Choose a roam directory: " org-roam-library
                                   nil t nil nil old)))))
    (setq org-roam-directory new
          org-roam-db-location (expand-file-name "org-roam.db" new))
    (unless (equal old new)
      (org-roam-db-sync)
      (org-roam-node-find))))

(defun org-roam-library-create (dir)
  "Create roam directory DIR, add it to `org-roam-library', save, and switch to it."
  (interactive (list (read-directory-name "New roam directory: " "~/org/")))
  (let ((dir (file-name-as-directory (file-truename dir))))
    (when (member dir org-roam-library)
      (user-error "%s is already in the library" dir))
    ;; org-roam indexes subdirectories, so nested roam directories would
    ;; index the same notes twice.
    (when-let* ((clash (seq-find (lambda (d) (or (string-prefix-p d dir)
                                                 (string-prefix-p dir d)))
                                 org-roam-library)))
      (user-error "%s overlaps with %s, which is already in the library" dir clash))
    (make-directory dir t)
    (setq org-roam-library (append org-roam-library (list dir)))
    (org-roam-library--save)
    (org-roam-checkout dir)))

(map! :leader
      :desc "Switch roam directory" "n r c" #'org-roam-checkout
      :desc "New roam directory"    "n r C" #'org-roam-library-create)

;; Set default line numbers to be relative
(setq display-line-numbers-type 'relative)

;; Break whole insert session into multiple undos using emacs' own grouping
(setq evil-want-fine-undo t)

;; windmove keybindings
(windmove-default-keybindings)

;; Suppress lean warning
(defun my/suppress-lsp-inlayhint-warnings (orig-fun type message &rest args)
  "Suppress LSP inlayHint/refresh warnings from popping up."
  (unless (and (eq type 'lsp-mode)
               (string-match-p "workspace/inlayHint/refresh" message))
    (apply orig-fun type message args)))

(advice-add 'display-warning :around #'my/suppress-lsp-inlayhint-warnings)

;; Bind soft wrap toggle to M-Z
(keymap-global-set "M-Z" 'visual-line-mode)
