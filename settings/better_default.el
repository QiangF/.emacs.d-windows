;; Time-stamp: <2017-07-29 09:34:14 lynnux>
;; gui���������set_gui.el��
;; ����plugin������plugin_basic.el��,�ǹٷ�����plugin_extra.el��

(require 'server)
;; ���win7�ϵĲ���ȫ��ʾ��Ϣ
(and (>= emacs-major-version 23) (defun server-ensure-safe-dir (dir) "Noop" t))
(when (string-equal system-type "windows-nt")
  (server-start))
(eval-after-load "server" '(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)) ; ȥ���ر�emacsclientw�򿪵��ļ�����ʾ
(define-key global-map "\C-r" 'kill-ring-save); M-w������������
(define-key global-map (kbd "C-x SPC") (lambda () (interactive)
      (switch-to-buffer (other-buffer (current-buffer) 1)))) ; ���buffer�л�
(global-set-key (kbd "C-v") 'yank)	; ��ҳ��������
(global-set-key (kbd "C-S-v") 'popup-kill-ring)
(delete-selection-mode 1);; ѡ���滻ģʽ���ȽϷ��㣬���Ǿ�˵�и����ã���������˵
(global-set-key [?\C-h] 'delete-backward-char) ;C-H��ɾ���ܺ��ã�
(global-set-key [?\M-h] 'backward-kill-word) ;M-H˳��ҲŪ��
(setq x-select-enable-clipboard t);; ֧��emacs���ⲿ�����ճ(ubuntu)
(icomplete-mode 1);; ��M-xִ��ĳ�������ʱ���������ͬʱ������ѡ����������ʾ
;; ������~��#�ļ�
(global-set-key [(meta f8)] 'indent-region)
(setq default-major-mode 'text-mode); Ĭ��textģʽ

(setq gdb-non-stop-setting nil)
(put 'narrow-to-region 'disabled nil) ; C-x n n��C-x n w��ֻ��������buffer

(fset 'yes-or-no-p 'y-or-n-p) ; ��yes/no�滻Ϊy/n
;; insert-date
(defun insert-date () ;
  "Insert date at point." ;
  (interactive) ;
  (insert (format-time-string "%Y��%m��%e�� %l:%M %a %p"))) ;

;; Alt;�����ע�ͣ��ܺ��ã������Ǽ�ǿ���Ĺ���:
;; û�м�������򣬾�ע��/��ע�͵�ǰ�У���������β��ʱ�������β��ע��
(defun qiang-comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command.
If no region is selected and current line is not blank and we are not at the end of the line,
then comment current line.
Replaces default behaviour of comment-dwim, when it inserts comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))
(global-set-key "\M-;" 'qiang-comment-dwim-line)
(defun comment-eclipse ()
  (interactive)
  (let ((start (line-beginning-position))
        (end (line-end-position)))
    (when (or (not transient-mark-mode) (region-active-p))
      (setq start (save-excursion
                    (goto-char (region-beginning))
;;                    (beginning-of-line)
                    (point))
            end (save-excursion
                  (goto-char (region-end))
;;                  (end-of-line)
                  (point))))
    (comment-or-uncomment-region start end)))
(global-set-key (kbd "C-c C-c") 'comment-eclipse)

(setq kill-do-not-save-duplicates t)
;; ÿ�ο�������������������滻ʱ������ɾ�����������а��������ݾ�û����
(when (string-equal system-type "windows-nt")
  (defadvice kill-region (before save-clip activate)
    (let* ((clip-str (w32-get-clipboard-data)))
      (and clip-str
	   (unless (equal (nth 0 kill-ring) clip-str)
	     (kill-new clip-str))))))

;; atl+w���Ƶ�ǰ��, atl+k���Ƶ���β��ԭ���ܲ����ðɣ�
;; Smart copy, if no region active, it simply copy the current whole line
(defadvice kill-line (before check-position activate)
  (if (member major-mode
	      '(emacs-lisp-mode scheme-mode lisp-mode
				c-mode c++-mode objc-mode js-mode
				latex-mode plain-tex-mode))
      (if (and (eolp) (not (bolp)))
	  (progn (forward-char 1)
		 (just-one-space 0)
		 (backward-char 1)))))

(defadvice kill-ring-save (around slick-copy activate)
  "When called interactively with no active region, copy a single line instead."
  (if (or (use-region-p) (not (called-interactively-p)))
      ad-do-it
    (kill-new (buffer-substring (line-beginning-position)
				(line-beginning-position 2))
	      nil)
    (message "Copied line")))

(defadvice kill-region (around slick-copy activate)
  "When called interactively with no active region, kill a single line instead."
  (if (or (use-region-p) (not (called-interactively-p)))
      ad-do-it
    (kill-new (filter-buffer-substring (line-beginning-position)
				       (line-beginning-position 2) t)
	      nil)))

;; Copy line from point to the end, exclude the line break
(defun qiang-copy-line (arg)
  "Copy lines (as many as prefix argument) in the kill ring"
  (interactive "p")
  (kill-ring-save (point)
		  (line-end-position))
  ;; (line-beginning-position (+ 1 arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s")))

;; (global-set-key (kbd "M-k") 'qiang-copy-line)

;; ����������Զ���ʽ��
(dolist (command '(yank yank-pop))
  (eval
   `(defadvice ,command (after indent-region activate)
      (and (not current-prefix-arg)
	   (member major-mode
		   '(emacs-lisp-mode
		     erlang-mode
		     lisp-mode
		     clojure-mode
		     scheme-mode
		     haskell-mode
		     ruby-mode
		     rspec-mode
		     python-mode
		     c-mode
		     c++-mode
		     objc-mode
		     latex-mode
		     js-mode
		     plain-tex-mode))
	   (let ((mark-even-if-inactive transient-mark-mode))
	     (indent-region (region-beginning) (region-end) nil))))))

(put 'downcase-region 'disabled nil);; ѡ������ C-X C-L 
(put 'upcase-region 'disabled nil);; ѡ������ C-X C-U

(global-set-key "%" 'match-paren)

;; ����ƥ����ת
(defun match-paren (arg)
  "Go to the matching paren if on a paren; otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
	((looking-at "\\s\)") (forward-char 1) (backward-list 1))
	(t (self-insert-command (or arg 1)))))

;; ��ʱ�Ǻ�, C-,��ǣ�C-.���ص���ǣ�����C-.���������л�
(global-set-key [(control ?\,)] 'ska-point-to-register)
(global-set-key [(control ?\.)] 'ska-jump-to-register)
(defun ska-point-to-register()
  "Store cursorposition _fast_ in a register. 
Use ska-jump-to-register to jump back to the stored 
position."
  (interactive)
  (setq zmacs-region-stays t)
  (point-to-register 8))

(defun ska-jump-to-register()
  "Switches between current cursorposition and position
that was stored with ska-point-to-register."
  (interactive)
  (setq zmacs-region-stays t)
  ;; ���û�мǺţ��͵���M-.�Ĺ���
  (if (get-register 8)
    (let ((tmp (point-marker)))
      (jump-to-register 8)
      (set-register 8 tmp))
    (setq unread-command-events (listify-key-sequence "\M-.")))
  )

;; C-t ���ñ�ǣ�ԭ����c-x t���棬��colemak��t��ʳָ̫���װ���
(global-set-key (kbd "C-q") 'set-mark-command)
(global-set-key (kbd "\C-xt") 'transpose-chars)

(put 'dired-find-alternate-file 'disabled nil)

;; windows�д򿪲�ѡ��buffer��Ӧ���ļ���C-X 6 ��2C mode��ǰ�
(when (string-equal system-type "windows-nt")
  (global-set-key (kbd "C-x C-d")
		(lambda () (interactive)
		  ;; (shell-command (format "explorer.exe /n,/select, \"%s\"" (replace-regexp-in-string "/" "\\\\" (buffer-file-name (current-buffer)))))
		  (require 'w32-browser)
		  (w32explore (buffer-file-name (current-buffer)))
		  )))

;; ʱ����÷���Time-stamp: <>����Time-stamp: " "��ֻ����µ�һ��ʱ���
(add-hook 'before-save-hook 'time-stamp)

(setq user-full-name "lynnux")
(setq user-mail-address "lynnux@qq.com")

;;;###autoload
(defun my-insert-char-next-line (arg)
  "insert char below the cursor"
  (interactive "p")
  (let ((col (current-column))
        char)
    (setq char
          (save-excursion
            (forward-line arg)
            (move-to-column col)
            (if (= (current-column) col)
                (char-after))))
    (if char
        (insert-char char 1)
      (message (concat "Can't get charactor in "
                       (if  (< arg 0)
                           "previous"
                         "next")
                       (progn (setq arg (abs arg))
                              (if (= arg 1) ""
                                (concat " " (number-to-string arg))))
                       " line.")))))

;;;###autoload
(defun my-insert-char-prev-line (arg)
  "insert char above the cursor"
  (interactive "p")
  (my-insert-char-next-line (- arg)))

(global-set-key (kbd "C-j") 'my-insert-char-prev-line) ;ԭ����C-I�ģ������Ӱ��TAB��
(global-set-key (kbd "C-S-j") 'my-insert-char-next-line) ;

(defun move-text-internal (arg)
  (cond
   ((and mark-active transient-mark-mode)
    (if (> (point) (mark))
        (exchange-point-and-mark))
    (let ((column (current-column))
          (text (delete-and-extract-region (point) (mark))))
      (forward-line arg)
      (move-to-column column t)
      (set-mark (point))
      (insert text)
      (exchange-point-and-mark)
      (setq deactivate-mark nil)))
   (t
    (let ((column (current-column)))
      (beginning-of-line)
      (when (or (> arg 0) (not (bobp)))
        (forward-line)
        (when (or (< arg 0) (not (eobp)))
          (transpose-lines arg)
          (when (and (eval-when-compile
                       '(and (>= emacs-major-version 24)
                             (>= emacs-minor-version 3)))
                     (< arg 0))
            (forward-line -1)))
        (forward-line -1))
      (move-to-column column t)))))

(defun move-text-down (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines down."
  (interactive "*p")
  (move-text-internal arg))

(defun move-text-up (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines up."
  (interactive "*p")
  (move-text-internal (- arg)))
(global-set-key (kbd "C-<up>") 'move-text-up)
(global-set-key (kbd "C-<down>") 'move-text-down)

;;; m-o�л�h/cpp�ļ�
(global-set-key (kbd "M-o") 'ff-find-other-file)
