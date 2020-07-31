;;; packages.el --- slack layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2020 Sylvain Benner & Contributors
;;
;; Author: Kosta Harlan <kosta@kostaharlan.net>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;; TODO: Integrate company-emoji.

(defconst slack-packages
  '(
    alert
    emoji-cheat-sheet-plus
    flyspell
    linum
    persp-mode
    slack
    window-purpose))

(defun slack/init-alert ()
  (use-package alert
    :defer t
    :init (setq alert-default-style 'notifier)))

(defun slack/post-init-emoji-cheat-sheet-plus ()
  (add-hook 'slack-mode-hook 'emoji-cheat-sheet-plus-display-mode))

(defun slack/post-init-flyspell ()
  (add-hook 'lui-mode-hook 'flyspell-mode))

(defun slack/post-init-linum ()
  (add-hook 'slack-mode-hook 'spacemacs/no-linum))

(defun slack/pre-init-persp-mode ()
  (spacemacs|use-package-add-hook persp-mode
    :post-config
    (progn
      (add-to-list 'persp-filter-save-buffers-functions
                   'spacemacs//slack-persp-filter-save-buffers-function)
      (spacemacs|define-custom-layout slack-spacemacs-layout-name
        :binding slack-spacemacs-layout-binding
        :body
        (progn
          (add-hook 'slack-mode #'spacemacs//slack-buffer-to-persp)
          ;; TODO: We don't want to slack-start every time someone types `SPC l o s`
          (call-interactively 'slack-start)
          (call-interactively 'slack-channel-select))))))

(defun slack/init-slack ()
  "Initialize Slack"
  (use-package slack
    :commands (slack-start)
    :defer t
    :init
    (spacemacs/declare-prefix "acs" "slack")
    (spacemacs/set-leader-keys
      "acsd" 'slack-im-select
      "acsg" 'slack-group-select
      "acsj" 'slack-channel-select
      "acsq" 'slack-ws-close
      "acsr" 'slack-select-rooms
      "acss" 'slack-start)
    (setq slack-enable-emoji t)
    :config
    (dolist (mode '(slack-mode slack-message-buffer-mode slack-thread-message-buffer-mode))
      (spacemacs/set-leader-keys-for-major-mode mode
        "#" 'slack-message-embed-channel
        "(" 'slack-message-remove-reaction
        ")" 'slack-message-add-reaction
        "@" 'slack-message-embed-mention
        "d" 'slack-im-select
        "e" 'slack-message-edit
        "g" 'slack-group-select
        "j" 'slack-channel-select
        "k" 'slack-select-rooms
        "mc" 'slack-message-embed-channel
        "mm" 'slack-message-embed-mention
        "p" 'slack-room-load-prev-messages
        "q" 'slack-ws-close
        "r" 'slack-select-rooms
        "t" 'slack-thread-show-or-create)
      (let ((keymap (symbol-value (intern (concat (symbol-name mode) "-map")))))
        (evil-define-key 'insert keymap
          (kbd "#") 'slack-message-embed-channel
          (kbd ":") 'slack-insert-emoji
          (kbd "@") 'slack-message-embed-mention)))))

(defun slack/post-init-window-purpose ()
  (purpose-set-extension-configuration
   :slack-layer
   (purpose-conf :mode-purposes '((slack-mode . chat)))))
