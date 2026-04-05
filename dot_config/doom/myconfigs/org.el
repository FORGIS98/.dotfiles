;;; myconfigs/org.el -*- lexical-binding: t; -*-

(setq org-directory "~/mi-gemelo-digital/")
(setq org-agenda-start-on-weekday 1)
(setq calendar-week-start-day 1)
(setq org-agenda-files
      (directory-files-recursively "~/mi-gemelo-digital/" "\\.org$"))

(defun my/org-skip-subtree-if-priority (priority)
  "Skip an agenda subtree if it has a priority of PRIORITY.

PRIORITY may be one of the characters ?A, ?B, or ?C."
  (let ((subtree-end (save-excursion (org-end-of-subtree t)))
        (pri-value (* 1000 (- org-lowest-priority priority)))
        (pri-current (org-get-priority (thing-at-point 'line t))))
    (if (= pri-value pri-current)
        subtree-end
      nil)))

(defun my/org-skip-subtree-if-habit ()
  "Skip an agenda entry if it has a STYLE property equal to \"habit\"."
  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (string= (org-entry-get nil "STYLE") "habit")
        subtree-end
      nil)))

(setq org-agenda-custom-commands
      '(;; ---------------------------------------------------------
        ;; JOB "J"
        ;; ---------------------------------------------------------

        ("j" . "job")

        ("jd" "daily view"
         ((tags "PRIORITY=\"A\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "High Priority! DO-NOW:")))
          (agenda ""
                  ((org-agenda-span 3)
                   (org-deadline-warning-days 0)
                   (org-agenda-skip-deadline-prewarning-if-scheduled t)
                   (org-agenda-start-day "0d")
                   (org-agenda-prefix-format " %i %-25:c%?-12t% s")))
          (alltodo ""
                   ((org-agenda-skip-function (lambda () (or (org-agenda-skip-if nil '(scheduled deadline)))))
                    (org-agenda-overriding-header "TODO-LIST:")
                    (org-agenda-prefix-format " %i %-25:c"))))
         ((org-agenda-files (append
                             (directory-files-recursively "~/mi-gemelo-digital/job/" "\\.org$")
                             (list "~/mi-gemelo-digital/cumpleaños.org"
                                   "~/mi-gemelo-digital/calendario-eventos.org")))
          (org-agenda-compact-blocks nil)
          (org-agenda-block-separator #x2500)))

        ;; ---------------------------------------------------------
        ;; PERSONAL "P"
        ;; ---------------------------------------------------------

        ("p" . "personal")

        ("pd" "daily view"
         ((tags "PRIORITY=\"A\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "High Priority! DO-NOW:")))
          (agenda ""
                  ((org-agenda-span 3)
                   (org-agenda-start-day "0d")
                   (org-deadline-warning-days 0)
                   (org-agenda-skip-deadline-prewarning-if-scheduled t)
                   (org-habit-show-habits nil)
                   (org-agenda-prefix-format " %i %-25:c%?-12t% s")))
          (alltodo ""
                   ((org-agenda-skip-function (lambda ()
                                                (or (my/org-skip-subtree-if-habit)
                                                    (my/org-skip-subtree-if-priority ?A)
                                                    (org-agenda-skip-if nil '(scheduled deadline)))))
                    (org-agenda-overriding-header "TODO-LIST:")
                    (org-agenda-prefix-format " %i %-25:c"))))
         ((org-agenda-files (append
                             (directory-files-recursively "~/mi-gemelo-digital/personal/" "\\.org$")
                             (list "~/mi-gemelo-digital/cumpleaños.org"
                                   "~/mi-gemelo-digital/calendario-eventos.org")))
          (org-agenda-compact-blocks nil)
          (org-agenda-block-separator #x2500)))))

(defun my/pop-to-org-agenda (&optional split)
  "Visit the org agenda, in the current window or a SPLIT."
  (interactive "P")
  (if (string-prefix-p "ES99P4brP0pSx2I" (system-name))
      (org-agenda nil "jd")
    (org-agenda nil "pd"))
  (when (not split)
    (delete-other-windows)))

(define-key evil-normal-state-map (kbd "S-SPC") 'my/pop-to-org-agenda)

(after! calendar
  (setq calendar-week-start-day 1))

;; log into LOGBOOK drawer
(setq org-log-into-drawer t)

(after! org
  (setq org-start-on-weekday 1)
  (setq org-capture-templates
        '(;; --- Grupo de TRABAJO (tecla "w") ---
          ("j" "job")
          ("jt" "tasks" entry
           (file "job/todo.org")
           "* TODO %?\n"
           :prepend t)
          ("jm" "meeting" entry
           (file "job/meetings.org")
           "* REU %?")

          ;; --- Grupo PERSONAL (tecla "p") ---
          ("p" "personal")
          ("pt" "tasks" entry
           (file "personal/todo.org")
           "* TODO %?\n"
           :prepend t)
          ("pj" "journal" entry
           (file+datetree "personal/journal.org")
           "* %?"))))

(map! :leader
      :desc "capture something"           "x" #'org-capture
      :desc "pop up a persistent scratch buffer" "X" #'doom/open-scratch-buffer)

(map! :leader
      (:prefix-map ("o" . "open")
                   (:prefix-map ("c" . "calendar")
                    :desc "today"                      "t" #'org-timeblock)))

(after! org-timeblock
  :config
  (setq org-timeblock-span 1)
  (setq org-timeblock-scale-options '(6 . 24)))

(after! tmr
  :config
  (setq tmr-dateline-file (concat doom-cache-dir "tmr-dateline"))

  (setq tmr-notification-functions
        '(tmr-notification-notify
          tmr-notification-notify-send
          tmr-notification-play-audio)))

(map! :leader
        (:prefix "t"
         :desc "Set timer"         "t" #'tmr-with-details
         :desc "List timers"       "l" #'tmr-tabulated-view
         :desc "Cancel timer"      "c" #'tmr-cancel
         :desc "Clone timer"       "m" #'tmr-clone))

(setq org-enforce-todo-dependencies t)
