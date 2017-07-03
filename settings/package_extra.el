;; Time-stamp: <2017-07-03 14:32:18 lynnux>
;; �ǹٷ��Դ�packages������

(add-to-list 'load-path
	     "~/.emacs.d/packages")

;;; global-linum-mode��Ȼ�����������ٶȣ���һֱ����Ϊ��emacs�����⣡
(require 'nlinum)
(setq nlinum-format "%4d") ; �е�̫��������4�ַ��պ���
(global-nlinum-mode)

;;; better C-A C-E
(autoload 'mwim-beginning-of-line-or-code "mwim" nil t)
(autoload 'mwim-end-of-line-or-code "mwim" nil t)
(global-set-key (kbd "C-a") 'mwim-beginning-of-line-or-code)
(global-set-key (kbd "C-e") 'mwim-end-of-line-or-code)

(require 'undo-tree)
(global-undo-tree-mode)
(setq undo-tree-visualizer-timestamps t)
(setq undo-tree-visualizer-diff t)
(define-key undo-tree-visualizer-mode-map (kbd "RET") 'undo-tree-visualizer-quit)
(setq undo-tree-auto-save-history t
      undo-tree-history-directory-alist `(("." . ,(expand-file-name "~/.emacs.d/undo/")))) ;; �������ˬ����
(global-set-key (kbd "C-z") 'undo-tree-undo)
(global-set-key (kbd "C-S-z") 'undo-tree-redo)

(defun yas ()
  (interactive)
  (add-to-list 'load-path "~/.emacs.d/packages/yasnippet")
  (require 'yasnippet)
  (setq yas-snippet-dirs
	'("~/.emacs.d/packages/yasnippet/yasnippet-snippets-master"
	  "~/.emacs.d/packages/yasnippet/mysnippets" ;; personal snippets
	  ))
  (yas-global-mode 1))
(yas)

(require 'session)
(add-hook 'after-init-hook 'session-initialize)
(setq session-globals-include '((kill-ring 50)
				(session-file-alist 100 t)
				(file-name-history 200)))

;; tabbar, use tabbar-ruler
(add-to-list 'load-path "~/.emacs.d/packages/tabbar") 
(global-set-key (kbd "<C-M-tab>") 'tabbar-backward-group)
(global-set-key (kbd "<C-M-S-tab>") 'tabbar-forward-group)

(global-set-key (kbd "<C-tab>") ;'tabbar-forward-tab
		'my-switch-buffer
		)

(global-set-key (if (string-equal system-type "windows-nt")
		    (kbd "<C-S-tab>")
		  (kbd "<C-S-iso-lefttab>")) ;'tabbar-backward-tab
		(lambda () 
		  (interactive)
		  (my-switch-buffer t))
		)

(defun my-switch-buffer (&optional backward)
  "Switch buffers, but don't record the change until the last one."
  (interactive)
  (save-excursion ; when C-g don't work
    (let* ((blist (copy-sequence (if (featurep 'tabbar-ruler) 
				     (ep-tabbar-buffer-list)
				   (buffer-list))
				 ))
	   (init-buffer (car blist))
	   current
	   (key-forward (kbd "<C-tab>"))
	   (key-backward (if (string-equal system-type "windows-nt")
			     (kbd "<C-S-tab>")
			   (kbd "<C-S-iso-lefttab>")))
	   done
	   (key-stroked (if backward
			    key-backward
			  key-forward))
	   key-previous)
      (setq key-previous key-stroked)
      (if backward
	  (setq blist (nreverse blist))
	(setq blist (append (cdr blist) (list (car blist)))))
      (while (not done)
	(setq current (car blist))
	(setq blist (append (cdr blist) (list current)))
	(switch-to-buffer current t)	; �ڶ���������������¼
	(when (featurep 'cursor-chg)
	  (curchg-change-cursor-on-overwrite/read-only)) ; ����cursor�����ʾ
	(message "C-tab to cycle forward, C-S-tab backward...")
	(setq key-stroked (make-vector 1 (read-event)))
	(unless (equal key-previous key-stroked)
	  (setq blist (nreverse blist))
	  (setq blist (append (cdr blist) (list (car blist)))))
	(setq key-previous key-stroked)
	(cond ((equal key-forward key-stroked)
	       t)
	      ((equal key-backward key-stroked)
	       t)
	      ((equal (kbd "<C-g>") key-stroked) ; don't work
	       (switch-to-buffer init-buffer t))
	      (t 
	       (setq done t)
	       (switch-to-buffer current)
	       (clear-this-command-keys t)
	       (setq unread-command-events (list last-input-event))))
	)
      ;; (when (= last-input-event ?\C-g) ; don't work ������warning
      ;; 	(switch-to-buffer init-buffer t))
      )))

;;org��C-tab�����ϲ���
(add-hook 'org-mode-hook (lambda()
			   (define-key org-mode-map (kbd "<C-tab>") 'my-switch-buffer)))
(setq EmacsPortable-global-tabbar 't)
(require 'tabbar-ruler)
(setq EmacsPortable-excluded-buffers '("*Messages*" "*Completions*" "*ESS*" "*Compile-Log*" "*Ibuffer*" "*SPEEDBAR*" "*etags tmp*" "*reg group-leader*" "*Pymacs*" "*grep*"))
(setq EmacsPortable-included-buffers '("*scratch*" "*shell*"))

(require 'highlight-symbol)
;zenburn
(set-face-background 'highlight-symbol-face "SteelBlue4") ; SteelBlue4
; (set-face-foreground 'highlight-symbol-face "yellow")
;atom-one-dark
; (set-face-background 'highlight-symbol-face "black")
;normal
; (set-face-background 'highlight-symbol-face "yellow")
(setq highlight-symbol-idle-delay 0.1)
(global-set-key [(control f3)] 'highlight-symbol-at-point)
(global-set-key [f3] 'highlight-symbol-next)
(global-set-key [(shift f3)] 'highlight-symbol-prev)
(global-set-key [(meta f3)] 'highlight-symbol-query-replace)
;; (highlight-symbol-mode 1)
;; ����ȫ��mode
(defun highlight-symbol-mode-on ()
  (unless  (or 
	    ;; �ų���mode���ڴ˼�
	    (eq major-mode 'occur-mode)
	    (eq major-mode 'occur-edit-mode)
	    (eq major-mode 'erc-mode)
	    )
    (highlight-symbol-mode)) 
  )
(define-globalized-minor-mode global-highlight-symbol-mode highlight-symbol-mode highlight-symbol-mode-on)
(global-highlight-symbol-mode 1)
(require 'highlight-symbol-scroll-out)
(global-highlight-symbol-scroll-out-mode)

(require 'cursor-chg)
(change-cursor-mode )
(setq curchg-default-cursor-color "red3") ; �޷�����cursor��foreground

;;crosshairs�����ã�ֻҪvline������		
(autoload 'vline-mode "vline" nil t)
(global-set-key [(control ?|)] 'vline-mode)

;(global-hl-line-mode t)

(add-to-list 'load-path "~/.emacs.d/packages/auto-complete")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/packages/auto-complete/mydict")
(ac-config-default)
(setq-default ac-sources '(ac-source-semantic
			   ac-source-yasnippet
			   ac-source-abbrev
			   ac-source-dictionary 
			   ac-source-words-in-buffer
			   ac-source-words-in-all-buffer
			   ac-source-imenu
			   ac-source-files-in-current-dir
			   ac-source-filename))
(add-hook 
 'auto-complete-mode-hook 
 (lambda() 
   (define-key ac-completing-map "\C-n" 'ac-next)
   (define-key ac-completing-map "\C-p" 'ac-previous)
   ))
(global-set-key (kbd "<C-return>") 'auto-complete)

;; һ���ͼ���modeȷʵͦ��ˬ�ģ������������
(require 'wcy-desktop)
(wcy-desktop-init)
(add-hook 'emacs-startup-hook
          (lambda ()
            (ignore-errors
              (wcy-desktop-open-last-opened-files))))

;; clang-format
(autoload 'clang-format-region "clang-format" "" t)
(autoload 'clang-format-buffer "clang-format" "" t)
(defun clang-format-auto ()
  (interactive)
  (if (or (not transient-mark-mode) (region-active-p))
      (call-interactively 'clang-format-region)
    (call-interactively 'clang-format-buffer)))

(add-hook 'c-mode-common-hook 'lynnux-c-mode-hook)
(add-hook 'c++-mode-hook 'lynnux-c++-mode-hook)

(defun lynnux-c-mode-hook ()
  (setq tab-width 4 indent-tabs-mode nil)
  (setq c-hungry-delete-key t)		; 
  (setq c-auto-newline 1)
  (c-set-style "stroustrup")
  (setq cscope-do-not-update-database t)
  (setq cscope-program "gtags-cscope")
  (gtags-settings)
  (define-key c-mode-base-map (kbd "C-h") 'c-electric-backspace) ;�޸�C-hû�����Ч��
  (local-set-key (kbd "C-c C-c") 'comment-eclipse)
  (setq clang-format-style "webkit") ; ֻ�����Ĭ��tab��4���ո�
  (local-set-key [(meta f8)] 'clang-format-auto)
)

(defun lynnux-c++-mode-hook()
  ;;c++ types
  (font-lock-add-keywords 'c++-mode '(("\\<\\(static_assert\\|assert\\|ensure\\)\\>"
				       . font-lock-warning-face)))
  (font-lock-add-keywords 'c++-mode '(("\\pure\\>"
				       . font-lock-keyword-face)))
  (font-lock-add-keywords 'c++-mode '(("\\<u?\\(byte\\|short\\|int\\|long\\)\\>"	
				       . font-lock-type-face)))
  (font-lock-add-keywords 'c++-mode '(("\\<c?\\(float\\|double\\)\\>"	
				       . font-lock-type-face)))
  (font-lock-add-keywords 'c++-mode '(("\\<u?int\\(8\\|16\\|32\\)\\(_t\\)?\\>"
				       . font-lock-type-face)))
  (font-lock-add-keywords 'c++-mode '(("\\<s?size_t\\>"
				       . 'font-lock-type-face)))
  )

(autoload 'nsis-mode "nsis-mode" "NSIS mode" t)
(setq auto-mode-alist (append '(("\\.\\([Nn][Ss][Ii]\\)$" .
                                 nsis-mode)) auto-mode-alist))
(setq auto-mode-alist (append '(("\\.\\([Nn][Ss][Hh]\\)$" .
                                 nsis-mode)) auto-mode-alist))

(autoload 'protobuf-mode "protobuf-mode" "protobuf mode" t)
(setq auto-mode-alist (append '(("\\.proto\\'" .
				 protobuf-mode)) auto-mode-alist))

(eval-after-load "calendar" 
  '(progn
     (require 'cal-china-x)
     (setq mark-holidays-in-calendar t)
     (setq cal-china-x-priority1-holidays cal-china-x-chinese-holidays)
     (setq calendar-holidays cal-china-x-priority1-holidays))) 

(global-set-key (kbd "<f4>") 'next-error)
(global-set-key (kbd "S-<f4>") 'previous-error)

(require 'jumplist)
(global-set-key (kbd "M-n") 'jl-jump-forward)
(global-set-key (kbd "M-p") 'jl-jump-backward)
(add-to-list 'jl-insert-marker-funcs "my-switch-buffer")
(add-to-list 'jl-insert-marker-funcs "ggtags-find-tag-dwim")
(add-to-list 'jl-insert-marker-funcs "ggtags-find-reference")
(add-to-list 'jl-insert-marker-funcs "ggtags-find-file")

(autoload 'iss-mode "iss-mode" "Innosetup Script Mode" t)
(setq auto-mode-alist (append '(("\\.iss$"  . iss-mode)) auto-mode-alist))
(setq iss-compiler-path "D:/Programme/Inno Setup 5/")
(add-hook 'iss-mode-hook 'xsteve-iss-mode-init)
(defun xsteve-iss-mode-init ()
  (interactive)
  (define-key iss-mode-map [f6] 'iss-compile)
  (define-key iss-mode-map [(meta f6)] 'iss-run-installer))

;; (add-hook 'dired-mode-hook (lambda () (require 'w32-browser)))
(eval-after-load "dired"
  '(progn
     (unless (string-equal system-type "windows-nt")
       (require 'w32-browser)
       (define-key dired-mode-map [f3] 'dired-w32-browser)
       (define-key dired-mode-map (kbd "<C-return>") 'dired-w32-browser)
       (define-key dired-mode-map [f4] 'dired-w32explore)
       (define-key dired-mode-map [menu-bar immediate dired-w32-browser]
	 '("Open Associated Application" . dired-w32-browser))
       ;; (define-key diredp-menu-bar-immediate-menu [dired-w32explore]
       ;;   '("Windows Explorer" . dired-w32explore))
       (define-key dired-mode-map [mouse-2] 'dired-mouse-w32-browser)
       (define-key dired-mode-map [menu-bar immediate dired-w32-browser]
	 '("Open Associated Applications" . dired-multiple-w32-browser)))))

(autoload 'cmake-mode "cmake-mode" "cmake-mode" t)
(setq auto-mode-alist
      (append '(("CMakeLists\\.txt\\'" . cmake-mode)
		("\\.cmake\\'" . cmake-mode))
	      auto-mode-alist))

;; paredit
;; (autoload 'paredit-mode "paredit"
;;   "Minor mode for pseudo-structurally editing Lisp code." t)
;; (eval-after-load "paredit" '(progn
;; 			      (require 'eldoc)
;; 			      (eldoc-add-command
;; 			       'paredit-backward-delete
;; 			       'paredit-close-round)
;; 			      (define-key paredit-mode-map (kbd "C-h") 'paredit-backward-delete)
;; 			      (define-key paredit-mode-map (kbd "M-h") 'paredit-backward-kill-word)
;; 			      ))
;; (electric-pair-mode) ; replace autopair

(defun my-elisp-hook()
  (defvar electrify-return-match
    "[\]}\)\"]"
    "If this regexp matches the text after the cursor, do an \"electric\"
  return.")
					; �⹦�ܲ�֪����ʲô�ã���΢�޸��û���ʱ�Զ�indent
  (defun electrify-return-if-match (arg)
    "If the text after the cursor matches `electrify-return-match' then
  open and indent an empty line between the cursor and the text.  Move the
  cursor to the new line."
    (interactive "P")
    (let ((case-fold-search nil))
      (if (looking-at electrify-return-match)
	  (save-excursion  ;(newline-and-indent) ; ֻ��Ҫindent
	    (indent-according-to-mode)))
      (newline arg)
      (indent-according-to-mode)))
  (find-function-setup-keys)  ;ֱ�Ӷ�λ������������λ�õĿ�ݼ���C-x F/K/V��ע���Ǵ�д��
;  (paredit-mode t) ; ϰ�߷ǳ�����
  (setq eldoc-idle-delay 0)
  (turn-on-eldoc-mode)
;  (local-set-key (kbd "RET") 'electrify-return-if-match)
  (eldoc-add-command 'electrify-return-if-match)
  (show-paren-mode t)
  (local-set-key (kbd "<f12>") 'xref-find-definitions)
  (local-set-key (kbd "M-.") 'xref-find-definitions) ; �������ԭ���ĺ���
  (local-set-key (kbd "<C-down-mouse-1>") 'xref-find-definitions)
  )
(add-hook 'emacs-lisp-mode-hook 'my-elisp-hook)
(add-hook 'lisp-interaction-mode-hook 'my-elisp-hook)
(add-hook 'ielm-mode-hook 'my-elisp-hook)

;;; gtags
(defun gtags-settings()
  ;;; gtags �Զ����µ��ļ�����ʱ
  (defun gtags-root-dir ()
    "Returns GTAGS root directory or nil if doesn't exist."
    (with-temp-buffer
      (if (zerop (call-process "global" nil t nil "-pr"))
	  (buffer-substring (point-min) (1- (point-max)))
	nil)))
  (defun gtags-update ()
    "Make GTAGS incremental update"
    (call-process "global" nil nil nil "-u"))
  (defun gtags-update-hook ()
    (when (gtags-root-dir)		;û�ж���ĸ�����
      (gtags-update)))
  (add-hook 'after-save-hook #'gtags-update-hook)
  (require 'ggtags)
  (ggtags-mode 1)
  (add-hook 'ggtags-global-mode-hook (lambda()
				       (define-key ggtags-global-mode-map "n" 'next-line)
				       (define-key ggtags-global-mode-map "p" 'previous-line)
				       ))
  (setq ggtags-global-abbreviate-filename nil) ; ����д·��
  (defadvice ggtags-eldoc-function (around my-ggtags-eldoc-function activate)); eldocû�п��أ�ֻ����д���ĺ�����
;  (customize-set-variable 'ggtags-highlight-tag nil) ; ��ֹ�»��� setq��defcustom��Ч�� ������eldoc������ʾprocess sentinel��
  (local-set-key (kbd "<C-down-mouse-1>") 'ggtags-find-tag-dwim) ; CTRL + ��������ܺ���
  (local-set-key (kbd "<f12>") 'ggtags-find-tag-dwim)
  (local-set-key (kbd "<C-wheel-up>") 'previous-error)
  (local-set-key (kbd "<C-wheel-down>") 'next-error)
  ;(turn-on-eldoc-mode) ; �Ῠ
  )

;; erlang����, ��Ҫ��������http://jixiuf.github.com/erlang/distel.html��
;; https://raw.github.com/jixiuf/emacs_conf/master/site-lisp/joseph/joseph-erlang.el
(add-to-list 'ac-modes 'erlang-mode)
(eval-after-load "erlang" 
  '(progn
     ;; (setq inferior-erlang-machine-options `("-name" ,(concat "emacs@" system-name "")  "+P" "102400")       )
     (require 'erlang-flymake)
     (defun erlang-flymake-get-app-dir() ;���¶���erlang-flymake�еĴ˺���,find out app-root dir
       ;; ��ʱ,�������� src/deep/dir/of/source/�����Ƚ����Ŀ¼,erlang-flymake�Դ��Ĵ˺���
       ;; �޷������������
       (let ((erlang-root (locate-dominating-file default-directory "Emakefile")))
	 (if erlang-root
	     (expand-file-name erlang-root)
	   (setq erlang-root (locate-dominating-file default-directory "rebar"))
	   (if erlang-root
	       (expand-file-name erlang-root)
	     (file-name-directory (directory-file-name
				   (file-name-directory (buffer-file-name)))))
	   )))
     (defun my-erlang-flymake-get-include-dirs-function()
       (let* ((app-root (erlang-flymake-get-app-dir))
	      (dir (list (concat app-root "include") ;��֧��ͨ���,
			 (concat  app-root "src/include")
			 (concat  app-root "deps")))
	      (deps (concat  app-root "deps")))
	 (when (file-directory-p deps)
	   (dolist (subdir (directory-files deps))
	     (when (and (file-directory-p (expand-file-name subdir deps))
			(not (string= "." subdir))
			(not (string= ".." subdir)))
	       (add-to-list 'dir (expand-file-name (concat subdir "/include" ) deps))
	       )))
	 dir))
     (setq erlang-flymake-get-include-dirs-function 'my-erlang-flymake-get-include-dirs-function)

     ;;���û�취,���ܵ���������,ֻ�ܿ���ϵͳhome�µ�.erlang.cookie��emacs��homeĿ¼��
     ;; (setq derl-cookie "when_home_not_equal")
     (require 'distel)
     (distel-setup)
     ))

;;;; ����erl  �ļ�ʱ���Զ�����һ��shell �Ա�distel���в�ȫ
(add-hook 'erlang-mode-hook 
	  '(lambda () (unless erl-nodename-cache (distel-load-shell))
	     ;(local-set-key [(control ?\.)] 'erl-find-source-under-point)
	     (local-set-key (kbd "<f12>") 'erl-find-source-under-point)
	     (local-set-key (kbd "M-.") 'etags-select-find-tag-at-point) ; when distel does't work
	     (local-set-key (kbd "C-'")  'erl-complete)
	     ))

(defun distel-load-shell ()
  "Load/reload the erlang shell connection to a distel node"
  (interactive)
  ;; Set default distel node name
  (setq erl-nodename-cache (intern (concat "emacs@" system-name "")))
  ;; (setq derl-cookie (read-home-erlang-cookie)) ;;new added can work
  (setq distel-modeline-node "distel")
  (force-mode-line-update)
  ;; Start up an inferior erlang with node name `distel'
  (let ((file-buffer (current-buffer))
        (file-window (selected-window)))
    ;; (setq inferior-erlang-machine-options '("-sname" "emacs@localhost" "-setcookie" "cookie_for_distel"))
    (setq inferior-erlang-machine-options `("-name" ,(concat "emacs@" system-name "") )) ;; erl -name emacs
    (switch-to-buffer-other-window file-buffer)
    (inferior-erlang)
    (select-window file-window)
    (switch-to-buffer file-buffer)
    (delete-other-windows)))

;; ruby mode
(add-hook 'ruby-mode-hook '(lambda()
			     (require 'rcodetools)
			     (setq ac-omni-completion-sources
				   (list (cons "//." '(ac-source-rcodetools))
					 (cons "::" '(ac-source-rcodetools))))
			     (setq ac-sources (append (list 'ac-source-rcodetools) ac-sources))
			     ))

;; popup yank-pop
(autoload 'popup-kill-ring "popup-kill-ring" nil t)
(global-set-key "\M-y" 'popup-kill-ring)
(global-set-key (kbd "C-`") 'popup-kill-ring)
(eval-after-load "popup-kill-ring" 
  '(progn
     (define-key popup-kill-ring-keymap "\M-n" 'popup-kill-ring-next)
     (define-key popup-kill-ring-keymap (kbd "C-`") 'popup-kill-ring-next)
     (define-key popup-kill-ring-keymap "\M-p" 'popup-kill-ring-previous)
     (setq 
      popup-kill-ring-interactive-insert t
      popup-kill-ring-item-min-width nil
      popup-kill-ring-item-size-max 26
      popup-kill-ring-popup-margin-left 1 
      popup-kill-ring-popup-margin-right 0)     
					;     (define-key popup-kill-ring-keymap "\M-y" 'popup-kill-ring-next)
					; �����ѡ�У���ɾ��ѡ�У��迪��delete-selecton-mode
     (put 'popup-kill-ring 'delete-selection 'yank)
     ))

;; python
;; (add-hook 'python-mode-hook '(lambda()
;; 			       (require 'pymacs)
;; 			       (pymacs-load "ropemacs" "rope-")
;; 			       (ropemacs-mode)
;; 			       (setq ropemacs-enable-autoimport t)
;; ))

(add-to-list 'load-path "~/.emacs.d/packages/jedi")
(autoload 'jedi:ac-setup "jedi" nil t)
(add-hook 'python-mode-hook '(lambda ()
			       (jedi:ac-setup)
			       (local-set-key (kbd "<C-return>") 'jedi:complete)))
;; (setq jedi:server-command
;;       (list "D:\\Python27\\Python.exe" jedi:server-script))

;; gnu global

(setq minibuffer-complete-cycle t)
(require 'minibuffer-complete-cycle) ;; modified for Emacs24
(custom-set-faces
 '(minibuffer-complete-cycle ((t (:background "blue" :foreground "snow")))))

;;; slime + sbcl����װ���ü�~/.emacs.d/packages���˵��
(when (file-exists-p "~/.emacs.d/packages/slime") ; ��װ���ٽ�����һ��
  (add-to-list 'load-path "~/.emacs.d/packages/slime")
  (autoload 'slime "slime-autoloads" nil t)
  (eval-after-load "slime-autoloads" '(progn
					(slime-setup '(slime-fancy))
					))
  )

;; ctags
(setq ctags-program "ctags")
(when (string-equal system-type "windows-nt")
  (progn
    (setq ctags-program (concat "\"" (file-truename "~/.emacs.d/bin/ctags.exe") "\""))
    ))

(defun create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (shell-command
   ;; (message
   (format "%s -f %s -e -R %s" ctags-program 
	   (concat "\"" (expand-file-name "TAGS" dir-name) "\"") ;Ŀ¼���пո�Ļ�
	   (concat "\"" (expand-file-name "." dir-name) "\"")
	   )))

;; stl�ļ����޺�ꡣ���vc��˵ֻ��vcinstalldir/include���Ŀ¼
(defun create-tags-cppstl (dir-name)
  "Create stl tags file."
  (interactive "DDirectory: ")
  (shell-command
   ;; (message
   (format "%s --c++-kinds=+p --fields=+iaS --extra=+q --language-force=c++ -f %s -e -R %s" ctags-program 
	   (concat "\"" (expand-file-name "TAGS" dir-name) "\"") ;Ŀ¼���пո�Ļ�
	   (concat "\"" (expand-file-name "." dir-name) "\"")
	   )))
;;; ��ǿM-.
(setq etags-table-search-up-depth 10) ;; �Զ���Ŀ¼�ϲ���TAGS�Ĳ����
(autoload 'etags-select-find-tag-at-point "etags-select" nil t)
(autoload 'etags-select-find-tag "etags-select" nil t)
(global-set-key (kbd "<f12>") 'etags-select-find-tag-at-point)
(global-set-key (kbd "M-.") 'etags-select-find-tag-at-point) ; ����elisp��ggtags֧�ֵĶ������
(global-set-key (kbd "<C-down-mouse-1>") 'etags-select-find-tag-at-point)

(eval-after-load "etags-select" '
  (progn 
    (require 'etags-table)
    (require 'etags-stack)))

;; lcEngine
;; (add-hook 'c-mode-common-hook
;; 	  (lambda ()
;; 	    (require 'lcEngine)
;; 	    (local-set-key (kbd "<C-return>") 'ac-complete-lcEngine) ;; ��ȫ
;; 	    (local-set-key (kbd "<f12>") 'lcEngine-goto-definition) ;; ��ת������
;; 	    (local-set-key (kbd "<C-f4>") 'lcEngine-syntax-check) ;; ������
	    
;; 	    (ac-lcEngine-setup) ; �о�������̫���ˣ���ȫ����flymakeҲ��
;; 	    ; �������İ���
;; 	    (setq flymake-no-changes-timeout 1.0)
;; 	    (local-set-key (kbd "<f4>") 
;; 			   (lambda ()
;; 			     (interactive)
;; 			     (flymake-goto-next-error)
;; 			     (let ((err (get-char-property (point) 'help-echo)))
;; 			       (when err
;; 				 (message err)))))
;; 	    (local-set-key [(shift f4)]
;; 			   (lambda ()
;; 			     (interactive)
;; 			     (flymake-goto-prev-error)
;; 			     (let ((err (get-char-property (point) 'help-echo)))
;; 			       (when err
;; 				 (message err)))))
;; 	    ))

;; everything, awesome! ��������·���е����⣬������
(when (string-equal system-type "windows-nt")
  (setq everything-use-ftp t)
  (defun everything-ffap-guesser-wrapper (file)
    (require 'everything)
    (everything-ffap-guesser file)
    )
  (eval-after-load "ffap" '(setf (cdr (last ffap-alist)) '(("\\.*\\'" . everything-ffap-guesser-wrapper)))) ; when C-x f can't find anything, try everything
  (autoload 'everything "everything" nil t)
  ;; �����ͽ�����������ˣ�������������,emacs is awesome! �����ǻ�����`process-coding-system-alist'���ļ�����`file-coding-system-alist'
  (eval-after-load "everything" '(add-to-list 'network-coding-system-alist
					      '(21 . (utf-8 . utf-8))
					      )); Ĭ��21�˿�
  )

;;; shell, main goal is for compile test
(defun smart-compile-run ()
  (interactive)
  (if (equal (buffer-name) "*shell*")
      (switch-to-prev-buffer)
    ;; (let ((run-exe (concat (file-name-sans-extension
    ;; 		     (file-name-nondirectory (buffer-file-name))) ".exe"))))
    (with-current-buffer (shell)
      (end-of-buffer)
      (move-end-of-line nil)
      ;(move-beginning-of-line nil)
      ;(kill-line 1)
      ;(insert-string run-exe)
      ;(move-end-of-line nil)
       )))
(global-set-key (kbd "<f5>") 'smart-compile-run)

;;; TODO ������������Ŀ¼����һ��Ŀ¼C-F7ʱ��ǰĿ¼û�б䣬����C-u F7��������
;; compile�������˵�������ĳ���ļ�
(setq compilation-auto-jump-to-first-error t compilation-scroll-output t)
(autoload 'smart-compile "smart-compile" nil t)
(autoload 'smart-compile-c-compile "smart-compile" nil t)
(global-set-key [f7] 'smart-compile)
(global-set-key [(shift f7)] 'smart-compile-regenerate)
(global-set-key [(control f7)] 'smart-compile-c-compile)
(defun smart-compile-regenerate()
  (interactive)
  (smart-compile 4))
(defun notify-compilation-result(buffer msg)
  "Notify that the compilation is finished,
close the *compilation* buffer if the compilation is successful,
and set the focus back to Emacs frame"
  (when (equal (buffer-name) "*compilation*") 
    (when (string-match "^finished" msg)
	(progn
	  (delete-windows-on buffer)
	  ;; (tooltip-show "\n Compilation Successful :-) \n ")
	  )
      ;; (tooltip-show "\n Compilation Failed :-( \n ")
      )
    (setq current-frame (car (car (cdr (current-frame-configuration)))))
    (select-frame-set-input-focus current-frame)
    ))
(eval-after-load "compile" '(add-to-list 'compilation-finish-functions
					 'notify-compilation-result))

;; (add-to-list 'load-path "~/.emacs.d/packages/helm")
;; (require 'helm-config)
					;(global-set-key (kbd "C-c h") 'helm-mini)
					;(helm-mode 1)

(add-to-list 'load-path "~/.emacs.d/packages/expand-region")
(autoload 'er/expand-region "expand-region" nil t)
(global-set-key "\C-t" 'er/expand-region)
;;; �����(setq show-paren-style 'expression)���ǵ�����
(defadvice show-paren-function (around not-show-when-expand-region activate)
  (if (and (or (eq major-mode 'lisp-interaction-mode) (eq major-mode 'emacs-lisp-mode))
	   (memq last-command '(er/expand-region er/contract-region)))
      (progn
	(setq show-paren-style 'parenthesis)
	ad-do-it
	(setq show-paren-style 'expression)
	)
    ad-do-it))

(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))

;; markdown
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;;; ����sublime�Ķ��깦��(��M��������visual code)
(setq mc/list-file "~/.emacs.d/packages/multiple-cursors/my-cmds.el")
(add-to-list 'load-path
	     "~/.emacs.d/packages/multiple-cursors")
(autoload 'mc/add-cursor-on-click "multiple-cursors" nil t)
(autoload 'mc/unmark-next-like-this "multiple-cursors" nil t)
(autoload 'mc/unmark-previous-like-this "multiple-cursors" nil t)
(autoload 'mc/mark-previous-like-this "multiple-cursors" nil t)
(autoload 'mc/mark-next-like-this "multiple-cursors" nil t)
(autoload 'mc/edit-lines "multiple-cursors" nil t)
(global-unset-key (kbd "M-<down-mouse-1>"))  ; CTRL + ��굥����ggtag����
(global-set-key (kbd "M-<mouse-1>") 'mc/add-cursor-on-click)
(global-set-key (kbd "C-M-<mouse-1>") 'mc/unmark-next-like-this) ; ȡ��������µ�mark
(global-set-key (kbd "M-S-<mouse-1>") 'mc/unmark-previous-like-this) ;ȡ��������ϵ�mark
(global-set-key (kbd "M-<wheel-up>") 'mc/mark-previous-like-this)
(global-set-key (kbd "M-<wheel-down>") 'mc/mark-next-like-this)
(global-set-key (kbd "C-S-t") 'mc/edit-lines)  ;��Ȼ��֧��ͬ�е�range
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;;; ��Ļ�ڿ���������Ĭ����������ĸ��ͷ�ĵ���λ�ã�C-u C-j��Ϊ����ԭ����λ�ã�C-u C-u C-j��������
(autoload  'ace-jump-mode  "ace-jump-mode"  "Emacs quick move minor mode"  t)
(define-key global-map (kbd "C-o") 'ace-jump-mode)
(eval-after-load 'ace-jump-mode '(setq ace-jump-mode-submode-list
				  '(ace-jump-word-mode
				    ace-jump-mode-pop-mark
				    ace-jump-char-mode
				    ace-jump-line-mode)))

;;; autohotkey�ļ��༭
(autoload 'xahk-mode "xahk-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.ahk\\'" . xahk-mode))

;;; rust mode
(add-to-list 'load-path "~/.emacs.d/packages/rust")
(autoload 'rust-mode "rust-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
;;; racer��ȫ
(autoload 'racer-mode "racer" nil t)
(add-hook 'rust-mode-hook #'racer-mode)
(add-hook 'racer-mode-hook #'eldoc-mode)
(defun my/racer-mode-hook ()
  (require 'ac-racer)
  (ac-racer-setup)
  (make-local-variable 'ac-auto-start) ; �Զ������Ῠ
  (setq ac-auto-start nil)
  (when (featurep 'smartparens-rust)
      ;; ���������smartparens-rust����ȻûЧ������ʵ��Ҫsmartparens-rust�ͺ���
    (eval-after-load 'smartparens-rust
      '(progn
	(sp-local-pair 'rust-mode "'" nil :actions nil)
	(sp-local-pair 'rust-mode "<" nil :actions nil) ;  ��4��������д">"Ҳ����
	))))
(add-hook 'racer-mode-hook 'my/racer-mode-hook)
(setq racer-cmd "racer") ;; �Լ����racer��PATH��������
;;; (setq racer-rust-src-path "") �Լ�����RUST_SRC_PATH��������ָ��rustԴ���srcĿ¼

(add-to-list 'load-path "~/.emacs.d/packages/neotree")
(autoload 'neotree-toggle "neotree" nil t)
(global-set-key (kbd "<C-f1>") 'neotree-toggle)
(global-set-key (kbd "C-x d") 'neotree-toggle) ; dired��������
(setq neo-window-width 32
      neo-create-file-auto-open t
      neo-show-updir-line t
      neo-mode-line-type 'neotree
      neo-smart-open t
      neo-show-hidden-files t
      neo-auto-indent-point t
      neo-vc-integration nil)

;; �е������Զ��ضγ��е�Ч����Ĭ�ϰ󶨵�m-q��elisp-mode��Ч
(autoload 'unfill-toggle "unfill" nil t)
(global-set-key [remap fill-paragraph] #'unfill-toggle)

(require 'hungry-delete)
(global-hungry-delete-mode)
(setq-default hungry-delete-chars-to-skip " \t\f\v") ; only horizontal whitespace

(add-to-list 'load-path "~/.emacs.d/packages/smartparens")
(require 'smartparens-config)
(sp-use-paredit-bindings)
;; ����paredit��M-(������ģʽ����pair��ֹ(���Բ�����
(sp-local-pair '(emacs-lisp-mode lisp-interaction-mode) "(" nil :bind "M-(") ; �����ʵ�ǰ�װ��sp-wrap��
(set-default 'sp-autoskip-closing-pair 'always)
;; Don't kill the entire symbol on C-k
(set-default 'sp-hybrid-kill-entire-symbol nil)
(smartparens-global-strict-mode)
(show-smartparens-global-mode) ;; Show parenthesis

(with-eval-after-load 'smartparens
  (dolist (key '( [remap delete-char]
                  [remap delete-forward-char]))
    (define-key smartparens-strict-mode-map key
      ;; menu-item��һ��symbol�����Һ���Ȥ���ǣ�F1-K��ʵʱ֪���ǵ����ĸ�����
      '(menu-item "maybe-sp-delete-char" nil
                  :filter (lambda (&optional _)
                            (unless (looking-at-p "[[:space:]\n]")
                              #'sp-delete-char)))))

  (dolist (key '([remap backward-delete-char-untabify]
                 [remap backward-delete-char]
                 [remap delete-backward-char]))
    (define-key smartparens-strict-mode-map key
      '(menu-item "maybe-sp-backward-delete-char" nil
                  :filter (lambda (&optional _)
                            (unless (looking-back "[[:space:]\n]" 1)
                              #'sp-backward-delete-char)))))
  
  ;; C-W֧��
  (dolist (key '( [remap kill-region]))
    (define-key smartparens-strict-mode-map key
      '(menu-item "maybe-sp-kill-region" nil
                  :filter (lambda (&optional _)
                            (when (use-region-p) ;; ��ѡ��ʱ����sp��
                              #'sp-kill-region)))))
  )


;; !themesҪ�ŵ��������theme�鿴 M-x customize-themes
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'zenburn t)

;; ����vim��tagbar����֮ǰ�Ǹ�sr-speedbar��֪�����ö��ٱ�!
;; �������û��neotree�ã���൯��һ��frame���Ͳ�Ĭ�Ͽ����ˣ�������ʱ������
(autoload 'imenu-list-smart-toggle "imenu-list" nil t)
(global-set-key [(control f4)] 'imenu-list-smart-toggle)
