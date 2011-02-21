;;---------------------------------------------------------
;; .emacs by Scott Jaderholm
;;---------------------------------------------------------
(add-to-list 'load-path "~/.elisp")
(defvar backup-dir (expand-file-name "~/.ebackup/"))
(setq backup-directory-alist (list (cons ".*" backup-dir)))
(defvar autosave-dir (expand-file-name "~/.eautosave/"))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))
(setq visible-bell t)
(setq ring-bell-function (lambda ()))
(fset 'yes-or-no-p 'y-or-n-p)
(setq initial-scratch-message nil)
(setq inhibit-splash-screen t)
(setq x-select-enable-clipboard t)
(show-paren-mode t)
(menu-bar-mode nil)
(tool-bar-mode nil)
(column-number-mode t)
(global-font-lock-mode t)
(icomplete-mode t)
(auto-compression-mode t)
(setq font-lock-maximum-decoration t)
(add-hook 'text-mode-hook 'auto-fill-mode)
(setq transient-mark-mode t)
(delete-selection-mode t)

(setq comment-style 'indent)
(setq frame-title-format
      (list '("emacs ")
            '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))
(setq cursor-in-non-selected-windows nil)
(setq-default indent-tabs-mode nil)
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "conkeror")
;(setq delete-by-moving-to-trash nil) ; slow
(setq read-buffer-completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)
;; nice parameter list hints for emacs-lisp
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode) 
;; M-x ielm if you want a emacs lisp repl
;; C-u C-x C-f finds the file at point (doesn't seem to work)
(setq ffap-require-prefix t)
;; so bit fonts split with vertical bar
(setq split-height-threshold 150)

(require 'pos-tip)
(setq pos-tip-foreground-color "white")
(setq pos-tip-background-color "black")

(defmacro bind (key fn)
  "shortcut for global-set-key"
  `(global-set-key (kbd ,key)
                   ;; handle unquoted function names and lambdas
                   ,(if (listp fn)
                        fn 
                      `',fn)))

(defmacro cmd (name &rest body)
  "declare an interactive command without all the boilerplate"
  `(defun ,name ()
     ,(if (stringp (car body)) (car body))
     ;; tried (let (documented (stringp (first body))) but didn't know gensym
     ;; and couldn't get it to work. should be possible
     (interactive)
     ,@(if (stringp (car body)) (cdr `,body) body)))

(bind "C-c C-r" eval-region)


;;---------------------------------------------------------
;; Windows only settings
;;---------------------------------------------------------
(cmd win32-only-settings
  (add-to-list 'exec-path (file-truename "~/src/win-bin"))
  (add-to-list 'exec-path (file-truename "~/src/conkeror"))

  (cmd w32-maximize-frame
        "Maximize the current frame (windows only)"
        (w32-send-sys-command 61488))

  ;; prompt for font and return string
  (cmd insert-x-style-font
    "Insert a string in the X format which describes a font the
     user can select from the Windows font selector."
    (insert (prin1-to-string (w32-select-font)))))

;;       (t (setq initial-frame-alist
;;                `((left . 0) (top . 0)
;;                  (width . 80) (height . 37)
;;                  ;(scroll-bar-width . 10)
;;                  ))))

;;-----------------------------------------------------------------
;; Linux only settings
;;-----------------------------------------------------------------
(cmd linux-only-settings
  (setq tramp-default-method "ssh"))

(if (eq window-system 'w32)
    (progn (win32-only-settings)
           (setq running-windows t))
  (setq running-windows nil))

(if (eq window-system 'x)
    (progn (linux-only-settings)
           (server-start)
           (setq running-linux t))
  (setq running-linux nil))

;;---------------------------------------------------------
;; ido
;;---------------------------------------------------------
(require 'ido)
(ido-mode t)
(add-hook 'ido-setup-hook 'ido-my-keys) ; _cool
(defun ido-my-keys ()
  (define-key ido-completion-map "\t" 'ido-complete)
  (define-key ido-completion-map "\C-t" 'ido-toggle-regexp) ; same as isearch
  ;(define-key ido-completion-map "\C-d" 'ido-enter-dired) ; now on by default
  )


;;---------------------------------------------------------
;; mpg123
;;---------------------------------------------------------
;; (require 'mpg123)
;; (add-hook 'mpg123-hook '(lambda () (local-unset-key (kbd "<down-mouse-1>"))))
;; (load "mpg123-remote")
;; ;; (setq mpg123-show-help nil)
;; (setq mpg123-lazy-slider t)
;; (setq mpg123-display-slider nil)
;; (setq mpg123-format-name-function 'my-mpg123-format-name-function)

;; (defun my-mpg123-format-name-function (artist album title tracknum filename)
;;   (concat (if (or mpg123-omit-id3-artist
;;                   (string= artist ""))
;;               ""
;;             (concat artist " - "))
;;           (if (string< "" title) title
;;             filename)))

;;---------------------------------------------------------
;; tail
;;---------------------------------------------------------
;; tail a command or file, _cool
(require 'tail)

;;---------------------------------------------------------
;; tramp
;;---------------------------------------------------------
(require 'tramp)

;;---------------------------------------------------------
;; epg
;;---------------------------------------------------------
(require 'epa-file nil t)
(setq epa-file-cache-passphrase-for-symmetric-encryption t)

;;---------------------------------------------------------
;; css
;;---------------------------------------------------------
(autoload 'css-mode "css-mode")
(setq auto-mode-alist (cons '("\\.css\\'" . css-mode) auto-mode-alist))

;;---------------------------------------------------------
;; javascript
;;---------------------------------------------------------
(autoload 'javascript-mode "javascript" nil t)
(add-to-list 'auto-mode-alist '("\\.js\\'" . javascript-mode))

;;---------------------------------------------------------
;; php
;;---------------------------------------------------------
(require 'php-mode)

;;---------------------------------------------------------
;; eshell
;;---------------------------------------------------------
;; Prevent annoying scrolling
(add-hook 'eshell-output-filter-functions
          'eshell-postoutput-scroll-to-bottom)
;; Put a space above eshell prompt
(setq eshell-prompt-function (lambda nil (concat "\n" (eshell/pwd) " $ ")))
;; Make ls output be RET and mouse-2 clickable
(load-library "esh-clickable-ls.el")
;; Type op file or op directory or op . in Eshell to open in explorer, _cool
(defun eshell/open (file)
  (w32-shell-execute "Open" (substitute ?\\ ?/ (expand-file-name file))) nil)

;;---------------------------------------------------------
;; ahk
;;---------------------------------------------------------
(require 'ahk-mode)

;;---------------------------------------------------------
;; csv
;;---------------------------------------------------------
(require 'csv-mode)
(add-to-list 'auto-mode-alist '("\\.[Cc][Ss][Vv]\\'" . csv-mode))

;;---------------------------------------------------------
;; isearch+
;;---------------------------------------------------------
;; Highlights search term section with no occurances
(eval-after-load "isearch" '(require 'isearch+))

;;---------------------------------------------------------
;; isearch occur
;;---------------------------------------------------------
;; M-o from isearch runs occur
(load "ska-occur-from-isearch.el")

;;---------------------------------------------------------
;; highline
;;---------------------------------------------------------
(require 'highline)
(global-highline-mode 1)

;;---------------------------------------------------------
;; smooth-scrolling
;;---------------------------------------------------------
;(require 'smooth-scrolling)

;;---------------------------------------------------------
;; dired
;;---------------------------------------------------------
(defun dired-mouse-find-alternate-file (event)
  "In dired, visit the file or directory you click on instead of
the dired buffer."
  (interactive "e")
  (let (file)
    (save-excursion
      (set-buffer (window-buffer (posn-window (event-end event))))
      (save-excursion
        (goto-char (posn-point (event-end event)))
        (setq file (dired-get-filename))))
    (select-window (posn-window (event-end event)))
    (find-alternate-file (file-name-sans-versions file t))))

(require 'dired-isearch)
(eval-after-load "dired"
  '(progn
     (define-key dired-mode-map (kbd "C-s") 'dired-isearch-forward)
     (define-key dired-mode-map (kbd "C-r") 'dired-isearch-backward)
     (define-key dired-mode-map (kbd "ESC C-s") 'dired-isearch-forward-regexp)
     (define-key dired-mode-map (kbd "ESC C-r")
       'dired-isearch-backward-regexp)))

;;---------------------------------------------------------
;; Rectangle regions
;;---------------------------------------------------------
(bind "C-x r C-SPC" rm-set-mark)
(bind "C-x r C-x" rm-exchange-point-and-mark)
(bind "C-x r C-w" rm-kill-region)
(bind "C-x r M-w" rm-kill-ring-save)
(autoload 'rm-set-mark "rect-mark"
  "Set mark for rectangle." t)
(autoload 'rm-exchange-point-and-mark "rect-mark"
  "Exchange point and mark for rectangle." t)
(autoload 'rm-kill-region "rect-mark"
  "Kill a rectangular region and save it in the kill ring." t)
(autoload 'rm-kill-ring-save "rect-mark"
  "Copy a rectangular region to the kill ring." t)

;;---------------------------------------------------------
;; collapse indented content
;;---------------------------------------------------------
(cmd jao-toggle-selective-display
  (set-selective-display (if selective-display nil 1)))

;;---------------------------------------------------------
;; like C-k but reverse, _cool
;;---------------------------------------------------------
(cmd backwards-kill-line
  (kill-region  (point) (progn (beginning-of-line) (point))))
(bind "C-c u" backwards-kill-line) ; C-u in zsh

;;---------------------------------------------------------
;; C-x p is reverse of C-x o
;;---------------------------------------------------------
(defun other-window-reverse (&optional x)
  (interactive "P")
  (if (equal x nil)
      (other-window -1)
    (other-window (- 0 x)) ))
(bind "C-x p" other-window-reverse)

;;---------------------------------------------------------
;; F3 open dired item with default app in Windows, _cool
;;---------------------------------------------------------
(defun browse-file-windows (file)
  "Run default Windows application associated with FILE.
If no associated application, then `find-file' FILE."
  (let ((windows-file-name (dired-replace-in-string
                           "/" "\\" (dired-get-filename))))
    (or (condition-case nil
            (w32-shell-execute nil windows-file-name)
          (error nil))
        (find-file windows-file-name))))

(defun browse-file-linux (file)
  (dired-do-shell-command "gnome-open" nil (dired-get-marked-files t current-prefix-arg)))

(defun browse-file (file)
  (cond ((equal system-type 'gnu/linux)
         (browse-file-linux file))
        ((equal system-type 'windows-nt)
         (browse-file-windows file))))

(eval-after-load "dired"
  '(define-key dired-mode-map [f3]
     (lambda () (interactive)
       (browse-file (dired-get-filename)))))

;;---------------------------------------------------------
;; indent entire buffer
;;---------------------------------------------------------
(cmd indent-whole-buffer ()
  "indent whole buffer"
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))
(defalias 'iwb 'indent-whole-buffer)

;;---------------------------------------------------------
;; convert file formats
;;---------------------------------------------------------
(cmd convert-unix-to-dos
  (set-buffer-file-coding-system 'undecided-dos))

(cmd convert-dos-to-unix
  (set-buffer-file-coding-system 'undecided-unix))

;;---------------------------------------------------------
;; count words
;;---------------------------------------------------------
(defun count-words (start end)
  "Print number of words in the region."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (count-matches "\\sw+"))))

(defun count-words-analysis (start end)
  "Count how many times each word is used in the region.
    Punctuation is ignored."
  (interactive "r")
  (let (words)
    (save-excursion
      (goto-char start)
      (while (re-search-forward "\\w+" end t)
        (let* ((word (intern (match-string 0)))
               (cell (assq word words)))
          (if cell
              (setcdr cell (1+ (cdr cell)))
            (setq words (cons (cons word 1) words))))))
    (when (interactive-p)
      (message "%S" words))
    words))

(defalias 'word-count 'count-words)
(defalias 'word-count-analysis 'count-words-analysis)

;;---------------------------------------------------------
;; something with long lines
;;---------------------------------------------------------
(defalias 'tt 'toggle-truncate-lines)

;;---------------------------------------------------------
;; install elisp 
;;---------------------------------------------------------
(require 'install-elisp)
(setq install-elisp-repository-directory "~/.elisp/")

;;---------------------------------------------------------
;; recentf (for anything)
;;---------------------------------------------------------
(require 'recentf)
(recentf-mode 1)

;;---------------------------------------------------------
;; magit
;;---------------------------------------------------------
(add-to-list 'load-path "~/src/magit")
(autoload 'magit-status "magit" nil t)
(bind "C-x g" magit-status)

;;---------------------------------------------------------
;; EMMS
;;---------------------------------------------------------
(add-to-list 'load-path "~/.elisp/emms/lisp")
(require 'emms-setup)
(emms-standard)
(emms-default-players)
(add-to-list 'exec-path "C:/Program Files/VideoLAN/VLC")
(setq emms-source-file-default-directory (file-truename "~/opt/music/iTunes/iTunes Music/"))
(require 'emms-lyrics)
(emms-lyrics 1)

(cmd music
  (if (equal "EMMS Playlist"  (buffer-name (current-buffer)))
      (ido-switch-buffer)
    (progn (if (not (get-buffer "EMMS Playlist"))
               (emms-add-directory-tree emms-source-file-default-directory))
           (emms))))

(defalias 'amusic 'emms-add-directory-tree)
(bind "C-c m" music)

;;---------------------------------------------------------
;; Markdown
;;---------------------------------------------------------
(autoload 'markdown-mode "markdown-mode.el"
   "Major mode for editing Markdown files" t)
(setq auto-mode-alist
   (cons '("\\.markdown" . markdown-mode) auto-mode-alist))

;;---------------------------------------------------------
;; TSV
;;---------------------------------------------------------
(autoload 'tsv-mode "tsv-mode" "A mode to edit table like file" t)
(autoload 'tsv-normal-mode "tsv-mode"
"A minor mode to edit table like file" t)

;;---------------------------------------------------------
;; anything
;;---------------------------------------------------------
(require 'anything)
(bind "<f9> a" anything)
(bind "C-c C-a" anything)
(bind "M-X" anything)
(require 'anything-config)

(defun my-get-source-directory (path)
  "Please imlement me. Currently returns `path' inchanged."
  path)

(defvar my-anything-c-source-file-search
  '((name . "File Search")
    (init . (lambda ()
              (setq anything-default-directory
                    default-directory)))
    (candidates . (lambda ()
                    (let ((args
                           (format "'%s' \\( -path \\*/.svn \\) -prune -o -iregex '.*%s.*' -print"
                                   (my-get-source-directory anything-default-directory)
                                   anything-pattern)))
                    (start-process-shell-command "file-search-process" nil
                                   "find" args))))
    (type . file)
    (requires-pattern . 4)
    (delayed))
  "Source for searching matching files recursively.")

;; (require 'anything-complete)
;; ;; Automatically collect symbols by 150 secs
;; (anything-lisp-complete-symbol-set-timer 150)
;; ;; replace completion commands with `anything'
;; (anything-read-string-mode 1)
;; ;; Bind C-o to complete shell history
;; (anything-complete-shell-history-setup-key "\C-o")
;; (add-hook 'anything-after-initialize-hook
;;       '(lambda ()
;;         (define-key anything-read-file-name-map "/" 'anything-read-file-name-follow-directory)))


(require 'anything-etags)
;(setq anything-etags-enable-tag-file-dir-cache t)
;(setq anything-etags-cache-tag-file-dir "~/workspace/")

(setq anything-sources
  (list
    anything-c-source-buffers
    anything-c-source-org-headline
    anything-c-source-recentf
    anything-c-source-emacs-commands
    anything-c-source-emms-dired
    anything-c-source-files-in-current-dir
    anything-c-source-locate
    anything-c-source-etags-select
    anything-c-source-occur
    anything-c-source-man-pages
    anything-c-source-buffer-not-found
    anything-c-source-imenu
;    anything-apropos-sources
    anything-c-source-calculation-result
    anything-c-source-kill-ring
    anything-c-source-fixme
    my-anything-c-source-file-search))

;;---------------------------------------------------------
;; Color theme
;;---------------------------------------------------------
;; (load "~/.emacs-dark")
(add-to-list 'load-path "~/.elisp/color-theme")
(require 'color-theme)
(color-theme-initialize)
;; (setq color-theme-is-cumulative nil)
(setq color-theme-is-cumulative t)
(setq color-theme-is-global t)
(load "color-theme-wombat")
(load "color-theme-colorful-obsolescence")
(load "color-theme-less")
(load "color-theme-cl-frame")
(load "color-theme-active")
(load "color-theme-matrix")
(load "color-theme-paper")
(load "color-theme-google")
(require 'color-theme-sanityinc)
;;(color-theme-sanityinc-light)
;;(color-theme-sanityinc-dark)
;;(color-theme-gnome2)
;;(color-theme-andreas)
;;(color-theme-arjen)
;;(color-theme-dark-blue)
;;(color-theme-feng-shui)
;;(color-theme-resolve)
;;(color-theme-retro-orange)
;;(color-theme-ryerson)
;(load "color-theme-zenburn")
;(color-theme-zenburn)
;(load "~/.emacs-spring")
(require 'gunmetal)
(require 'folio)
;(color-theme-gunmetal)
;(color-theme-folio)
(load "~/.emacs-colors")

;;---------------------------------------------------------
;; yasnippet
;;---------------------------------------------------------
(add-to-list 'load-path "~/.elisp/yasnippet")
(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.elisp/yasnippet/snippets")

;;---------------------------------------------------------
;; auto recompile elisp files
;;---------------------------------------------------------
(setq font-lock-verbose nil
      byte-compile-verbose nil)

(defun pj/auto-recompile-file-always ()
  (when (equal mode-name "Emacs-Lisp")
    (let ((maximum-compile-log-height 8)
          (old-window-start (window-start))
          (old-window-point (window-point)))
      ;; pre-split for compile log buffer so that it does not modify the layout
      (set-window-buffer (split-window-vertically (- (window-height) maximum-compile-log-height)) (get-buffer-create "*Compile-Log*"))
      ;; byte compile the buffer
      (byte-compile-file buffer-file-name)
      (let ((buf (get-buffer "*Compile-Log*")))
        ;; scroll to the end to see if there's an error
        (set-window-point (get-buffer-window buf) (buffer-size buf))
        ;; auto close the compile log window and restore original display position
        (run-at-time 1.0 nil (lambda (buf)
                               (delete-windows-on buf)
                               (set-window-point (selected-window) old-window-point)
                               (set-window-start (selected-window) old-window-start))
                     buf)))))

;(add-hook 'after-save-hook 'pj/auto-recompile-file-always)

;;---------------------------------------------------------
;; Org-mode
;;---------------------------------------------------------
(add-to-list 'load-path "~/.elisp/org-7.3/lisp")
(add-to-list 'load-path "~/.elisp/org-7.3/contrib/lisp")
(add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\)$" . org-mode))
(require 'org-install)
(require 'org-icalendar)
(require 'org-mouse)

;; Standard org stuff
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)

;; Use org in gnus
;; (setq message-mode-hook
;;       (quote (orgstruct++-mode
;;               (lambda nil (setq fill-column 72) (flyspell-mode 1))
;;               turn-on-auto-fill
;;               bbdb-define-all-aliases)))

(load "my-reqall")

;; Settings
(setq org-blank-before-new-entry nil) ; old behavior
; (setq org-return-follows-link t)
; (setq org-ellipsis "...")
(setq org-cycle-separator-lines 1) ; Display blank lines, like outline-blank-lines
(setq org-special-ctrl-a/e t)
(setq org-special-ctrl-k t)
(setq org-tags-column -79) ; tags right aligned
(setq org-agenda-align-tags-to-column 70) ; try to right align tags in agenda
(setq org-hide-leading-stars t) ; only show one *
(setq org-log-done t) ; add CLOSED when complete item
(setq org-startup-folded 'showall) ; Best default for small files with tables
(setq org-highest-priority 49) ; 1
(setq org-lowest-priority 57) ; 9
(setq org-default-priority 53) ; 5
(setq org-agenda-ndays 1) ; default to one day in agenda
(setq org-agenda-start-on-weekday nil)
(setq org-deadline-warning-days 7)
(setq org-agenda-skip-deadline-if-done t)
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-show-all-dates t)
(setq org-reverse-note-order nil) ; new notes first
(setq org-fontify-done-headline t)
(setq org-use-fast-todo-selection 'prefix)

;; Custom keywords
(setq org-todo-keyword-faces
      '(("TODO"  . (:foreground "red" :weight bold))
        ("STARTED" :foreground "blue" :weight bold)
        ("GOAL"  . (:foreground "purple" :weight bold))
        ("WAITING"  . (:foreground "orange" :weight bold))
        ("DELEGATED"  . (:foreground "orange" :weight bold))
        ("SOMEDAY"  . (:foreground "orange" :weight bold))
        ("ONGOING"  . (:foreground "orange" :weight bold))
        ("DONE"  . (:foreground "forest green" :weight bold))
        ("DISMISSED"  . (:foreground "forest green" :weight bold))
        ("CANCELLED"  . (:foreground "forest green" :weight bold))))

(setq org-todo-keywords
         '((sequence "TODO(t)" "|" "DONE(d)" )
           (type "GOAL(g)" "STARTED(s)" "WAITING(w@)" "DELEGATED(e)" "SOMEDAY(S)" "PROJECT(P)" "|")
           (sequence "QUESTION" "|" "ANSWERED")
           (type "|" "CANCELED(c)" "DISMISSED(D)")))

;; Publish my website
(load "org-personal")

;; fix flyspell in org-mode
(autoload 'flyspell-delay-command "flyspell" "Delay on command." t)
(autoload 'tex-mode-flyspell-verify "flyspell" "" t)
(setq flyspell-delayed-commands
      '(org-self-insert-command	org-delete-backward-char
	org-backward-or-forward-delete-char org-delete-char))

;; ;; Nice for adding bold, italics, etc
;; (add-hook 'org-load-hook
;; 	  '(lambda () (define-key org-mode-map "\C-cf" 'org-emphasize)))

;; archive at save (I think)
(setq safe-local-variable-values (quote ((after-save-hook archive-done-tasks))))

;;; Remember mode
(add-to-list 'load-path "~/.elisp/remember/")
(require 'remember)
(org-remember-insinuate)
(define-key global-map [(control meta ?r)] 'org-remember) ; _cool
;(define-key global-map "\C-cr" 'org-remember)
(setq org-default-notes-file "~/remember.org")
(setq org-directory "~/org/")
;; (setq remember-annotation-functions '(org-remember-annotation))
;; (setq remember-handler-functions '(org-remember-handler))
(setq org-remember-store-without-prompt t)

(setq org-remember-templates
      '(("todo" ?t "* TODO %?" "~/org/todo.org" "Tasks")
        ("calendar" ?c "* %?\n  %^t" "~/org/calendar.org" "Events")
        ("phone-calls" ?p "* %T %?" "~/doc/phone-calls.org" "Phone Calls")
        ("journal" ?j "* %U\n%?" "~/doc/personal/journal.org" "Journal")
        ("music" ?m "* :%^{Field|song|artist|album} %^{Value} :%^{Field|song|artist|album} %^{Value}" "~/org/music.org" "Music to checkout")
        ("movie" ?v "* %^{Movie name}" "~/org/movies.org" "Movies to see")
        ("note" ?n "* %U\n  %?" "~/org/notes.org" "Notes")
        ("food" ?f "* %U\n  - %?" "~/org/food.org" "Food")
        ("programming" ?f "* %U\n  - %?" "~/org/programming.org" "Questions")
        ("exercise" ?e "* %U\n  - %?" "~/org/exercise.org" "Exercise")
        ("other" ?o "* %a\n%i")))

(setq remember-all-handler-functions t)
(setq remember-handler-functions
     '(org-remember-handler
     (lambda nil
       (let* ((frame-names-alist (make-frame-names-alist))
              (frame (cdr (assoc "*Remember*" frame-names-alist))))
         (if frame
             (delete-frame frame t))))))

(setq org-agenda-include-diary t)
(setq diary-file "~/tmp/.gcal")
(setq org-agenda-repeating-timestamp-show-all t)
(setq org-agenda-remove-date t)
(setq org-completion-use-ido t)

;; Refile targets include this file and any file contributing to the agenda -
;; up to 5 levels deep
(setq org-refile-targets (quote ((org-agenda-files :maxlevel . 5) (nil :maxlevel . 5))))

; Refile targets start with the file name - allows creating level 1 tasks
(setq org-refile-use-outline-path (quote file))

; Refile targets complete in steps so we start with filename, TAB shows the next level of targets etc
(setq org-outline-path-complete-in-steps t)

;; Change task state to STARTED when clocking in
(setq org-clock-in-switch-to-state "STARTED")

;; ;; No blanks between headings
;; (setq org-blank-before-new-entry '((heading . nil) (plain-list-item . nil)))

(setq org-agenda-custom-commands
      '(("P" "Projects" tags "/!PROJECT" ((org-use-tag-inheritance nil)))
        ("s" "Started Tasks" todo "STARTED" ((org-agenda-todo-ignore-with-date nil)))
        ("Q" "Questions" tags "QUESTION" nil)
        ("w" "Tasks waiting on something" tags "WAITING" ((org-use-tag-inheritance nil)))
        ("r" "Refile New Notes and Tasks" tags "REFILE" ((org-agenda-todo-ignore-with-date nil)))
        ("n" "Notes" tags "NOTES" nil)
;;        ("q" . "Searches")
;;        ("qa" "Archive files" search ""
;;         ((org-agenda-files (file-expand-wildcards "~/org/.*.archive"))))
;;        ("qn" "Notes files" search ""
;;         ((org-agenda-files (file-expand-wildcards "~/org/*.notes"))))
       ("c" "Schedule" agenda ""
        ((org-agenda-ndays 7)
         (org-agenda-start-on-weekday 1)
         (org-agenda-time-grid nil)
         (org-agenda-prefix-format " %12:t ")
         (org-agenda-include-all-todo nil)
         (org-agenda-repeating-timekstamp-show-all t)
         (org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled))))
       ("u" "Upcoming deadlines (6 months)" agenda ""
        ((org-agenda-skip-function '(org-agenda-skip-entry-if 'notdeadline))
         (org-agenda-ndays 1)
         (org-agenda-include-all-todo nil)
         (org-deadline-warning-days 180)
         (org-agenda-time-grid nil)))))

(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t) ("NEXT"))
              ("SOMEDAY" ("WAITING" . t))
              (done ("NEXT") ("WAITING"))
              ("TODO" ("WAITING") ("CANCELLED"))
              ("STARTED" ("WAITING"))
              ("PROJECT" ("CANCELLED") ("PROJECT" . t)))))


;; Resume clocking tasks when emacs is restarted
(setq org-clock-persistence-insinuate)
;; Yes it's long... but more is better ;)
(setq org-clock-history-length 35)
;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)
;; Change task state to STARTED when clocking in
(setq org-clock-in-switch-to-state "STARTED")
;; Save clock data and notes in the LOGBOOK drawer
(setq org-clock-into-drawer t)
;; Sometimes I change tasks I'm clocking quickly - this removes
;; clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)
;; Don't clock out when moving task to a done state
(setq org-clock-out-when-done nil)
;; Save the running clock and all clock history when exiting Emacs,
;; load it on startup
(setq org-clock-persist t)

; Erase all reminders and rebuilt reminders for today from the agenda
(cmd my-org-agenda-to-appt
  (setq appt-time-msg-list nil)
  (org-agenda-to-appt))

; Rebuild the reminders everytime the agenda is displayed
(add-hook 'org-finalize-agenda-hook 'my-org-agenda-to-appt)

; This is at the end of my .emacs - so appointments are set up when Emacs starts
(my-org-agenda-to-appt)

; Activate appointments so we get notifications
(appt-activate t)

; If we leave Emacs running overnight - reset the appointments one
; minute after midnight
(run-at-time "24:01" nil 'my-org-agenda-to-appt)

(cmd my-org-todo
  (org-narrow-to-subtree)
  (org-show-todo-tree nil)
  (widen))

;; Keep tasks with dates off the global todo lists
(setq org-agenda-todo-ignore-with-date t)

;; Remove completed deadline tasks from the agenda view
(setq org-agenda-skip-deadline-if-done t)

;; Include agenda archive files when searching for things
(setq org-agenda-text-search-extra-files (quote (agenda-archives)))

;; Show all future entries for repeating tasks
(setq org-agenda-repeating-timestamp-show-all t)

;; Show all agenda dates - even if they are empty
(setq org-agenda-show-all-dates t)

;; Sorting order for tasks on the agenda
(setq org-agenda-sorting-strategy
      (quote ((agenda time-up priority-down effort-up category-up)
              (todo priority-down)
              (tags priority-down))))

;; Start the weekly agenda today
(setq org-agenda-start-on-weekday nil)

;; ;; Disable display of the time grid
;; (setq org-agenda-time-grid
;;       (quote (nil "----------------"
;;                   (800 1000 1200 1400 1600 1800 2000))))

(load "~/.elisp/org-mode/contrib/lisp/org-checklist")

;; enable task blocking
(setq org-enforce-todo-dependencies t)

;; C-S-RET for inserting new heading after content of current item
(setq org-insert-heading-respect-content t)

; Set default column view headings: Task Effort Clock_Summary
(setq org-columns-default-format
      "%80ITEM(Task) %10Effort(Effort){:} %10CLOCKSUM")

; global Effort estimate values
(setq org-global-properties
      (quote (("Effort_ALL" .
               "0:10 0:30 1:00 2:00 3:00 4:00 5:00 6:00 8:00"))))

; save all org buffers one minute before the hour
(run-at-time "00:59" 3600 'org-save-all-org-buffers)
;; (run-at-time "00:59" 3600 'org-feed-update-all)
(setq org-empty-line-terminates-plain-lists t)
  
(add-to-list 'load-path "~/.elisp/atom-syndication/")
(require 'atom-syndication)
(require 'org-atom)

(setq user-full-name "Scott Jaderholm"
      org-export-author-info nil
      org-export-email-info nil
      org-export-creator-info nil)

;;---------------------------------------------------------
;; headings
;;---------------------------------------------------------
(cmd my-insert-heading
  (if (or (equal major-mode 'emacs-lisp-mode) (equal major-mode 'clojure-mode))
      (insert ";;---------------------------------------------------------
;; 
;;---------------------------------------------------------"))
  (if (equal major-mode 'python-mode)
      (insert "#----------------------------------------------------------
#
#----------------------------------------------------------"))
  (if (or (equal major-mode 'css-mode) (equal major-mode 'javascript-mode))
      (insert "/* ------------------------------

   ------------------------------ */")))
(bind "C-c h" my-insert-heading)

;;-----------------------------------------------------------------------------
;; F2: files
;;-----------------------------------------------------------------------------
(defmacro set-key-find-file (key file)
  "Defines a shortcut key to open a file."
  (let ((fname (intern (concat "open-" file))))
    `(progn (defun ,fname () (interactive) (find-file ,file))
            (global-set-key (kbd ,key) ',fname))))

(set-key-find-file "<f2> e" "~/.emacs")
(set-key-find-file "<f2> g" "~/.gnus.el")
(set-key-find-file "<f2> t" "~/org/todo.org")
(set-key-find-file "<f2> n" "~/org/notes.org")
(set-key-find-file "<f2> f" "~/org/feeds.org")
(set-key-find-file "<f2> z" "~/.zshrc")
(set-key-find-file "<f2> b" "~/.xbindkeysrc")
(set-key-find-file "<f2> r" "~/.Xresources")
(set-key-find-file "<f2> m" "~/.Xmodmap")

;;-----------------------------------------------------------------------------
;; F5: Org functions
;;-----------------------------------------------------------------------------
(bind "<f5> a" org-toggle-archive-tag)
(bind "<f5> b" org-ido-switchb)
(bind "<f5> i" org-clock-in)
(bind "<f5> o" org-clock-out)
(bind "<f5> r" org-refile)
(bind "<f5> f" org-occur)
;(bind "<f5> r" org-remember)
(bind "<f5> v" org-archive-subtree)
(bind "<f5> t" my-org-todo)
(bind "<f5> w" widen)
(bind "<f5> u" org-feed-update-all)
;;-----------------------------------------------------------------------------
;; F6: Emacs functions
;;-----------------------------------------------------------------------------
(bind "<f6> t" 'visit-tags-table)
(bind "<f6> h" 'jao-toggle-selective-display)
(bind "<f6> h" 'hs-org/minor-mode)
(bind "<f6> d" 'color-theme-wombat)
(bind "<f6> l" 'color-theme-active)
(bind "<f6> n" 'linum-mode)


;;-----------------------------------------------------------------------------
;; F7:
;;-----------------------------------------------------------------------------
(setq font-counter 0)
(setq fonts '("Envy Code R-10"
              ;; "Envy Code R-9"
              ;; "Terminus-9"
              "MonteCarlo-10"
              ;; "ProFont-9"
              ;; "Smooth-10"
              "GohuFont-9"
              "GohuFont-12"
              ;; "Terminus-10"
              "DejaVu Sans Mono-8"
              "DejaVu Sans Mono-9"
              "DejaVu Sans Mono-10"
              ;; "DejaVu Sans Mono-28"
              ;; "DejaVu Sans Mono-10"
              ;; "DejaVu Sans Mono-12"
              ;; "DejaVu Sans Mono-14"
              ;; "Envy Code R-12"
              ;; "Envy Code R-14"
              ;; "Courier 10 Pitch-13" ; 1 and l look the same
              ;; "Inconsolata-16:medium"
              ;; "Inconsolata-24:medium"
              ;; "Liberation Mono-12"
              ;; "Liberation Mono-14"
              ;; "Monaco-12"
              ;; "Monaco-18"
              )
      font-length (length fonts))

(defun cycle-fonts (&optional direction)
  (interactive)
  (if (= -1 direction)
      ;; backward
      (progn
        (if (zerop font-counter)
            (setq font-counter (1- font-length))
          (decf font-counter)))
    ;; forward
    (if (= font-counter (1- font-length))
        (setq font-counter 0)
      (incf font-counter)))
  (let ((next-font (nth font-counter fonts)))
    (set-default-font next-font)
    (message (concat "Changed font to `" next-font "`"))))

(bind "<f7>" (lambda () (interactive) (cycle-fonts 1)))
(bind "S-<f7>" (lambda () (interactive) (cycle-fonts -1)))

;;-----------------------------------------------------------------------------
;; F8:
;;-----------------------------------------------------------------------------
(bind "<f8>" slime-selector)

;;-----------------------------------------------------------------------------
;; F9: Emacs programs
;;-----------------------------------------------------------------------------
(bind "<f9> e" eshell)
(bind "<f9> f" rgrep)
(bind "<f9> h" (lambda () (interactive) (dired "~")))
(bind "<f9> c" calendar)
(bind "<f9> r" org-remember)
(bind "<f9> g" gnus)
(bind "<f9> M-g" gnus-unplugged)


;;-----------------------------------------------------------------------------
;; F11:
;;-----------------------------------------------------------------------------

(bind "<M-f11>" recentf-open-files)

;;-----------------------------------------------------------------------------
;; F12: Agenda
;;-----------------------------------------------------------------------------
(bind "<f12>" org-agenda)
(bind "C-<f12>" org-clock-goto)

;;---------------------------------------------------------
;; Random bindings
;;---------------------------------------------------------
(bind "C-x C-b" ibuffer)
(bind "C-x C-p" proced)
;; (bind "C-h" backward-delete-char-untabify)
;; (bind "M-h" backward-kill-word)
(bind "\C-cc" comment-region)
(bind "\C-cn" uncomment-region)
(bind "C-x M-f" find-file-other-window)
(bind "M-/" hippie-expand)

;; Useful function for inserting date quickly
;; (bind "C-c D" (lambda () (interactive)
;;                           (insert (format-time-string "%a, %b %e, %Y"))))
(bind "C-c D" (lambda () (interactive)
                (insert (format-time-string "%Y-%m-%d"))))
;; (bind "C-c t" (lambda () (interactive)
;;                           (insert (format-time-string "%H:%M"))))
;; (bind "C-c T" (lambda () (interactive)
;;                           (insert (format-time-string "%H:%M:%S"))))

(cmd print-buffer2
  (hfyview-buffer))

(cmd print-region2 
  (hfyview-region))

;; (autoload 'egg-status "egg" nil t)
;; (bind "C-x g" egg-status)
;; (add-to-list 'load-path "~/src/egg")
;; (require 'egg)

(cmd insert-local-variables-spec
  "Insert a minimal local variables spec for this buffer."
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      ;; FIXME: only strip the last 5 characters when they're "-mode"
      (insert (format "-*- mode: %s; coding: %s -*-"
                      (substring (symbol-name major-mode) 0 -5)
                      buffer-file-coding-system))
      ;; If there's some kind of local comment syntax, ensure the local
      ;; variables spec lives in one.
      (when comment-start
        (comment-region (point-min) (point)))
      (insert "\n"))))

(load "speedread.el")

;; e no longer does RET, instead does C-c C-x or whatever
(add-hook 'dired-mode-hook
          '(lambda ()
             (define-key dired-mode-map "e" 'wdired-change-to-wdired-mode)
             (define-key dired-mode-map "/" 'dired-isearch-filenames)))

(defun make-backup-file-name (FILE)
  (let ((dirname (concat "~/.backups/emacs/"
                         (format-time-string "%y/%m/%d/"))))
    (if (not (file-exists-p dirname))
        (make-directory dirname t))
    (concat dirname (file-name-nondirectory FILE))))

(defun org-gcal-sync ()
  "Export org to ics to be uploaded to Google Calendar and import
an .ics file that has been downloaded from Google Calendar "
  (org-export-icalendar-combine-agenda-files)
  (icalendar-import-file "~/tmp/.basic.ics" "~/tmp/.gcal"))

;; Proper CSS indentation
(setq cssm-indent-function 'cssm-c-style-indenter)

(cmd reinit
  "Reload .emacs"
  (load-file "~/.emacs"))

;; (cmd my-done
;;   (server-edit)
;;   (make-frame-invisible nil t))
;; (bind "C-x C-c" my-done)

(defun dec-to-hex (dec)
  (format "%02X" dec))

(defun rgb-to-hex (r g b)
  (concat "#" (mapconcat #'dec-to-hex (list r g b) "")))

(require 'jot)

(autoload 'inferior-moz-mode "moz" "MozRepl Inferior Mode" t)
(autoload 'moz-minor-mode "moz" "MozRepl Minor Mode" t)
(cmd javascript-moz-setup (moz-minor-mode 1))
(add-hook 'javascript-mode-hook 'javascript-moz-setup)
(add-hook 'espresso-mode-hook 'javascript-moz-setup)
(add-hook 'js2-mode-hook 'javascript-moz-setup)
;; so run-mozilla is available w/o opening .js file
(javascript-moz-setup)


;; (add-to-list 'load-path "~/.elisp/drew")
;; (require 'emacs-init)

(add-to-list 'load-path "~/.elisp/haskell-mode-2.4/")

(require 'haskell-mode)
(load "~/.elisp/haskell-mode-2.4/haskell-site-file")
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)

(add-to-list 'auto-mode-alist '("\\.js\\'" . espresso-mode))
(autoload 'espresso-mode "espresso" nil t)

;(setq sql-mysql-options (list "-P 3306" "-C" "-t" "-f" "-n"))

(put 'set-goal-column 'disabled nil)

(defun combine-lines (&optional arg)
  (interactive "P")
  (let ((rexp "\\(?:\\s-\\|\n\\)"))
    (progn
      (while (looking-back rexp)
        (delete-backward-char 1))
      (while (looking-at rexp)
        (delete-char 1))
      (unless arg
        (insert " ")))))

;; (add-to-list 'load-path "~/.elisp/edb-1.31/lisp")
;; (add-to-list 'load-path "~/.elisp/elip-0.803/source")
;; (require 'elip)

(eval-after-load "sql"
  (progn (load-library "sql-indent")
         (load-library "sql-transform")))

;; Allows scrolling sql output buffer with C-c C-p and C-c C-n from
;; sql code buffer
(autoload 'master-mode "master" "Master mode minor mode." t)
(add-hook 'sql-mode-hook
          (function (lambda ()          ; function is like quote but byte compiles arg
                      (master-mode t)
                      (master-set-slave sql-buffer))))
(add-hook 'sql-set-sqli-hook '(lambda () (master-set-slave sql-buffer)))

;; Remember about M-x scroll-all-mode when

(require 'sql-completion)
(setq sql-interactive-mode-hook
      (lambda ()
        (define-key sql-interactive-mode-map "\t" 'comint-dynamic-complete)
        (sql-mysql-completion-init)))

(require 'desktop)
(add-to-list 'desktop-globals-to-save 'sql-mysql-schema)

(cmd my-sql-mysql
   "Switch to buffer before popping."
   (if (and (boundp 'sql-buffer)
	    (buffer-live-p sql-buffer))
       (switch-to-buffer sql-buffer)
     (sql-mysql)))

(bind "C-c s" my-sql-mysql)

;; In order to search and replace text before sending it over to the SQLi buffer

(require 'sql)

(define-key sql-mode-map (kbd "C-c C-b") 'my-sql-replace-and-send)

(defcustom my-sql-replacements
  '(("#USER#" . "'"))
  "Strings to replace."
  :type '(repeat (cons (string :tag "search") (string :tag "replace"))))

(cmd my-sql-replace-and-send
  (let* ((start (save-excursion
                  (backward-paragraph)
                  (point)))
         (end (save-excursion
                (forward-paragraph)
                (point)))
         (statement (buffer-substring start end))
         (things my-sql-replacements)
         (buf sql-buffer))
    (with-temp-buffer
      (insert statement)
      (dolist (thing things)
        (goto-char (point-min))
        (while (search-forward (car thing) nil t)
          (replace-match (cdr thing))))
      (let ((sql-buffer buf))
        (sql-send-buffer))))) 

;(defalias 'sql-get-login 'ignore)

;; mobile org
(setq org-mobile-directory "\\\\www.box.net@SSL\\DavWWWRoot\\dav\\org")
(setq org-mobile-force-id-on-agenda-items nil)

(require 'thingatpt)
(require 'thing-edit)

;; (require 'mumamo)

;; (require 'multi-mode)

(bind "C-c r" query-replace-regexp)

;; (require 're-builder+)

(defun save-macro (name)                  
  "save a macro. Take a name as argument
     and save the last defined macro under 
     this name at the end of your .emacs"
  (interactive "SName of the macro :")  ; ask for the name of the macro    
  (kmacro-name-last-macro name)         ; use this name for the macro    
  (find-file "~/.emacs")                ; open the .emacs file 
  (goto-char (point-max))               ; go to the end of the .emacs
  (newline)                             ; insert a newline
  (insert-kbd-macro name)               ; copy the macro 
  (newline)                             ; insert a newline
  (switch-to-buffer nil))               ; return to the initial buffer

(fset 'sql-macro-same-name
   (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ([67108896 5 21 134217848 114 101 112 108 97 99 101 45 114 101 103 101 120 112 return 92 40 91 65 45 122 93 43 92 41 92 40 91 94 65 45 122 93 43 92 41 32 97 115 32 92 40 91 65 45 122 93 43 92 41 return 92 51 92 97 backspace 50 32 97 115 32 92 51 return 14 1] 0 "%d")) arg)))

;; Example regexps
;; Increment the numbers in brackets like [1] starting from 12
;; Regexp \[[0-9]+\]
;; Replace [\,(+ 12 \#)]

;; Change the sum(ifnull(.*,0)) to ifnull(sum(.*),0)

;; Change sum(a) as b to sum(b) as b

;; Cut (C-w) or copy (M-w) current line if nothing is selected
(defun next-list-boundaries ()
  (list (progn (paredit-forward) (point))
        (progn (paredit-backward) (point))))

(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive (cond (mark-active
                      (list (region-beginning) (region-end)))
                     ((bolp)
                      (progn (message "Copied line")
                             (list (line-beginning-position) (line-beginning-position 2))))
                     (t
                      (progn (message "Copied form")
                             (next-list-boundaries))))))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (cond (mark-active (list (region-beginning) (region-end)))
         ((bolp)
          (progn (message "Cut line")
                 (list (line-beginning-position)
                       (line-beginning-position 2))))
         (t
          (progn (message "Cut form")
                 (next-list-boundaries))))))

;; I like better than M-| uniq
(defun uniq-lines (beg end)
  "Unique lines in region. Called from a program, there are two
arguments: BEG and END (region to sort)."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (while (not (eobp))
        (kill-line 1)
        (yank)
        (let ((next-line (point)))
          (while (re-search-forward
                  (format "^%s" (regexp-quote (car kill-ring))) nil t)
            (replace-match "" nil nil))
          (goto-char next-line))))))

;;; keywords hinge gutter wrap
;; prevent huge fringes w small font
(set-fringe-mode '(5 . 0))
;; these look unnecessary
;; (set-window-fringes nil 5 0)
(set-fringe-style '(5 . 0))

;; (load-file "~/.elisp/typing-speed.el")
;; (turn-on-typing-speed)

; find . \( -name "*.java" -o -name "*.clj" -o -name "*.py" \) -print0|xargs -0 etags --append

(cmd transparent (set-frame-parameter (selected-frame) 'alpha '(90 90)))
(cmd opaque (set-frame-parameter (selected-frame) 'alpha '(100 100)))

;;; diff color cursors for write/read modes
;(load-file "~/.elisp/cursor.el")

(require 'loccur)
;; defines shortcut for loccur of the current word
(define-key global-map (kbd "C-c C-o") 'loccur-current)
;; defines shortcut for the interactive loccur command
(define-key global-map (kbd "C-M-o") 'loccur)
;; defines shortcut for the loccur of the previously found word
(define-key global-map (kbd "C-S-o") 'loccur-previous-match)

(require 'anything-grep)

(autoload 'ack-same "full-ack" nil t)
(autoload 'ack "full-ack" nil t)
(autoload 'ack-find-same-file "full-ack" nil t)
(autoload 'ack-find-file "full-ack" nil t)
(setq ack-executable (executable-find "ack-grep"))
;; TODO write a function that cleans up current sexp
;; if I have (setq ack-executable | (executable-find "ack-grep" ))
;; and cursor is at | then the keystroke will remove extra whitespace at cursor and after grep"

(load "my-bookmarks")
;(load "my-ido")
(load "my-desktop")

;; auto fill comments but not code
(dolist (i '(emacs-lisp-mode-hook lisp-mode-hook clojure-mode-hook))
  (add-hook 'i '(lambda ()
                 (auto-fill-mode 1)
                 (set (make-local-variable 'fill-nobreak-predicate)
                      (lambda ()
                        (not (eq (get-text-property (point) 'face)
                                 'font-lock-comment-face)))))))

;;---------------------------------------------------------
;; Highlight symbol
;;---------------------------------------------------------

(require 'highlight-symbol)
;; (highlight-symbol-mode 1)
;; (add-hook 'clojure-mode-hook 'highlight-symbol-mode)

(cmd sync
     "Easier OrgMobile syncing"
     (org-mobile-pull)
     (org-mobile-push))

;;---------------------------------------------------------
;; Clojure-mode and Slime
;;---------------------------------------------------------
(add-to-list 'load-path "~/.elisp/clojure-mode")
(add-to-list 'load-path "~/.elisp/swank-clojure")

(require 'clojure-mode)

(add-to-list 'load-path "~/src/slime")
(add-to-list 'load-path "~/src/slime/contrib")
(require 'slime)
(slime-setup '(slime-fancy))

(def-slime-selector-method ?j
  "most recently visited clojure-mode buffer."
  (slime-recently-visited-buffer 'clojure-mode))

(defmacro slime-local-connect (name port)
  `(defun ,name ()
     (interactive)
     (slime-connect "127.0.0.1" ,port)))

(slime-local-connect sl5 4005)
(slime-local-connect sl6 4006)
(slime-local-connect sl7 4007)
(slime-local-connect sl8 4008)
(slime-local-connect sl9 4009)

;; Clojure stack trace change
(defface esk-clojure-trace-face
   '((((class color) (background dark))
      (:foreground "grey50"))
     (((class color) (background light))
      (:foreground "grey55")))
   "Face used to dim parentheses."
   :group 'starter-kit-faces)

(setq esk-clojure-trace-face 'esk-clojure-trace-face)

;; This will make relevant lines stand out more in stack traces
(defun sldb-font-lock ()
  (font-lock-add-keywords nil
                          '(("[0-9]+: \\(clojure\.\\(core\\|lang\\).*\\)"
                             1 esk-clojure-trace-face)
                            ("[0-9]+: \\(java.*\\)"
                             1 esk-clojure-trace-face)
                            ("[0-9]+: \\(swank.*\\)"
                             1 esk-clojure-trace-face)
                            ("\\[\\([A-Z]+\\)\\]"
                             1 font-lock-function-name-face))))

(add-hook 'sldb-mode-hook 'sldb-font-lock)

;; (autoload 'clojure-test-mode "clojure-test-mode" "Clojure test mode" t)
(add-hook 'clojure-mode-hook
          '(lambda ()
             ;; (save-excursion
             ;; (goto-char (point-min))
             ;; (if (or (search-forward "(deftest" nil t)
             ;;         (search-forward "(with-test" nil t))
             ;; (clojure-test-mode t)

             ;; (require 'clj-imports)
             ;; (define-key clojure-mode-map (kbd "C-c i")
             ;;   'clj-imports-insert-with-completion)
             ;; (define-key clojure-mode-map (kbd "C-c C-n")
             ;;   'clj-imports-eval-ns)

             
))

(defun backward-up-list+ ()
  "Stupid backward-up-list doesn't work from inside a string and I got tired of having to move outside the string to use it."
  (interactive)
  (if (in-string-p)
      (while (in-string-p)
        (backward-char))
    (backward-up-list)))

(bind "C-M-u" backward-up-list+)

(defun up-list+ ()
  (interactive)
  (if (in-string-p)
      (while (in-string-p)
        (forward-char))
    (up-list)))

(defun move-to-parent ()
  )
(defun eval-parent-sexp ()
  "Cause sometimes you just want to eval just the immediate form. not the top level, but without going to the closing paren and evaling there."
  (interactive)
  (save-excursion
    ;; get out of string if in it
    (dotimes (c (if (in-string-p) 2 1))
      (up-list+))
    (let ((cmd (key-binding (kbd "C-x C-e"))))
      (if (eq cmd 'slime-eval-last-expression)
          (funcall cmd)
        (funcall cmd '())))))

(global-set-key (kbd "C-M-S-x") 'eval-parent-sexp)

(setq slime-protocol-version nil)

;; (require 'clojure-test-mode)

;;---------------------------------------------------------
;; Paredit
;;---------------------------------------------------------
(require 'paredit)
(dolist (i '(emacs-lisp-mode-hook lisp-mode-hook lisp-interaction-mode-hook clojure-mode-hook slime-repl-mode-hook))
  (add-hook i (lambda () (paredit-mode +1)
                (local-set-key  "(" 'paredit-open-parenthesis)
                (local-set-key  ")" 'paredit-close-parenthesis)
                (local-set-key "[" 'paredit-open-parenthesis)
                (local-set-key "]" 'paredit-close-parenthesis)
                (local-set-key "{" 'paredit-open-curly)
                (local-set-key "}" 'paredit-close-curly))))

;;; cool! insert something above parent sexp
(define-key paredit-mode-map (kbd "C-S-j")
  (lambda ()
    (interactive)
    (backward-up-list+)
    (paredit-newline)
    (previous-line)
    (indent-according-to-mode)))

;;; use matching pairs everywhere
;;---------------------------------------------------------
;; clojure refactoring
;;---------------------------------------------------------
(add-to-list 'load-path "~/src/clojure-refactoring/")
(require 'clojure-refactoring-mode)
(global-set-key (kbd "C-c e") 'clojure-refactoring-ido)

(global-set-key (kbd "<f8>")
                (lambda () (interactive)
                  (if (eq major-mode 'clojure-mode)
                      (switch-to-buffer "*slime-repl clojure*")
                    (switch-to-buffer (slime-recently-visited-buffer 'clojure-mode)))))

(global-set-key (kbd "<S-f8>")
                (lambda () (interactive)
                  (switch-to-buffer "*inferior-lisp*")))

;;---------------------------------------------------------
;; Tramp
;;---------------------------------------------------------
;; (eval-after-load "tramp"
;;   '(progn
;;      (add-to-list 'tramp-default-proxies-alist
;;                   '(nil "\\`root\\'" "/ssh:%h:"))
;;      ;; (add-to-list 'tramp-default-proxies-alist
;;      ;;                   '((regexp-quote (system-name)) nil nil))
;;      ))

(load "dired-x") ;; C-x C-j jump to current file in dired

(cmd xsteve-ido-choose-from-recentf
  "Use ido to select a recently opened file from the `recentf-list'"
  (let ((home (expand-file-name (getenv "HOME"))))
    (find-file
     (ido-completing-read "Recentf open: "
                          (mapcar (lambda (path)
                                    (replace-regexp-in-string home "~" path))
                                  recentf-list)
                          nil t))))

(bind "C-x f" xsteve-ido-choose-from-recentf)

(setq ibuffer-shrink-to-minimum-size t)
(setq ibuffer-always-show-last-buffer nil)
(setq ibuffer-sorting-mode 'recency)
(setq ibuffer-use-header-line t)

(require 'iflipb)
;(load "frazer-buffer")
(setq iflipb-ignore-buffers '("*Messages*" "*Help*" "*Completions*" "TAGS"))
(setq iflipb-always-ignore-buffers '("^ "))

(setq iflipb-boring-buffer-filter 'my-bs-ignore-buffer)

(bind "<C-tab>" iflipb-next-buffer)
(bind "<C-S-iso-lefttab>"  iflipb-previous-buffer)
(define-key org-mode-map (kbd "<C-tab>") nil) ; unbind it in orgmode
(bind "<f1>" iflipb-next-buffer)
(bind "<S-f1>"  iflipb-previous-buffer)


;; (bind "C-x C-b" bs-show)

(cmd xsteve-save-current-directory
  "Save the current directory to the file ~/.emacs.d/current-directory"
  (let ((dir default-directory))
    (with-current-buffer (find-file-noselect "~/.emacs.d/current-directory")
      (delete-region (point-min) (point-max))
;      (insert (concat dir "\n"))
      (insert dir)
      (save-buffer)
      (kill-buffer (current-buffer)))))
(bind "<S-f10>" xsteve-save-current-directory)

(defun djcb-duplicate-line (&optional commentfirst)
  "comment line at point; if COMMENTFIRST is non-nil, comment the original"
  (interactive)
  (beginning-of-line)
  (push-mark)
  (end-of-line)
  (let ((str (buffer-substring (region-beginning) (region-end))))
    (when commentfirst
    (comment-region (region-beginning) (region-end)))
    (insert-string
      (concat (if (= 0 (forward-line 1)) "" "\n") str "\n"))
    (forward-line -1)))

;; or choose some better bindings....

;; duplicate a line
(bind "C-c y" djcb-duplicate-line)

;; duplicate a line and comment the first
(bind "C-c M-y" (lambda () (interactive) (djcb-duplicate-line t)))

(setq whitespace-style '(trailing lines space-before-tab indentation
                                  space-after-tab) whitespace-line-column 80)
;(global-whitespace-mode 1)

(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward)

;; source: http://steve.yegge.googlepages.com/my-dot-emacs-file
(defun rename1 (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive (list (completing-read "New name: " nil nil nil (buffer-name))))
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))

(defun move1 (dir)
  "Moves both current buffer and file it's visiting to DIR."
  (interactive "DNew directory: ")
  (let* ((name (buffer-name))
	 (filename (buffer-file-name))
	 (dir
          (if (string-match dir "\\(?:/\\|\\\\)$")
              (substring dir 0 -1) dir))
	 (newname (concat dir "/" name)))

    (if (not filename)
	(message "Buffer '%s' is not visiting a file!" name)
      (progn (copy-file filename newname 1)
             (delete-file filename)
             (set-visited-file-name newname)
             (set-buffer-modified-p nil)
             t))))
(bind "<f3>" browse-url-at-point)

;; (require 'viewer)
;; (viewer-stay-in-setup)
;; (setq viewer-modeline-color-unwritable "tomato"
;;       viewer-modeline-color-view "orange")
;; (viewer-change-modeline-color-setup)
;; (viewer-aggressive-setup 'force)
;; (bind "<f4>" view-mode)

;;; stop slime from complaining about mismatching versions
(setq slime-protocol-version "20100404")
(bind "<M-wheel-up>" text-scale-increase)
(bind "<M-wheel-down>" text-scale-decrease)

(load "indent-yank")
;(scroll-bar-mode -1)

; (setq-default mode-line-format nil)

;;; ( and ) for hiding details
;(require 'dired-details+)

(cmd hide-dot-files
  (dired-mark-files-regexp "^\\.")
  (dired-do-kill-lines))

(define-key dired-mode-map [?%?h] 'hide-dot-files)

(display-time-mode)
(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;;; auto-complete lags my emacs every once in a while

;(add-to-list 'load-path "~/.elisp/auto-complete-1.3")
(add-to-list 'load-path "~/.elisp/auto-complete")
(require 'auto-complete)
(global-auto-complete-mode t)
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.elisp/auto-complete/dict")
(ac-config-default)

(cmd my-transpose-sexps
  (transpose-sexps 1)
  (backward-sexp 2))

(define-key lisp-mode-shared-map (kbd "C-M-T") 'my-transpose-sexps)

(if running-windows
    (setq path-to-ctags "C:/cygwin/bin/ctags"))

(defun create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (shell-command
   (format "%s -f %s/TAGS -e -R %s" path-to-ctags dir-name dir-name)))

(require 'etags-select)
(bind "\M-?" etags-select-find-tag-at-point)
(bind "\M-." etags-select-find-tag)

(require 'etags-update)

;; (add-to-list 'load-path "~/.elisp/drag-stuff/")
;; (require 'drag-stuff)
;; (drag-stuff-global-mode t)

;; (add-to-list 'load-path "~/.elisp/wrap-region/")
;; (require 'wrap-region)
;; (wrap-region-global-mode t)

(add-hook 'server-switch-hook
          (lambda ()
            (when (current-local-map)
              (use-local-map (copy-keymap (current-local-map))))
            (when server-buffer-clients
              (local-set-key (kbd "C-x k") 'server-edit)
              (local-set-key (kbd "<f4>") 'server-edit)
              (local-set-key (kbd "M-k") 'server-edit))))

(defun my-kill-buffer ()
  (interactive) (kill-buffer (current-buffer)))

(global-set-key (kbd "<f4>") 'my-kill-buffer)
(global-set-key (kbd "M-k") 'my-kill-buffer)

;(global-hl-line-mode)
(require 'centered-cursor-mode)
(require 'hl-spotlight)
;(setq highline-vertical '(2 . 2))
;(setq line-move-visual nil)

(when (require 'auto-mark nil t)
  (setq auto-mark-command-class-alist
        '((anything . anything)
          (goto-line . jump)
          (indent-for-tab-command . ignore)
          (undo . ignore)))
  (setq auto-mark-command-classifiers
        (list (lambda (command)
                (if (and (eq command 'self-insert-command)
                         (eq last-command-char ? ))
                    'ignore))))
  (global-auto-mark-mode 1))

(require 'visible-mark)
(global-visible-mark-mode t)
;; (add-to-list 'exec-path "C:/local/git/bin") 

;; (add-to-list 'load-path "~/.elisp/hideshow-org/")
;; (require 'hideshow-org)

(cmd comment-or-uncomment-current-line-or-region
  "Comments or uncomments current current line or whole lines in region."
  (save-excursion
    (let (min max)
      (if (and transient-mark-mode mark-active)
          (setq min (region-beginning) max (region-end))
        (setq min (point) max (point)))
      (comment-or-uncomment-region
       (progn (goto-char min) (line-beginning-position))
       (progn (goto-char max) (line-end-position))))))

(require 'comment-uncomment-line-or-region)
(bind "C-c c" comment-uncomment-line-or-region)

(when (require 'browse-kill-ring nil 'noerror)
  (browse-kill-ring-default-keybindings))

(add-hook 'gnus-article-mode-hook 'longlines-mode)
;(refill-mode)

(load "~/.elisp/my-indent.el")

(add-to-list 'load-path "~/.elisp/session/lisp/")
(require 'session)
(add-hook 'after-init-hook 'session-initialize)
      
;;; TODO change so that moves by continuous region instead of character
;; (require 'point-undo)
;; (define-key global-map [left] 'point-undo)
;; (define-key global-map [right] 'point-redo)

;;; cool: C-u C-_ when a section is selected does selective undo on that region

(require 'undo-tree)

;;; yellow color
;;; http://www.adaic.com/standards/95lrm/html/RM-12-8.html
;;; bgcolor #fffff0
;;; font Courier New
;(require 'ido-hacks)

;; (require 'smex)
;; (smex-initialize)
;; (bind "M-x" smex)
;; (bind "M-X" smex-major-mode-commands)
;; (bind "C-c C-c M-x" execute-extended-command)

(cmd scroll-down-keep-cursor
  "Scroll the text one line down while keeping the cursor"
  (scroll-down 1))

(cmd scroll-up-keep-cursor
  "Scroll the text one line up while keeping the cursor"
  (scroll-up 1))

(bind "C-S-p" scroll-down-keep-cursor)
(bind "C-S-n" scroll-up-keep-cursor)

(defun yank-with-newline ()
  "Yank, appending a newline if the yanked text doesn't end with one."
  (yank)
  (when (not (string-match "\n$" (current-kill 0)))
    (newline-and-indent)))

(cmd yank-as-line-above
  "Yank text as a new line above the current line.

Also moves point to the beginning of the text you just yanked."
  (let ((lnum (line-number-at-pos (point))))
    (beginning-of-line)
    (yank-with-newline)
    (goto-line lnum)))

(cmd yank-as-line-below
  "Yank text as a new line below the current line.
Also moves point to the beginning of the text you just yanked."
  (let* ((lnum (line-number-at-pos (point)))
         (lnum (if (eobp) lnum (1+ lnum))))
    (if (and (eobp) (not (bolp)))
        (newline-and-indent)
      (forward-line 1))
    (yank-with-newline)
    (goto-line lnum)))

(bind "\M-P" yank-as-line-above)
(bind "\M-p" yank-as-line-below)

;; (defun my-open-line (&optional alt)
;;   (interactive "p")
;;   (cond ((= alt 1)  (progn (unless (bolp)
;;                              (beginning-of-line))
;;                            (newline)
;;                            (forward-line -1)
;;                            (indent-according-to-mode)))
;;         ((= alt 2) (progn (unless (eolp)
;;                             (end-of-line))
;;                           (newline-and-indent)))
;;         (t (open-line 1))))

;; (define-key global-map (kbd "C-o") 'my-open-line)

;;; Not sure this is useful
(require 'org-velocity)
(setq org-velocity-bucket (concat org-directory "/bucket.org"))
(bind "C-c v" org-velocity-read)

(bind "C-h u" man)

(cmd isearch-other-window
     ;; thank you leo2007!
     (save-selected-window
       (other-window 1)
       (isearch-forward)))

(bind "C-M-S" isearch-other-window)

(bind "C-h F" customize-face)

;;---------------------------------------------------------
;; Javascript with Slime/Clojure
;;---------------------------------------------------------
(cmd slime-eval-last-expression-as-scriptjure
  "Assume the last expression is valid scriptjure and send it to
slime to get javascript back"
  (slime-eval `(swank:eval-and-grab-output
                ,(concat "(just-js " (slime-last-expression) ")"))))

(defun moz-eval-last-expression (&rest ignored)
  "Convert last expression from scriptjure to javascript use
mozrepl to evaluate in browser"
  (interactive)
  (destructuring-bind (output value) (slime-eval-last-expression-as-scriptjure)
    (if (equal output "")
        (progn
          (comint-send-string
           (inferior-moz-process)
           "(content.toString() === '[object Window]') ? null : (repl.home(), repl.enter(content), null);")
          (comint-send-string
           (inferior-moz-process)
           (concat (first (read-from-string value)) ";")))
      (message output))))

;;; TODO delete I don't think I'll use this
(define-key inferior-moz-mode-map (kbd "C-c l")
  (lambda () (interactive)
    (insert "repl.home(); repl.enter(content);")
    (comint-send-input)))

;;; repl.home(); repl.enter(content);
(bind "C-c j" moz-eval-last-expression)

(require 'sunrise-commander)

;; ;;; This was installed by package-install.el.
;; ;;; This provides support for the package system and
;; ;;; interfacing with ELPA, the package archive.
;; ;;; Move this code earlier if you want to reference
;; ;;; packages in your .emacs.
(when
    (load
     (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))

(require 'inf-ruby)
(require 'ruby-electric)
(add-hook 'ruby-mode-hook (lambda () (ruby-electric-mode t)))

;; (setq grep-program "ack -H -a --nogroup")

(require 'rainbow-mode)

(autoload 'multi-term "multi-term" nil t)
(autoload 'multi-term-next "multi-term" nil t)

;; (setq multi-term-program "/bin/bash")   ;; use bash
(setq multi-term-program "/bin/zsh") ;; or use zsh...

;; only needed if you use autopair
(add-hook 'term-mode-hook
          #'(lambda () (setq autopair-dont-activate t)))

(bind "C-c t" multi-term-next)
(bind "C-c T" multi-term)

(eval-after-load 'clojure-mode
  '(define-clojure-indent (describe 'defun) (it 'defun)
     (slice 'defun) (page 'defun) (rule 'defun)
     (case 'defun) (deftest 'defun)
     (testing 'defun)
     (given 'defun)
     (using 'defun)
     (test 'defun)
     (defs 0)
     (with 'defun)
     (do-it 'defun)))

(bind "C-c :" slime-interactive-eval)

(cmd screencast-start
     "Prepare frame for screencast"
     (set-default-font "DejaVu Sans Mono-12")
     (set-frame-size (selected-frame) 90 22))

(add-to-list 'load-path "~/.elisp/coffee-mode")
(require 'coffee-mode)
(setq-default tab-width 4)

(require 'autopair)

(add-hook 'coffee-mode-hook
          '(lambda()
             (define-key coffee-mode-map (kbd "C-c C-l") 'coffee-compile-buffer)
             (define-key coffee-mode-map (kbd "C-c C-k") 'coffee-compile-file)
             (autopair-mode)
             (set (make-local-variable 'tab-width) 2)))


;; (autoload 'slime-highlight-edits-mode "slime-highlight-edits")
;; (add-hook 'slime-mode-hook (lambda () (slime-highlight-edits-mode 1)))

(require 'contentswitch)
(bind "<f1>" contentswitch)
(bind "M-S-SPC" (lambda () (interactive) (just-one-space 0)))

(cmd delete-current-song
     (let* ((emms-show-format "%s")
           (song (emms-show)))
       (move-file-to-trash song)
       (message (concat "Deleted " song))))

(put 'narrow-to-region 'disabled nil)

(defadvice slime-repl-emit (after sr-emit-ad activate)
  (with-current-buffer (slime-output-buffer)
    (add-text-properties slime-output-start slime-output-end
                         '(font-lock-face slime-repl-output-face
                                          rear-nonsticky (font-lock-face)))))

(defadvice slime-repl-insert-prompt (after sr-prompt-ad activate)
  (with-current-buffer (slime-output-buffer)
    (let ((inhibit-read-only t))
      (add-text-properties slime-repl-prompt-start-mark (point-max)
                           '(font-lock-face slime-repl-prompt-face
                                            rear-nonsticky
                                            (slime-repl-prompt
                                             read-only
                                             font-lock-face
                                             intangible))))))

(defun slime-clojure-repl-setup ()
  (when (string-equal "clojure" (slime-connection-name))
    (message "Setting up repl for clojure")
    (when (slime-inferior-process)
      (slime-redirect-inferior-output))

    (set-syntax-table clojure-mode-syntax-table)
    (clojure-mode-font-lock-setup)

    (setq lisp-indent-function 'clojure-indent-function)

    ;; (when (and (featurep 'paredit) paredit-mode (>= paredit-version 21))
    ;;   (define-key slime-repl-mode-map "{" 'paredit-open-curly)
    ;;   (define-key slime-repl-mode-map "}" 'paredit-close-curly))
    ;; (slime-setup '(slime-fancy))

    ))

(add-hook 'slime-repl-mode-hook 'slime-clojure-repl-setup)

(define-key global-map [(control meta ?r)] 'org-capture)

(bind "C-M-S-k" (lambda () (interactive) (kill-sexp -1)))

(defun my-emms-playlist-total-time-below-point ()
  "Calculates the total time taken for all the tracks currently
  in playlist and below point" (interactive) (let ((move-forward
         t)
        (total-playlist-time 0))
    (save-excursion 		
      (while move-forward
        (setq total-playlist-time
              (+ total-playlist-time
                 (or (emms-track-get (emms-playlist-track-at (point))
                                     'info-playing-time) 0)))
        (forward-line 1)
        (setq move-forward (next-single-property-change (point) 'emms-track))))
    (setq total-hour-only (/ total-playlist-time 3600)
          total-minutes-only (/ (% total-playlist-time 3600) 60)
          total-seconds-only (% total-playlist-time 60))
    (message "Total time is %dh:%dm:%ds" total-hour-only total-minutes-only total-seconds-only)))

(add-to-list 'load-path "~/.elisp/ac-slime")
(require 'ac-slime)
(add-hook 'slime-mode-hook 'set-up-slime-ac)
(add-hook 'slime-repl-mode-hook 'set-up-slime-ac)

(add-hook 'slime-inspector-mode-hook
          (lambda ()
            (font-lock-add-keywords nil '(("\\(\\w+\\)(" 1
                                           font-lock-function-name-face)))))

(require 'scratch)

;; (require 'hl-sexp)
;; (global-hl-sexp-mode)

;; #EEEEDD lightgoldenrod2

;; (require 'highlight-parentheses)
;; (highlight-parentheses-mode)

;; (global-highlight-changes-mode)

(bind "M-P"
      (lambda ()
        (interactive)
        (slime-eval-defun)
        (slime-switch-to-output-buffer)
        (slime-repl-previous-input)
        (slime-repl-return)
        (other-window-reverse)))

(bind "C-c q" delete-indentation)

(bind "M-W" (lambda ()
              (interactive)
              (save-excursion
                (backward-up-list+)
                (let ((beg (point)))
                  (paredit-forward)
                  (copy-region-as-kill beg (point))))
              (message "Copied parent sexp")))

;;; cause M-r only keeps one sexp unless you count them and pass num as arg
;; (bind "M-R" (lambda ()
;;               (interactive)
;;               (let ((beg (point))
;;                     (end (progn (backward-up-list+)
;;                                 (forward-char)
;;                                 (point))))
;;                 (kill-region beg end)
;;                 (paredit-splice-sexp))))

(bind "M-R" paredit-splice-sexp-killing-backward) 

(bind "C-h a" apropos)
(setq apropos-do-all t) ; display non-interactive functions

(require 'auto-complete-etags)
(ac-flyspell-workaround)
(ac-set-trigger-key "TAB")
;; (setq ac-use-menu-map t)
;; ;; Default settings
;; (define-key ac-menu-map "\C-n" 'ac-next)
;; (define-key ac-menu-map "\C-p" 'ac-previous)
(define-key ac-mode-map (kbd "C-c h") 'ac-last-quick-help)
(define-key ac-mode-map
  (kbd "C-c H")
  'ac-last-help)

;(global-visual-line-mode)

;; (require 'popup-pos-tip)
;; (defadvice popup-tip
;;   (around popup-pos-tip-wrapper
;;           (string &rest args)
;;           activate)
;;   (if (eq window-system 'x)
;;       (apply 'popup-pos-tip string args)
;;     ad-do-it))

(bind "<kp-subtract>" beginning-of-defun)
(bind "<kp-add>" end-of-defun)

(require 'parenface)
(set-face-foreground 'paren-face "#888")
(add-hook 'clojure-mode-hook (paren-face-add-support clojure-font-lock-keywords))

(add-to-list 'load-path "~/.elisp/google-weather-el")
(require 'google-weather)
(require 'org-google-weather)

(require 'http-post-simple)

; (display-buffer ".emacs" t)

;; (add-to-list 'load-path "~/.elisp/tabbar")
;; (require 'aquamacs-tabbar)
;; (tabbar-mode)

;; (defun tabbar-buffer-groups (buffer)
;;   "Return the list of group names BUFFER belongs to.
;;  Return only one group for each buffer."
;;   (with-current-buffer (get-buffer buffer)
;;     (cond
;;      ((string-equal "*" (substring (buffer-name) 0 1))
;;       "Emacs Buffer")
;;      ((eq major-mode 'dired-mode)
;;       "Dired")
;;      (t
;;       "User Buffer")
;;      )))

;; (setq tabbar-buffer-groups-function 'tabbar-buffer-groups)

;; (setq tabbar-buffer-groups-function
;;       (lambda ()
;;         (list "All"))) ;; code by Peter Barabas

;; ;; Tabbar
;; (require 'tabbar)
;; (tabbar-mode)
;; (setq tabbar-buffer-groups-function
;;       (lambda ()
;;         (list "All Buffers")))

;; (setq tabbar-buffer-list-function
;;       (lambda ()
;;         (remove-if
;;          (lambda(buffer)
;;            (find (aref (buffer-name buffer) 0) " *"))
;;          (buffer-list))))

;; ;; add a buffer modification state indicator in the tab label,
;; ;; and place a space around the label to make it looks less crowd
;; (defadvice tabbar-buffer-tab-label (after fixup_tab_label_space_and_flag activate)
;;   (setq ad-return-value
;; 		(if (and (buffer-modified-p (tabbar-tab-value tab))
;; 				 (buffer-file-name (tabbar-tab-value tab)))
;; 			(concat " + " (concat ad-return-value " "))
;;           (concat " " (concat ad-return-value " ")))))

;; ;; called each time the modification state of the buffer changed
;; (defun ztl-modification-state-change ()
;;   (tabbar-set-template tabbar-current-tabset nil)
;;   (tabbar-display-update))
;; ;; first-change-hook is called BEFORE the change is made
;; (defun ztl-on-buffer-modification ()
;;   (set-buffer-modified-p t)
;;   (ztl-modification-state-change))
;; (add-hook 'after-save-hook 'ztl-modification-state-change)
;; ;; this doesn't work for revert, I don't know
;; ;;(add-hook 'after-revert-hook 'ztl-modification-state-change)
;; (add-hook 'first-change-hook 'ztl-on-buffer-modification) 

(setq ibuffer-saved-filter-groups
      '(("default"      
         ("emailatask"
          (filename . "/c01/emailatask"))
         ("Clojure"
          (or (mode . clojure-mode)
              (mode . slime-repl-mode)
              (name . "*SLIME Compilation*")
              (name . "*slime-events*")))
         ("Programming"
          (or
           (mode . c-mode)
           (mode . perl-mode)
           (mode . python-mode)
           (mode . emacs-lisp-mode)))
         ("Dired"
          (mode . dired-mode))
         ("Music"
          (name . "EMMS Playlist"))
         ("Org"
          (mode . org-mode))  
         ("Mail"
          (or
           (mode . message-mode)
           (mode . mail-mode)))
         ("ERC"   (mode . erc-mode)))))

(add-hook 'ibuffer-mode-hook
          (lambda ()
            (ibuffer-switch-to-saved-filter-groups "default")))

(bind "C-z" anything)

;;; insert or remove break point for clojure at point. Uses (break) which I
;;; defined for compojure bc swank.core/break doesn't work for me there.
(defun jsj-insert-or-remove-break-point (&optional alt)
  (interactive "p")
  (let ((s (if (= alt 4) "(break)" "(swank.core/break)")))
    (beginning-of-line)
    (if (search-forward s (line-end-position) t)
        (progn (beginning-of-line)
               (kill-line 1))
      (progn (open-line 1)
             (beginning-of-line)
             (insert s)))
    (indent-according-to-mode)))

(define-key clojure-mode-map  (kbd "C-c b") 'jsj-insert-or-remove-break-point)

;;; insert or remove print statement for variable at point. Invoke with C-u to
;;; put statement below current line (e.g. when at arg in function definition)
(defun jsj-insert-or-remove-print (&optional below)
  (interactive "p")
  (let ((word (thing-at-point 'filename)))
    (beginning-of-line)
    (if (search-forward "println" (line-end-position) t)
        (progn (beginning-of-line)
               (kill-line 1))
      (progn (when (= 4 below)
               (next-line))
             (open-line 1)
             (beginning-of-line)
             (insert "(println \"" word ":\" " word ")"))))
  (indent-according-to-mode))

(define-key clojure-mode-map  (kbd "C-c p") 'jsj-insert-or-remove-print)
;(add-hook 'text-mode-hook 'c-subword-mode)

;;; start search at top of buffer
(bind "C-S-s" (lambda () (interactive) (beginning-of-buffer) (isearch-forward)))

;;; cause I hate switching package and then going to repl
(defun slime-goto-current-ns ()
  (interactive)
  (slime-repl-set-package (slime-current-package))
  (slime-switch-to-output-buffer))
(bind "C-c C-S-z" slime-goto-current-ns)

;; (define-key slime-mode-map (kbd "C-M-x")
;;   (lambda ()
;;     (interactive)
;;     (slime-compile-defun)))

(add-to-list 'load-path "~/.elisp/elein")
(require 'elein)

(defun my-emms-show ()
  ;; too slow when switchign several songs! expire option -t doesn't seem to work
  (shell-command (concat "notify-send -t 1000 -i gtk-info \""
                         (emms-track-description
                          (emms-playlist-current-selected-track))
                         "\""))
  (emms-show))

;;---------------------------------------------------------
;; Custom set variables
;;---------------------------------------------------------
;;; Custom-set-variables
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ac-auto-show-menu 0.7)
 '(ac-delay 0.01)
 '(ac-modes (quote (slime-repl-mode emacs-lisp-mode lisp-interaction-mode c-mode cc-mode c++-mode java-mode clojure-mode scala-mode scheme-mode ocaml-mode tuareg-mode perl-mode cperl-mode python-mode ruby-mode ecmascript-mode javascript-mode js-mode js2-mode php-mode css-mode makefile-mode sh-mode fortran-mode f90-mode ada-mode xml-mode sgml-mode)))
 '(ac-quick-help-delay 1.0)
 '(ahk-syntax-directory "c:/Program Files/AutoHotkey/Extras/Editors/Syntax")
 '(appt-display-diary nil)
 '(appt-display-duration 5)
 '(appt-display-interval 5)
 '(appt-message-warning-time 10)
 '(calendar-font-lock-keywords (quote (("\\(A\\(?:pril\\|ugust\\)\\|December\\|February\\|J\\(?:anuary\\|u\\(?:ly\\|ne\\)\\)\\|Ma\\(?:rch\\|y\\)\\|\\(?:Novem\\|Octo\\|Septem\\)ber\\) -?[0-9]+" . font-lock-type-face) ("S[au]" . font-lock-comment-face) ("Fr\\|Mo\\|S[au]\\|T[hu]\\|We" . font-lock-string-face))) t)
 '(clojure-mode-font-lock-comment-sexp t)
 '(clojure-mode-use-backtracking-indent t)
 '(column-number-mode t)
 '(completion-show-help nil)
 '(contentswitch-jump-to-match-location t)
 '(css-indent-offset 2)
 '(dired-dwim-target t)
 '(dired-listing-switches "-haAl")
 '(dired-recursive-deletes (quote always))
 '(display-time-mode t)
 '(display-time-world-list (quote (("America/Los_Angeles" "Pacific") ("America/Denver" "Mountain") ("America/Chicago" "Midwest") ("America/New_York" "Eastern") ("Pacific/Honolulu" "Hawaii") ("Europe/London" "London") ("Europe/Paris" "Paris") ("Europe/Berlin" "Berlin") ("Asia/Calcutta" "Bangalore") ("Asia/Tokyo" "Tokyo") ("Asia/Shanghai" "Shanghai") ("Australia/Sydney" "Sydney"))))
 '(ecb-gzip-setup (quote cons))
 '(ecb-layout-name "left13")
 '(ecb-options-version "2.32")
 '(emms-player-list (quote (emms-player-mplayer-playlist emms-player-mplayer)))
 '(emms-player-mplayer-command-name "/usr/bin/mplayer")
 '(emms-playlist-buffer-name "EMMS Playlist")
 '(emms-playlist-mode-center-when-go t)
 '(eshell-save-history-on-exit t)
 '(fill-column 79)
 '(hfyview-quick-print-in-files-menu t)
 '(ido-create-new-buffer (quote always))
 '(ido-enable-flex-matching t)
 '(ido-enter-matching-directory (quote first))
 '(ido-everywhere t)
 '(ido-max-directory-size 3000000)
 '(ido-max-prospects 10)
 '(ido-max-window-height 1)
 '(ido-max-work-directory-list 50)
 '(ido-max-work-file-list 100)
 '(ido-use-filename-at-point nil)
 '(js2-auto-indent-p t)
 '(js2-enter-indents-newline t)
 '(js2-indent-on-enter-key t)
 '(list-directory-verbose-switches "-l")
 '(ls-lisp-dirs-first t)
 '(ls-lisp-format-time-list (quote ("%Y-%m-%d" "%Y-%m-%d")))
 '(ls-lisp-ignore-case t)
 '(ls-lisp-use-localized-time-format t)
 '(ls-lisp-verbosity nil)
 '(notmuch-message-headers (quote ("Subject" "To" "Cc" "Date" "User-Agent" "X-Mailer")))
 '(notmuch-message-headers-visible t)
 '(notmuch-saved-searches (quote (("inbox+unread" . "tag:inbox and tag:unread") ("inbox" . "tag:inbox") ("unread" . "tag:unread"))))
 '(notmuch-search-oldest-first nil)
 '(notmuch-show-logo nil)
 '(nxhtml-skip-welcome t)
 '(org-agenda-files (quote ("~/org/birthdays.org" "~/org/workout.org" "~/org/recipes.org" "~/org/someday.org" "~/org/quotes.org" "~/org/todo.org" "~/org/calendar.org" "~/org/shopping.org")))
 '(org-agenda-window-frame-fractions (quote (0.1 . 0.75)))
 '(org-atom-publish-content t)
 '(org-export-with-section-numbers nil)
 '(org-log-repeat nil)
 '(recentf-max-menu-items 1000)
 '(scroll-bar-mode (quote right))
 '(session-locals-include (quote (overwrite-mode buffer-undo-list)))
 '(show-paren-mode t)
 '(slime-autodoc-delay 0.1)
 '(slime-complete-symbol*-fancy t)
 '(slime-complete-symbol-function (quote slime-fuzzy-complete-symbol))
 '(speedbar-hide-button-brackets-flag t)
 '(speedbar-indentation-width 2)
 '(speedbar-show-unknown-files t)
 '(speedbar-update-flag nil t)
 '(speedbar-use-images nil)
 '(sql-product (quote mysql))
 '(sr-windows-locked nil)
 '(tabbar-home-button (quote ((" Modes") "")))
 '(tabbar-scroll-left-button (quote ((" <") " <")))
 '(tabbar-scroll-right-button (quote (("  > ") " >")))
 '(todochiku-icons-directory "~/todochiku-icons")
 '(tooltip-delay 2)
 '(w32shell-shell (quote cmd))
 '(work-timer-relax-time 5)
 '(work-timer-working-time 25))

;;; for audiobooks
;; (setq emms-player-mplayer-parameters
;;       '("-slave" "-quiet" "-really-quiet"
;;         "-af" "scaletempo"
;;         "-speed" "2.0"))

;; (setq browse-url-browser-function 'w3m-browse-url)
;; (autoload 'w3m-browse-url "w3m" "Ask a WWW browser to show a URL." t)
;; optional keyboard short-cut
(global-set-key "\C-xm" 'browse-url-at-point)

(cmd insert-javadoc-call
     (insert "(clojure.java.javadoc/javadoc )")
     (backward-char))

(bind "C-x j" insert-javadoc-call)

;;; must open file normally first, then run this
(defun find-alternative-file-with-sudo ()
  (interactive)
  (let ((fname (or buffer-file-name
                   dired-directory)))
    (when fname
      (if (string-match "^/sudo:root@localhost:" fname)
          (setq fname (replace-regexp-in-string
                       "^/sudo:root@localhost:" ""
                       fname))
        (setq fname (concat "/sudo:root@localhost:" fname)))
      (find-alternate-file fname))))

(global-set-key (kbd "C-x C-r") 'find-alternative-file-with-sudo)

;;; use print
;; (setq slime-message-function 'osd-slime-message)

;; (defun osd-slime-message (format-string &rest args)
;;   (shell-command (concat "notify-send -t 1000 -i clojure Clojure " (apply #'format format-string args) ""))
;;   (apply #'message format-string args ))

;; (progn
;;   (setq cdt-dir (file-truename "~/src/cdt"))
;;   (setq cdt-source-path "/home/scott/src/clojure/src/clj:/home/scott/src/clojure/src/jvm:/home/scott/src/clojure-contrib/src/main/clojure:")

;;   (mapcar #'file-directory-p (split-string cdt-source-path ":"))
;;   (load-file (format "%s/ide/emacs/cdt.el" cdt-dir)))

(require 'fuzzy)
(turn-on-fuzzy-isearch)

(when (fboundp 'winner-mode)
  (winner-mode 1))

;;; thanks tomoj converts (if x (foo x
(bind "C-c C-f" paredit-convolute-sexp)

;; (setq-default indicate-empty-lines t)
;; (setq-default indicate-buffer-boundaries t)
;; the following is size 7 for me...
;(set-face-font 'default "-unknown-Envy Code R-normal-normal-normal-*-13-*-*-*-m-0-iso10646-1")
;;(set-default-font "Envy Code R-7") ;; doesn't work consistently ;(

(defun ido-goto-symbol (&optional symbol-list)
  "Refresh imenu and jump to a place in the buffer using Ido."
  (interactive)
  (unless (featurep 'imenu)
    (require 'imenu nil t))
  (cond
   ((not symbol-list)
    (let ((ido-mode ido-mode)
          (ido-enable-flex-matching
           (if (boundp 'ido-enable-flex-matching)
               ido-enable-flex-matching t))
          name-and-pos symbol-names position)
      (unless ido-mode
        (ido-mode 1)
        (setq ido-enable-flex-matching t))
      (while (progn
               (imenu--cleanup)
               (setq imenu--index-alist nil)
               (ido-goto-symbol (imenu--make-index-alist))
               (setq selected-symbol
                     (ido-completing-read "Symbol? " symbol-names))
               (string= (car imenu--rescan-item) selected-symbol)))
      (unless (and (boundp 'mark-active) mark-active)
        (push-mark nil t nil))
      (setq position (cdr (assoc selected-symbol name-and-pos)))
      (cond
       ((overlayp position)
        (goto-char (overlay-start position)))
       (t
        (goto-char position)))))
   ((listp symbol-list)
    (dolist (symbol symbol-list)
      (let (name position)
        (cond
         ((and (listp symbol) (imenu--subalist-p symbol))
          (ido-goto-symbol symbol))
         ((listp symbol)
          (setq name (car symbol))
          (setq position (cdr symbol)))
         ((stringp symbol)
          (setq name symbol)
          (setq position
                (get-text-property 1 'org-imenu-marker symbol))))
        (unless (or (null position) (null name)
                    (string= (car imenu--rescan-item) name))
          (add-to-list 'symbol-names name)
          (add-to-list 'name-and-pos (cons name position))))))))

(global-set-key "\C-c." 'ido-goto-symbol)

(require 'webjump)
(global-set-key (kbd "<f2> w") 'webjump)
(setq webjump-sites (append '(("Java API" . [simple-query "www.google.com" "http://www.google.ca/search?hl=en&as_sitesearch=http://java.sun.com/javase/6/docs/api/&q=" ""])) webjump-sample-sites))

(add-hook 'align-load-hook
          (lambda ()
            (add-to-list 'align-rules-list
                         '(text-column-whitespace
                           (regexp . "\\(^\\|\\S-\\)\\([ \t]+\\)")
                           (group  . 2)
                           (modes  . align-text-modes)
                           (repeat . t)))
            (add-to-list 'align-lisp-modes 'clojure-mode)
            (add-to-list 'align-rules-list
                         '(clojure-keyword-map
                           (regexp . ":[^\s]+\\(\s+\\).+")
                           (group  . 1)
                           (modes  . align-lisp-modes)))))

(defun align-repeat (start end regexp)
  "Repeat alignment with respect to 
     the given regular expression."
  (interactive "r\nsAlign regexp: ")
  (align-regexp start end 
                (concat "\\(\\s-*\\)" regexp) 1 1 t))

(bind "C-c C-R" slime-eval-region)

(defun delete-this-buffer-and-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (when (yes-or-no-p "Are you sure you want to remove this file? ")
        (delete-file filename)
        (kill-buffer buffer)
        (message "File '%s' successfully removed" filename)))))

(global-set-key (kbd "C-c k") 'delete-this-buffer-and-file)

;; symbols for some overlong function names
(eval-after-load 'clojure-mode
  '(font-lock-add-keywords
    'clojure-mode
    (mapcar
     (lambda (pair)
       `(,(car pair)
         (0 (progn (compose-region
                    (match-beginning 0) (match-end 0)
                    ,(cadr pair))
                   nil))))
     `(("\\<fn\\>" ,(make-char 'greek-iso8859-7 107))
       ("\\<comp\\>" ?∘)
       ("\\<partial\\>" ?þ)
       ("\\<complement\\>" ?¬)
       ))))

;; (define-key slime-mode-map (kbd "M-a") 'slime-beginning-of-defun)
;; (define-key slime-mode-map (kbd "M-e") 'slime-end-of-defun)

(defun clojure-jump-to-function-test ()
  (interactive)
  (flet ((maybe-create-test-namespace
          (namespace)
          (unless (clojure-find-package)
            (goto-char (point-min))
            (insert (format "(ns %s\n  (:use [%s] [clojure.test]))\n\n"
                            (replace-regexp-in-string "\\(\\.\\)[^\\.]+$" ".test." namespace nil nil 1)
                            namespace)))))
    (let* ((fn (which-function))
           (fn-name (if (listp fn) (first fn) fn))
           (namespace (clojure-find-package)))
      (clojure-jump-to-test)
      (when fn-name
        (goto-char (point-min))
        (maybe-create-test-namespace namespace)
        (unless (search-forward-regexp (format "(deftest test-%s[ \t\n]*" fn-name) nil t)
          (goto-char (point-max))
          (insert (format "\n\n(deftest test-%s\n  )" fn-name))
          (goto-char (- (point) 1)))))))

(global-set-key (kbd "<M-S-backspace>")
                (lambda () (interactive)
                  (backward-kill-word 1)
                  (backward-delete-char 1)))

(require 'org-protocol)
(setq org-capture-templates
      (quote (("w" "web note" entry (file+headline "~/org/web.org" "Notes") "* Source: %u, %c\n  %i")
              ("l" "scriptjure political or economic references" entry (file+headline "~/org/scripture-study.org" "Politics or Economic")
               "* %c %^{Type|descriptive|prescriptive|other} %U\n  %i\n\n   Notes: %^{Notes}")
              ("s" "scripture" entry (file+headline "~/org/scripture-study.org" "Notes") "* %c %U\n  %i")
              ("x" "co template" entry (file+headline "~/org/co.org" "co") "* %c\n" :immediate-finish 1)
              ("b" "book" entry (file+headline "~/www/org/truth.org" "Notes") "* %U\n  %?")
              ("t" "todo" entry (file+headline "~/org/todo.org" "Tasks") "* TODO %?")
              ("c" "calendar" entry (file+headline "~/org/calendar.org" "Events") "* %?\n  %^t")
              ("p" "phone-calls" entry (file+headline "~/doc/phone-calls.org" "Phone Calls") "* %T %?")
              ("j" "journal" entry (file+headline "~/doc/personal/journal.org" "Journal") "* %U\n%?")
              ("m" "music" entry (file+headline "~/org/music.org" "Music to checkout") "* :%^{Field|song|artist|album} %^{Value} :%^{Field|song|artist|album} %^{Value}")
              ("v" "movie" entry (file+headline "~/org/movies.org" "Movies to see") "* %^{Movie name}")
              ("n" "note" entry (file+headline "~/org/notes.org" "Notes") "* %U\n  %?")
              ("f" "food" entry (file+headline "~/org/food.org" "Food") "* %U\n  - %?")
              ("f" "programming" entry (file+headline "~/org/programming.org" "Questions") "* %U\n  - %?")
              ("e" "exercise" entry (file+headline "~/org/exercise.org" "Exercise") "* %U\n  - %?")
              ("o" "other" entry (file+headline "~/remember.org" "") "* %a\n%i"))))

;; (add-to-list 'load-path "~/src/gnus/lisp/")
;; (require 'gnus-load)

(add-to-list 'load-path "~/src/notmuch/emacs")
(require 'notmuch)
(setq mail-specify-envelope-from t
      message-sendmail-envelope-from 'header
      mail-envelope-from 'header)
;; (load "~/.notmuch")

(require 'javadoc-help)
(bind "<f9> j" javadoc-lookup)
(bind "<f9> J" javadoc-help)
(javadoc-set-predefined-urls '("/usr/share/doc/openjdk-6-jre-headless/api/"))

;; (byte-recompile-directory "~/.elisp" 0 t)

(bind "C-x C-S-e" eval-buffer)

(defun dired-view-file ()
  "In Dired, examine a file in view mode, returning to Dired when done.
When file is a directory, show it in this buffer if it is inserted.
Otherwise, display it in another buffer."
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (if (file-directory-p file)
        (or (and (cdr dired-subdir-alist)
                 (dired-goto-subdir file))
            (dired file))
      (view-file-other-window file))))

(defun dired-view-file-next (&optional reverse)
  (interactive)
  (View-quit)
  (if reverse (previous-line)
    (next-line))
  (dired-view-file))

(defun dired-view-file-previous ()
  (interactive)
  (dired-view-file-next 1))

(define-key view-mode-map (kbd "n") 'dired-view-file-next)
(define-key view-mode-map (kbd "p") 'dired-view-file-previous)

;; (autoload 'align-let "align-let" nil t)
;; (autoload 'align-let-keybinding "align-let" nil t)
;; (add-hook 'emacs-lisp-mode-hook 'align-let-keybinding)
;; (add-hook 'scheme-mode-hook     'align-let-keybinding)
;; (let ((abcsadf 2)
;;       (b       2)))

;; (let [abc 3
;;           c 3])

;; (setq foo 1
;;       b   2)

(defun jsj-ac-show-help ()
  "show docs for symbol at point or at beginning of list if not on a symbol"
  (interactive)
  (let ((s (save-excursion
             (or (symbol-at-point)
                 (progn (backward-up-list)
                        (forward-char)
                        (symbol-at-point))))))
    (pos-tip-show (if (equal major-mode 'emacs-lisp-mode)
                      (ac-symbol-documentation s)
                    (ac-slime-documentation (symbol-name s)))
                  'popup-tip-face
                  ;; 'alt-tooltip
                  (point)
                  nil
                  -1)))

(define-key lisp-mode-shared-map (kbd "C-c C-h") 'jsj-ac-show-help)

;; (defface alt-tooltip
;;   '((t
;;      :background "gray85"
;;      :foreground "black"
;;      :inherit variable-pitch))
;;   "Face for my tooltip.")

(defun backward-up-list+-1 ()
  "go to left of )"
  (interactive)
  (backward-up-list+)
  (forward-char))

(define-key lisp-mode-shared-map (kbd "C-M-9") 'backward-up-list+-1)

(defun up-list+-1 ()
  "go to right of ("
  (interactive)
  (up-list+)
  (backward-char))

(define-key lisp-mode-shared-map (kbd "C-M-0") 'up-list+-1)

(require 'flymake)

(defun flymake-Haskell-init ()
  (flymake-simple-make-init-impl
   'flymake-create-temp-with-folder-structure nil nil
   (file-name-nondirectory buffer-file-name)
   'flymake-get-Haskell-cmdline))

(defun flymake-get-Haskell-cmdline (source base-dir)
  (list "flycheck_haskell.pl"
        (list source base-dir)))

(push '(".+\\.hs$" flymake-Haskell-init flymake-simple-java-cleanup)
      flymake-allowed-file-name-masks)
(push '(".+\\.lhs$" flymake-Haskell-init flymake-simple-java-cleanup)
      flymake-allowed-file-name-masks)
(push
 '("^\\(\.+\.hs\\|\.lhs\\):\\([0-9]+\\):\\([0-9]+\\):\\(.+\\)"
   1 2 3 4) flymake-err-line-patterns)

;; optional setting
;; if you want to use flymake always, then add the following hook.
;; (add-hook
;;  'haskell-mode-hook
;;  '(lambda ()
;;     (if (not (null buffer-file-name)) (flymake-mode))))

(when (fboundp 'resize-minibuffer-mode) ; for old emacs
  (resize-minibuffer-mode)
  (setq resize-minibuffer-window-exactly nil))

(add-to-list 'load-path "~/src/shime")
(require 'shime)

(define-key haskell-mode-map [f5] 'shime-load-file)
;;; commented till bother to come up with bindings that don't conflict w/ commenting
;; (define-key haskell-mode-map (kbd "C-c C-c") 'shime-cabal-build)
;; (define-key haskell-mode-map (kbd "C-c c") 'shime-cabal-ido)

;;; need to move from opt on mamey to src on everything
(add-to-list 'load-path "~/src/scala-2.8.1.final/misc/scala-tool-support/emacs/")
(require 'scala-mode-auto)
(add-to-list 'exec-path "~/src/scala-2.8.1.final/bin/")

;; Load the ensime lisp code...
(add-to-list 'load-path "~/src/ensime_2.8.1-0.4.1/elisp/")
(require 'ensime)

;; This step causes the ensime-mode to be started whenever
;; scala-mode is started for a buffer. You may have to customize this step
;; if you're not using the standard scala mode.
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)

(bind "M-S-s" paredit-split-sexp)
(define-key paredit-mode-map  (kbd "M-S") 'paredit-split-sexp)
(define-key paredit-mode-map  (kbd "M-s") 'save-buffer)
(global-set-key (kbd "M-s") 'save-buffer)

(defun jump-to-mark ()
  "Jumps to the local mark, respecting the `mark-ring' order.
This is the same as using \\[set-mark-command] with the prefix argument."
  (interactive)
  (set-mark-command 1))
(global-set-key (kbd "M-`") 'jump-to-mark)

;;; more precise move keys
;; (setq shift-select-mode nil)

;; (defun forward-word2 ()
;;   (interactive)
;;   (forward-word 2)
;;   (backward-word))
;; (bind "M-F" forward-word2)

;; (defun backward-word2 ()
;;   (interactive)
;;   (backward-word 2)
;;   (forward-word))
;; (bind "M-B" backward-word2)
(global-set-key (kbd "C-;") 'anything)

;; (add-to-list 'align-rules-list
;;              '(text-column-whitespace
;;                (regexp . "\\(^\\|\\S-\\)\\([ \t]+\\)")
;;                (group  . 2)
;;                (modes  . align-text-modes)
;;                (repeat . t)))

;; (autoload 'align-cols "align" "Align text in the region." t)

(add-to-list 'load-path "~/.elisp/align-cljlet")
(require 'align-cljlet)

(global-set-key (kbd "M-a") 'ido-switch-buffer)

(defun define-function ()
  (interactive)
  (let ((name (symbol-at-point)))
    (backward-paragraph)
    (insert "\n(defn " (symbol-name name) "\n  [])\n" )
    (backward-char 3)))

(define-key clojure-mode-map (kbd "C-c f") 'define-function)

(defadvice he-substitute-string (after he-paredit-fix)
  "remove extra paren when expanding line in paredit"
  (if (and paredit-mode (equal (substring str -1) ")"))
      (progn (backward-delete-char 1) (forward-char))))

;; (defun he-substitute-string (str &optional trans-case)
;;   (let ((trans-case (and trans-case
;;                          case-replace
;;                          case-fold-search))
;;         (newpos (point-marker))
;;         (subst ()))
;;     (goto-char he-string-beg)
;;     (setq subst (if trans-case (he-transfer-case he-search-string str) str))
;;     (setq he-tried-table (cons subst he-tried-table))
;;     (insert subst)
;;     (delete-region (point) he-string-end)
;;     (goto-char newpos)
;;     ;; only lines that changed:
;;     (if (and paredit-mode (equal (substring subst -1) ")"))
;;         (progn (backward-delete-char 1) (forward-char)))))

;;; fix hippie expand bug when using paredit where extra paren
;; (require 'hippie-exp)

;; (fset 'he-substitute-string-orig (symbol-function 'he-substitute-string))

;; (defun he-substitute-string (str &optional trans-case)
;;   (he-substitute-string-orig str trans-case)
;;   (if (and paredit-mode (equal (substring str -1) ")"))
;;       (progn (backward-delete-char 1) (forward-char))))

;; (global-set-key "\C-h" 'ehelp-command)

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
)

;; (require 'secrets)

(add-to-list 'load-path "~/.elisp/workgroups.el/")
(require 'workgroups)
(setq wg-prefix-key (kbd "C-c w"))
(workgroups-mode 1)

(setq display-buffer-reuse-frames t)

(add-to-list 'load-path "~/.elisp/emacs-nexus/")
(require 'nexus)


(require 'doc-view)
(setq doc-view-resolution 160)
(define-key doc-view-mode-map (kbd "C-v") 'doc-view-scroll-up-or-next-page)
(define-key doc-view-mode-map (kbd "M-v") 'doc-view-scroll-down-or-previous-page)

;;; thanks retroj for helping w/ this
(defun isearch-exit-at-opposite-end ()
  "by default isearch forward ends at end and isearch backward
  ends at beginning. this makes it do the opposite."
  (interactive)
  (add-hook 'isearch-mode-end-hook 'isearch-move-point-to-opposite-end)
  (isearch-exit))

(defun isearch-move-point-to-opposite-end ()
  (funcall (if isearch-forward #'backward-char #'forward-char)
           (length isearch-string))
  (remove-hook 'isearch-mode-end-hook 'isearch-move-point-to-opposite-end))

(define-key isearch-mode-map (kbd "<C-return>") 'isearch-exit-at-opposite-end)
