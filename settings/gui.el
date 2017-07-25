;; Time-stamp: <2017-07-25 11:26:06 lynnux>
;; ������ص�

(custom-set-variables
 '(blink-cursor-mode nil)		;����Ƿ���˸
 '(column-number-mode t)		;״̬������ʾ�кź��к�
 '(line-number-mode t)
 '(display-time-mode t) 		;��ʾʱ��
 '(inhibit-startup-screen t)		;��ֹ��ʾ��������
 '(show-paren-mode t)			;()ƥ����ʾ
 '(tooltip-mode nil)			;windows�Ῠ������
 '(tool-bar-mode nil)          		;����ʾtoolbar
 )

(setq-default line-spacing 1)

;; (global-visual-line-mode 1); ���е��ǲ���ʾ�����ѿ���С����
(set-scroll-bar-mode 'right); ���������Ҳ�(ubuntu)

(setq scroll-step 1
      ;scroll-margin 3 ; ����е�СӰ��highlight-symbol-scroll-out
      scroll-conservatively 10000) ; ����ҳ��ʱ�Ƚ��������Ҫ��ҳ�Ĺ���
;; �����֣�Ĭ�ϵĹ���̫�죬�����Ϊ3��
(defun up-slightly () (interactive) (scroll-up 3))
(defun down-slightly () (interactive) (scroll-down 3))

(if (string-equal system-type "windows-nt")
    (progn				;windows���ѹ���ǰ����ûЧ��
      (global-set-key [wheel-up] 'down-slightly)
      (global-set-key [wheel-down] 'up-slightly) 
      )
  (progn				;linux
    (global-set-key [mouse-4] 'down-slightly)
    (global-set-key [mouse-5] 'up-slightly) 
    )
  )


;;���ڰ�������
(global-set-key (kbd "C-1") 'delete-other-windows) ; Alt-1 �ر���������
(global-set-key (kbd "M-1") 'other-window)
(defun volatile-kill-buffer ()
  "Kill current buffer unconditionally."
  (interactive)
  (let ((buffer-modified-p nil))
    (kill-buffer (current-buffer))))
(global-set-key (kbd "C-2") 'volatile-kill-buffer)
(global-set-key (kbd "C-4") 'copy-buffer-file-name-as-kill) ;/·��
(global-set-key (kbd "C-3") 'copy-buffer-file-name-as-kill-windows) ; \·��
(global-set-key "\M-r" 'replace-string)
(defun copy-buffer-file-name-as-kill(choice &optional name)
  "Copy the buffer-file-name to the kill-ring"
  (interactive "cCopy Buffer Name : [f]ull, [d]irectory, n[a]me?")
  (let ((new-kill-string)
        )
    (setq name (or name (if (eq major-mode 'dired-mode)
			    (dired-get-filename)
			  (or (buffer-file-name) ""))))
    (cond ((eq choice ?f)
           (setq new-kill-string name))
          ((eq choice ?d)
           (setq new-kill-string (file-name-directory name)))
          ((eq choice ?a)
           (setq new-kill-string (file-name-nondirectory name)))
          (t (message "Quit")))
    (when new-kill-string
      (message "%s copied" new-kill-string)
      (kill-new new-kill-string))))
(defun copy-buffer-file-name-as-kill-windows(choice)
  "Copy the buffer-file-name to the kill-ring"
  (interactive "cCopy Buffer Name : [f]ull, [d]irectory, n[a]me?")
  (let ((new-kill-string)
        (name (if (eq major-mode 'dired-mode)
                  (dired-get-filename)
                (or (buffer-file-name) ""))))
    (cond ((eq choice ?f)
           (setq new-kill-string name))
          ((eq choice ?d)
           (setq new-kill-string (file-name-directory name)))
          ((eq choice ?a)
           (setq new-kill-string (file-name-nondirectory name)))
          (t (message "Quit")))
    (when new-kill-string
      
      (let ((win-path (replace-regexp-in-string "/" "\\\\" new-kill-string)))
	(message "%s copied" win-path)
	(kill-new win-path))
      )))
;; (defun display-buffer-name ()
;;   (interactive)
;;   (message (buffer-file-name (current-buffer))))
;; (global-set-key (kbd "C-5") 'display-buffer-name);Alt-5 ��ʾbuffer�ļ���

(setq display-time-24hr-format t) ; 24Сʱ��ʽ
(setq display-time-day-and-date t) ; ��ʾ����
;(mouse-avoidance-mode 'animate) ; ����ƶ��������ʱ������Զ�����
;(setq frame-title-format "%f")		; ��ʾ��ǰ�༭���ĵ�
; toobar-ruler��Ϊ24.3��bug���޸ĵ���buffer���Ӵ���ʾ��
(setq frame-title-format '("%f" (:eval (if (buffer-modified-p) " *" ""))))

;; �������ã�����Consolas���壬�ܺÿ�����˵��msר�Ÿ�vs studio�õ�
(defun qiang-font-existsp (font)
  (if (null (x-list-fonts font))
      nil t))
(defun qiang-make-font-string (font-name font-size)
  (if (and (stringp font-size) 
	   (equal ":" (string (elt font-size 0))))
      (format "%s%s" font-name font-size)
    (format "%s %s" font-name font-size)))
(defun qiang-set-font (english-fonts
		       english-font-size
		       chinese-fonts
		       &optional chinese-font-size)
  "english-font-size could be set to \":pixelsize=18\" or a integer.
If set/leave chinese-font-size to nil, it will follow english-font-size"
  (require 'cl) ; for find if
  (let ((en-font (qiang-make-font-string
		  (find-if #'qiang-font-existsp english-fonts)
		  english-font-size))
	(zh-font (font-spec :family (find-if #'qiang-font-existsp chinese-fonts)
			    :size chinese-font-size)))

    ;; Set the default English font
    ;; 
    ;; The following 2 method cannot make the font settig work in new frames.
    ;; (set-default-font "Consolas:pixelsize=18")
    ;; (add-to-list 'default-frame-alist '(font . "Consolas:pixelsize=18"))
    ;; We have to use set-face-attribute
    (message "Set English Font to %s" en-font)
    (set-face-attribute
     'default nil :font en-font)

    ;; Set Chinese font 
    ;; Do not use 'unicode charset, it will cause the english font setting invalid
    (message "Set Chinese Font to %s" zh-font)
    (dolist (charset '(kana han symbol cjk-misc bopomofo))
      (set-fontset-font (frame-parameter nil 'font)
			charset
			zh-font))))

;; ��������,FixedsysҪ���������ģ�Ϊ�˱�֤org��table��ʾ�����������СӦ�����ó�һ���󣬲��������о����ִ���ˣ���Ҳ�ã�������Ӧ��
;;; 25����Fixedsys Excelsior 3.01-L�Ῠ����������Fixedsys(24������)�������������з��顣���������Ϊ��������-����Hxd�滻-Ϊ_������(ͬʱ�滻unicode)
(qiang-set-font
 '("Fixedsys Excelsior 3.01_L" "Consolas" "Source Code Pro" "Monaco" "DejaVu Sans Mono" "Monospace" "Courier New") ":pixelsize=16"
 '("WenQuanYi Bitmap Song" "����" "Microsoft Yahei" "��Ȫ��ȿ�΢�׺�" "����" "������" "����") 16)

;; �����������������ַ�ʱ�������������˵��`set-default-font'��֧��new frames���������ʱ���õ�
;(set-default-font "Consolas 11") ;; for Ӣ��     
;(set-fontset-font "fontset-default" 'unicode "΢���ź� 11") ;; for ����

;; ctrl+�����ֵ������ִ�С
(if (string-equal system-type "windows-nt")
    (progn 
      ;; For Windows
      (global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
      (global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease))
  (progn
    (global-set-key (kbd "<C-mouse-4>") 'text-scale-increase)
    (global-set-key (kbd "<C-mouse-5>") 'text-scale-decrease)
    ))

;; ������ɫ������theme�����ã�M-X list-colors-display ������ʾ�������ɫ
(set-face-background 'show-paren-match-face "slate blue")
;(set-face-foreground 'show-paren-match-face "gray15")

;; �����λ��������ʱ������ѡ�е�Ч��
(add-hook 'emacs-lisp-mode-hook (lambda ()
				  (make-local-variable 'show-paren-style)
				  (setq show-paren-style 'expression)
				  ;(face-remap-add-relative 'show-paren-match '((:background "black"))) ; elisp����һ����ɫ
				  ))

(setq time-stamp-format "%:y-%02m-%02d %02H:%02M:%02S lynnux")

;;; ������� 24.5ûЧ����
(when (and (>= emacs-major-version 25) (string-equal system-type "windows-nt"))
   (w32-send-sys-command 61488))
