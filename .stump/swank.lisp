;;; Load swank first in case something doesn't work.
(load (home ".elisp/slime/swank-loader.lisp"))
(swank-loader:init)

(defcommand swank (&optional port) ()
  (setf stumpwm:*top-level-error-action* :break)
  (swank:create-server :port (or port 4006)
                       :coding-system "utf-8"
                       :style swank:*communication-style*
                       :dont-close t)
  (message "Starting swank."))
(define-key *root-map* (kbd "C-s") "swank")

