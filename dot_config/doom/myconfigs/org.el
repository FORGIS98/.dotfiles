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

(defun my/org-skip-if-tag-yo()
  "Skip element if has tag :yo:"
  (let ((tags (org-get-tags)))
    (if (member "yo" tags)
        (org-end-of-subtree t)
      nil)))

(defun my/org-skip-subtree-if-not-habit ()
  "Salta una entrada si NO es un hábito."
  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (not (string= (org-entry-get nil "STYLE") "habit"))
        subtree-end
      nil)))

(setq org-agenda-custom-commands
      '(;; ---------------------------------------------------------
        ;; WORK "W"
        ;; ---------------------------------------------------------

        ("w" . "work")

        ("wd" "daily view"
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
                   ((org-agenda-skip-function (lambda ()
                                                (or (my/org-skip-subtree-if-habit)
                                                    (my/org-skip-subtree-if-priority ?A)
                                                    (my/org-skip-if-tag-yo)
                                                    (org-agenda-skip-if nil '(scheduled deadline)))))
                    (org-agenda-overriding-header "TODO-LIST:")
                    (org-agenda-prefix-format " %i %-25:c"))))
         ((org-agenda-compact-blocks nil)
          (org-agenda-block-separator #x2500)))

        ("wt" "tmp"
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
                   ((org-agenda-skip-function (lambda ()
                                                (or (my/org-skip-subtree-if-habit)
                                                    (my/org-skip-subtree-if-priority ?A)
                                                    (my/org-skip-if-tag-yo)
                                                    (org-agenda-skip-if nil '(scheduled deadline)))))
                    (org-agenda-overriding-header "TODO-LIST:")
                    (org-agenda-prefix-format " %i %-25:c"))))
         ((org-agenda-files (list "~/mi-gemelo-digital/work/"
                                  "~/mi-gemelo-digital/cumpleaños.org"
                                  "~/mi-gemelo-digital/eventos-importantes.org"))
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
                   (org-agenda-prefix-format " %i %-25:c%?-12t% s")))
          (alltodo ""
                   ((org-agenda-skip-function (lambda ()
                                                (or (my/org-skip-subtree-if-habit)
                                                    (my/org-skip-subtree-if-priority ?A)
                                                    (org-agenda-skip-if nil '(scheduled deadline)))))
                    (org-agenda-overriding-header "TODO-LIST:")
                    (org-agenda-prefix-format " %i %-25:c"))))
         ((org-agenda-files (list "~/mi-gemelo-digital/personal/"
                                  "~/mi-gemelo-digital/cumpleaños.org"
                                  "~/mi-gemelo-digital/eventos-importantes.org"))
          (org-agenda-compact-blocks nil)
          (org-agenda-block-separator #x2500)))

        ("ph" "Habits Timeline"
         ((agenda ""
                  ((org-agenda-span 3)
                   (org-agenda-start-day "0d")
                   (org-agenda-skip-function '(my/org-skip-subtree-if-not-habit))
                   (org-agenda-overriding-header "Habit Consistency Chart:")))))))

(defun my/pop-to-org-agenda (&optional split)
  "Visit the org agenda, in the current window or a SPLIT."
  (interactive "P")
  (if (string-prefix-p "ES99P4brP0pSx2I" (system-name))
      (org-agenda nil "wd")
    (org-agenda nil "pd"))
  (when (not split)
    (delete-other-windows)))

(define-key evil-normal-state-map (kbd "S-SPC") 'my/pop-to-org-agenda)

(after! calendar
  (setq calendar-week-start-day 1))

(setq org-todo-keywords
      '((sequence "TODO(t)" "|" "DONE(d!)" "CANC(c!)")))

;; log into LOGBOOK drawer
(setq org-log-into-drawer t)

(after! org
  (setq org-start-on-weekday 1)
  (setq org-capture-templates
        '(;; --- Grupo de TRABAJO (tecla "w") ---
          ("w" "work")
          ("wt" "tasks" entry
           (file "work/todo.org")
           "* TODO %?\n"
           :prepend t)
          ("wm" "meeting" entry
           (file "work/meetings.org")
           "* REU %?")

          ;; --- Grupo PERSONAL (tecla "p") ---
          ("p" "personal")
          ("pt" "tasks" entry
           (file "personal/todo.org")
           "* TODO %?\n"
           :prepend t)
          ("pj" "diary" entry
           (file+datetree "personal/journal.org")
           "* %?"))))

(map! :leader
      :desc "capture something"           "x" #'org-capture
      :desc "pop up a persistent scratch buffer" "X" #'doom/open-scratch-buffer)

(use-package! calfw-org)

(map! :leader
      (:prefix-map ("o" . "open")
                   (:prefix-map ("c" . "calendar")
                    :desc "today"                      "t" #'org-timeblock)))

(after! org-timeblock
  :config
  (setq org-timeblock-span 1)
  (setq org-timeblock-scale-options '(6 . 24)))
