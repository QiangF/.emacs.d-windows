;; Time-stamp: <2021-11-05 10:11:37 lynnux>
;; �ǹٷ��Դ�packages������
;; benchmark: ʹ��profiler-start��profiler-report���鿴��Ӱ��emacs���ܣ�����ɿ��ٵ������
;; һ�㶼��eldoc�Ῠ����ggtag��racer mode������Ϊ����������������ɿ���

(add-to-list 'load-path
	     "~/.emacs.d/packages")

;; !themesҪ�ŵ��������theme�鿴 M-x customize-themes
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

(autoload 'defhydra "hydra" nil t)
(global-set-key (kbd "C-x f") 'hydra-find-file-select)
(global-set-key (kbd "C-c o") 'hydra-occur-select)
(global-set-key (kbd "C-c h") 'hydra-hideshow-select) ; bug:���һ����3������������֣������������һ�в���ʾ

(defun hydra-find-file-select ()
  (interactive)
  (unless (functionp 'hydra-find-file/body)
    (defhydra hydra-find-file ()
      "
_f_: file cache     _e_: helm locate
_c_: file changed   _v_: file visited
_a_: file at point  _q_uit
"
      ("f" file-cache-switch-file nil :color blue)
      ("e" helm-locate nil :color blue)
      ("c" files-recent-changed nil :color blue)
      ("v" files-recent-visited nil :color blue)
      ("a" find-file-at-point nil :color blue)
      ("q" nil "nil" :color blue))
    )
  (funcall 'hydra-find-file/body)
  )

(defun hydra-occur-select ()
  (interactive)
  (unless (functionp 'hydra-occur/body)
    (defhydra hydra-occur ()
      "
_a_: all   _t_: type
_m_: mode  _RET_: this buffer
_q_uit
"
      ("a" all-occur nil :color blue)
      ("t" type-occur nil :color blue)
      ("m" mode-occur nil :color blue)
      ("RET" occur nil :color blue)
      ("q" nil "nil" :color blue))
    )
  (funcall 'hydra-occur/body)
  )

;; hydraʹ��autoload�ķ�ʽ https://github.com/abo-abo/hydra/issues/149
(defun hydra-hideshow-select()
  (interactive)
  (hs-minor-mode)
  (unless (functionp 'hydra-hideshow/body)
    (defhydra hydra-hideshow ()
      "
_h_: hide all toggle     _s_: show block
_H_: hide block toggle   _S_: show all 
_c_: hide comment        _q_uit
"
      ("h" hs-toggle-hiding-all nil :color blue)
      ("s" hs-show-block nil :color blue)
      ("H" hs-toggle-hiding nil :color blue)
      ("S" hs-show-all nil :color blue)
      ("c" hs-hide-initial-comment-block nil :color blue)
      ("q" nil "nil" :color blue)))
  (funcall 'hydra-hideshow/body))

(defvar my-hs-hide nil "Current state of hideshow for toggling all.")
  ;;;###autoload
(defun hs-toggle-hiding-all () "Toggle hideshow all."
       (interactive)
       (setq-local my-hs-hide (not my-hs-hide))
       (if my-hs-hide
	   (hs-hide-all)
	 (hs-show-all)))

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
	'("~/.emacs.d/packages/yasnippet/yasnippet-snippets-master/snippets"
	  "~/.emacs.d/packages/yasnippet/mysnippets" ;; personal snippets
	  ))
  (yas-global-mode 1)

  ;; �����ʵ��ͦ���õģ���~xxx����Ҫ�滻�ģ�����`xxx'������Ҫѡ�е��в���ѡ��
  (autoload 'aya-create "auto-yasnippet" nil t)
  (autoload 'aya-expand "auto-yasnippet" nil t)
  (global-set-key (kbd "C-c y") #'aya-create)
  (global-set-key (kbd "C-c e") #'aya-expand)
  )
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

;; �ο�easy-kill��д��C-TAB
(defvar myswitch-buffer-list nil)
(defvar myswitch-buffer-current nil)
(defun myswitch-activate-keymap ()
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<C-tab>") 'myswitch_next_buffer)
    (define-key map (if (string-equal system-type "windows-nt")
			(kbd "<C-S-tab>")
		      (kbd "<C-S-iso-lefttab>"))
      'myswitch_prev_buffer)
    (set-transient-map ;; �ؼ�������
     map
     t ;; ����keymap
     (lambda ()
       ;; �˳�ʱ�����л�
       (switch-to-buffer (nth myswitch-buffer-current myswitch-buffer-list)); ����t�������л���ȥ
       )
     )))
(defun myswitch_next_buffer()
  (interactive)
  (incf myswitch-buffer-current)
  (if (>= myswitch-buffer-current (length myswitch-buffer-list))
      (setq myswitch-buffer-current 0))
  (switch-to-buffer (nth myswitch-buffer-current myswitch-buffer-list) t) ; �ڶ������������������л�
  )
(defun myswitch_prev_buffer()
  (interactive)
  (decf myswitch-buffer-current)
  (if (< myswitch-buffer-current 0)
      (setq myswitch-buffer-current (1- (length myswitch-buffer-list))))
  (switch-to-buffer (nth myswitch-buffer-current myswitch-buffer-list) t) ; �ڶ������������������л�
  )
(defun myswitch_next_buffer_start(&optional backward)
  (interactive)
  (setq myswitch-buffer-list (copy-sequence (if (featurep 'tabbar-ruler) 
						(ep-tabbar-buffer-list)
					      (buffer-list))
					    ))
  (message "C-tab to cycle forward, C-S-tab backward...")
  (setq myswitch-buffer-current 0)
  (if backward
      (myswitch_prev_buffer)
    (myswitch_next_buffer))
  (myswitch-activate-keymap)
  )
(global-set-key (kbd "<C-tab>")
		'myswitch_next_buffer_start
		)
(global-set-key (if (string-equal system-type "windows-nt")
		    (kbd "<C-S-tab>")
		  (kbd "<C-S-iso-lefttab>"))
		(lambda () 
		  (interactive)
		  (myswitch_next_buffer_start t))
		)

;;org��C-tab�����ϲ���
(add-hook 'org-mode-hook (lambda()
			   (define-key org-mode-map (kbd "<C-tab>") nil)))
(setq EmacsPortable-global-tabbar 't)
(require 'tabbar-ruler)
(setq EmacsPortable-excluded-buffers '("*Messages*" "*Completions*" "*ESS*" "*Compile-Log*" "*Ibuffer*" "*SPEEDBAR*" "*etags tmp*" "*reg group-leader*" "*Pymacs*" "*grep*"))
(setq EmacsPortable-included-buffers '("*scratch*" "*shell*"))

(require 'highlight-symbol)
;; zenburn
(set-face-background 'highlight-symbol-face "SteelBlue4") ; SteelBlue4
;; (set-face-foreground 'highlight-symbol-face "yellow")
;;atom-one-dark
;; (set-face-background 'highlight-symbol-face "black")
;;normal
;; (set-face-background 'highlight-symbol-face "yellow")
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
	    (eq major-mode 'fundamental-mode)
	    (eq major-mode 'helm-major-mode)
	    )
    (highlight-symbol-mode)) 
  )
(define-globalized-minor-mode global-highlight-symbol-mode highlight-symbol-mode highlight-symbol-mode-on)
(global-highlight-symbol-mode 1)
;; (require 'highlight-symbol-scroll-out)
;; (global-highlight-symbol-scroll-out-mode)
;; ����ѡ����
(defadvice highlight-symbol-get-symbol (around my-highlight-symbol-get-symbol activate)
  (if (use-region-p)
      (setq ad-return-value (buffer-substring (region-beginning) (region-end)))
    ad-do-it
    )
  )

(require 'cursor-chg)
(change-cursor-mode )
(setq curchg-default-cursor-color "red3") ; �޷�����cursor��foreground

;;crosshairs�����ã�ֻҪvline������		
(autoload 'vline-mode "vline" nil t)
(global-set-key [(control ?|)] 'vline-mode)

;; (global-hl-line-mode t)

(if nil
    ;; auto complete �ܿ�ϧ��ֹͣά���ˣ���ʱ������
    (progn
      (add-to-list 'load-path "~/.emacs.d/packages/auto-complete")
      (require 'auto-complete-config)
      (add-to-list 'ac-dictionary-directories "~/.emacs.d/packages/auto-complete/mydict")
      (ac-config-default)
      (setq-default ac-sources '(ac-source-abbrev
				 ac-source-dictionary
				 ac-source-words-in-same-mode-buffers
				 ac-source-semantic
				 ac-source-yasnippet
				 ac-source-words-in-buffer
				 ac-source-words-in-all-buffer
				 ac-source-imenu
				 ac-source-files-in-current-dir
				 ac-source-filename))
      (setq
       ac-use-fuzzy t ; ò���Զ�������menu����û��fuzzy�ģ����ֶ���ȫ�ǿ��Ե�
       ;; ac-auto-show-menu 0.1
       ac-use-quick-help nil
       ;; ac-ignore-case t
       ac-use-comphist t
       )
      (add-hook 
       'auto-complete-mode-hook 
       (lambda() 
	 (define-key ac-completing-map "\C-n" 'ac-next)
	 (define-key ac-completing-map "\C-p" 'ac-previous)
	 ))
      (global-set-key (kbd "<C-return>") 'auto-complete)
      (global-set-key (kbd "<M-return>") 'auto-complete)
      )
  (progn
    ;; company mode�����֧��comment���ģ�����֧�ֲ�ȫhistory
    (add-to-list 'load-path "~/.emacs.d/packages/company-mode")
    (require 'company)
    (add-hook 'after-init-hook 'global-company-mode)
    (define-key company-active-map (kbd "C-n") 'company-select-next)
    (define-key company-active-map (kbd "C-p") 'company-select-previous)
    (define-key company-active-map (kbd "M-n") 'company-next-page)
    (define-key company-active-map (kbd "M-p") 'company-previous-page)
    (define-key company-active-map (kbd "TAB") 'company-complete-selection) ; ����return
    (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
    (define-key company-active-map (kbd "C-h") nil) ; ȡ���󶨣���f1���档c-wֱ�ӿ�Դ��
    (dotimes (i 10)
      (define-key company-active-map (read-kbd-macro (format "C-%d" i)) 'company-complete-number))
    (setq ;company-idle-delay 0.5 ; Ϊ0�Ļ�̫���ˣ�����ͻῨס��Ĭ�Ͼ�����
     company-minimum-prefix-length 2
     company-require-match nil
     company-dabbrev-ignore-case nil
     company-dabbrev-downcase nil
     company-show-numbers t)
    ;; ����TabNine.exe������~\.TabNine\2.2.2\x86_64-pc-windows-gnu
    (with-eval-after-load 'dash
      (add-to-list 'load-path "~/.emacs.d/packages/company-mode/company-tabnine")
      (require 'company-tabnine)
      (add-to-list 'company-backends #'company-tabnine)
      )
    (global-set-key (kbd "<C-return>") 'company-indent-or-complete-common)
    (global-set-key (kbd "<M-return>") 'company-indent-or-complete-common)
    ;; (require 'company-posframe) ;; ͦ�ã����о���������Ӱ��
    ;; (company-posframe-mode 1)
    ;; (setq company-posframe-quickhelp-delay 0.1)
    (require 'company-ctags)
    (company-ctags-auto-setup)
    )
  )


;; һ���ͼ���modeȷʵͦ��ˬ�ģ������������
(require 'wcy-desktop)
(wcy-desktop-init)
(add-hook 'emacs-startup-hook
          (lambda ()
            (ignore-errors
              (wcy-desktop-open-last-opened-files))))
(defadvice wcy-desktop-load-file (after my-wcy-desktop-load-file activate)
  (setq buffer-undo-list nil)
  );; ���undo-tree��ͻ

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
  ;;(setq c-auto-newline 1)
  (c-set-style "stroustrup")
  (gtags-settings)
  ;; (define-key c-mode-base-map (kbd "C-h") 'c-electric-backspace) ;�޸�C-hû�����Ч��
  (local-set-key (kbd "C-c C-c") 'comment-eclipse)
  (setq clang-format-style "webkit") ; ֻ�����Ĭ��tab��4���ո�
  ;; (local-set-key [(meta f8)] 'clang-format-auto)
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

(require 'jumplist)
(global-set-key (kbd "M-n") 'jl-jump-forward)
(global-set-key (kbd "M-p") 'jl-jump-backward)
(add-to-list 'jl-insert-marker-funcs "my-switch-buffer")
(add-to-list 'jl-insert-marker-funcs "ggtags-find-tag-dwim")
(add-to-list 'jl-insert-marker-funcs "ggtags-find-reference")
(add-to-list 'jl-insert-marker-funcs "ggtags-find-file")
(add-to-list 'jl-insert-marker-funcs "racer-find-definition")
(add-to-list 'jl-insert-marker-funcs "swiper")
(add-to-list 'jl-insert-marker-funcs "helm-occur")
(add-to-list 'jl-insert-marker-funcs "helm-imenu-in-all-buffers")
(add-to-list 'jl-insert-marker-funcs "xref-find-definitions")
(global-set-key [(control ?\,)] 'my-save-pos) ; �ֶ�������¼λ��
(defun my-save-pos()
  (interactive)
  )
(add-to-list 'jl-insert-marker-funcs "my-save-pos")


(autoload 'iss-mode "iss-mode" "Innosetup Script Mode" t)
(setq auto-mode-alist (append '(("\\.iss$"  . iss-mode)) auto-mode-alist))
(setq iss-compiler-path "D:/Programme/Inno Setup 5/")
(add-hook 'iss-mode-hook 'xsteve-iss-mode-init)
(defun xsteve-iss-mode-init ()
  (interactive)
  (define-key iss-mode-map [f6] 'iss-compile)
  (define-key iss-mode-map [(meta f6)] 'iss-run-installer))

;; (add-hook 'dired-mode-hook (lambda () (require 'w32-browser)))
(with-eval-after-load 'dired
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
      '("Open Associated Applications" . dired-multiple-w32-browser))))

(autoload 'cmake-mode "cmake-mode" "cmake-mode" t)
(setq auto-mode-alist
      (append '(("CMakeLists\\.txt\\'" . cmake-mode)
		("\\.cmake\\'" . cmake-mode))
	      auto-mode-alist))

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
  (setq eldoc-idle-delay 0)
  (turn-on-eldoc-mode)
  ;;  (local-set-key (kbd "RET") 'electrify-return-if-match)
  (eldoc-add-command 'electrify-return-if-match)
  (show-paren-mode t)
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
  ;; (add-hook 'after-save-hook #'gtags-update-hook)
  (require 'ggtags)
  (ggtags-mode 1)
  (add-hook 'ggtags-global-mode-hook (lambda()
				       (define-key ggtags-global-mode-map "n" 'next-line)
				       (define-key ggtags-global-mode-map "p" 'previous-line)
				       ))
  (setq ggtags-global-abbreviate-filename nil) ; ����д·��
  (defadvice ggtags-eldoc-function (around my-ggtags-eldoc-function activate)); eldocû�п��أ�ֻ����д���ĺ�����
					;  (customize-set-variable 'ggtags-highlight-tag nil) ; ��ֹ�»��� setq��defcustom��Ч�� ������eldoc������ʾprocess sentinel��
  ;; (local-set-key (kbd "<f12>") 'ggtags-find-tag-dwim)
  ;; (local-set-key (kbd "C-.") 'ggtags-find-tag-dwim)
  ;; (local-set-key (kbd "<C-down-mouse-1>") 'ggtags-find-tag-dwim) ; CTRL + ��������ܺ���
  ;;(turn-on-eldoc-mode) ; �Ῠ
  )

;; python
(add-to-list 'load-path "~/.emacs.d/packages/jedi")
(when (featurep 'auto-complete)
  (autoload 'jedi:ac-setup "jedi" nil t)
  (add-hook 'python-mode-hook '(lambda ()
				 (jedi:ac-setup)
				 (local-set-key (kbd "<C-return>") 'jedi:complete))))
;; (setq jedi:server-command
;;       (list "D:\\Python27\\Python.exe" jedi:server-script))

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

;; (add-hook 'c-mode-common-hook
;; 	  (lambda ()
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

;;; shell, main goal is for compile test
(defvar smart-compile-run-last-buffer nil)
(defun smart-compile-run ()
  (interactive)
  (if (equal (buffer-name) "*shell*")
      (progn
	(if smart-compile-run-last-buffer
	    (switch-to-buffer smart-compile-run-last-buffer)
	  (switch-to-prev-buffer))
	(delete-other-windows))
    ;; (let ((run-exe (concat (file-name-sans-extension
    ;; 		     (file-name-nondirectory (buffer-file-name))) ".exe"))))
    (progn
      (setq smart-compile-run-last-buffer (buffer-name))
      (with-current-buffer (shell)
	(end-of-buffer)
	(move-end-of-line nil)
					;(move-beginning-of-line nil)
					;(kill-line 1)
					;(insert-string run-exe)
					;(move-end-of-line nil)
	))))
;; (global-set-key (kbd "<f5>") 'smart-compile-run) ; ��projetile��f5 x s����

;;; TODO ������������Ŀ¼����һ��Ŀ¼C-F7ʱ��ǰĿ¼û�б䣬����C-u F7��������
;; compile�������˵�������ĳ���ļ�
(setq compilation-auto-jump-to-first-error nil ; �Զ��������������ֻ��warningʱ�൱����
      compilation-scroll-output t)
(autoload 'smart-compile "smart-compile" nil t)
(autoload 'smart-compile-c-compile "smart-compile" nil t)
(global-set-key [f7] 'smart-compile)
(global-set-key [(shift f7)] 'smart-compile-regenerate)
(global-set-key [(control f7)] 'smart-compile-c-compile)
(defun smart-compile-regenerate()
  (interactive)
  (smart-compile 4))

(defun bury-compile-buffer-if-successful (buffer string)
  "Bury a compilation buffer if succeeded without warnings "
  (when (and
         (buffer-live-p buffer)
         (string-match "compilation" (buffer-name buffer))
         (if (string-match "finished" string)
	     ;; �Ҳ�����λ�ȡ����buffer�ķ�����ֻ����compilation���ɫ��
	     (progn (face-remap-add-relative
		     'mode-line-inactive '((:foreground "ivory" :background "SeaGreen") mode-line))
		    (face-remap-add-relative
		     'mode-line '((:foreground "ivory" :background "SeaGreen") mode-line))
		    t)
	   (progn (face-remap-add-relative
		   'mode-line-inactive '((:foreground "ivory" :background "DarkOrange2") mode-line))
		  (face-remap-add-relative
		   'mode-line '((:foreground "ivory" :background "DarkOrange2") mode-line))
		  nil))
         (not
          (with-current-buffer buffer
            (goto-char (point-min))
            (search-forward "warning" nil t))))
    (delete-windows-on buffer)
    ;; (run-with-timer 1 nil
    ;; 		    (lambda (buf)
    ;; 		      (bury-buffer buf)
    ;; 		      (switch-to-prev-buffer (get-buffer-window buf) 'kill))
    ;; 		    buffer)  ;; ��������������ڲ������˳�����
    (setq current-frame (car (car (cdr (current-frame-configuration)))))
    (select-frame-set-input-focus current-frame) ; ������������û���ã�������
    ))
(with-eval-after-load 'compile (add-to-list 'compilation-finish-functions
					    'bury-compile-buffer-if-successful))

;; expand-region��easy-kill��easy-mark�滻�ˣ���Ҫ�����ᱻ����
(add-to-list 'load-path "~/.emacs.d/packages/expand-region")
;; (autoload 'er/expand-region "expand-region" nil t)
;; (autoload 'er/contract-region "expand-region" nil t)
;; (global-set-key "\C-t" 'er/expand-region)
;; (global-set-key (kbd "C-S-t") 'er/contract-region)

;; see https://github.com/magnars/expand-region.el/issues/229
(with-eval-after-load "expand-region"
  (global-set-key (kbd "C-q") #'(lambda (arg)
				  (interactive "P")
				  (setq transient-mark-mode t)
				  (set-mark-command arg))))
;;; �����(setq show-paren-style 'expression)���ǵ�����
(defadvice show-paren-function (around not-show-when-expand-region activate)
  (if (and (or (eq major-mode 'lisp-interaction-mode) (eq major-mode 'emacs-lisp-mode))
	   (memq last-command '(er/expand-region er/contract-region easy-mark easy-kill-er-expand easy-kill-er-unexpand)))
      (progn
	(setq show-paren-style 'parenthesis)
	ad-do-it
	(setq show-paren-style 'expression)
	)
    ad-do-it))

(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'auto-mode-alist '("\\.nse$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))
(modify-coding-system-alist 'file "\\.lua\\'" 'utf-8) ; ��Ҫ��BOM��BOM��ms���е�

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
(global-unset-key (kbd "<M-down-mouse-1>"))
(global-set-key (kbd "M-<mouse-1>") 'mc/add-cursor-on-click)
(global-set-key (kbd "C-M-<mouse-1>") 'mc/unmark-next-like-this) ; ȡ��������µ�mark
(global-set-key (kbd "M-S-<mouse-1>") 'mc/unmark-previous-like-this) ;ȡ��������ϵ�mark
(global-set-key (kbd "M-<wheel-up>") 'mc/mark-previous-like-this)
(global-set-key (kbd "M-<wheel-down>") 'mc/mark-next-like-this)
;; (global-set-key (kbd "C-S-t") 'mc/edit-lines)  ;��Ȼ��֧��ͬ�е�range
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "<f8>") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(with-eval-after-load 'multiple-cursors
  (define-key mc/keymap (kbd "C-v") nil)
  (define-key mc/keymap (kbd "RET") 'multiple-cursors-mode))

;;; ��Ļ�ڿ���������Ĭ����������ĸ��ͷ�ĵ���λ�ã�C-u C-j��Ϊ����ԭ����λ�ã�C-u C-u C-j��������
(autoload  'ace-jump-mode  "ace-jump-mode"  "Emacs quick move minor mode"  t)
(define-key global-map (kbd "C-o") 'ace-jump-mode)
(with-eval-after-load 'ace-jump-mode (setq ace-jump-mode-submode-list
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
(modify-coding-system-alist 'file "\\.rs\\'" 'utf-8-with-signature) ; �����ı���������룬�ɴ��Ĭ��

;;; racer��ȫ
(autoload 'racer-mode "racer" nil t)
(add-hook 'rust-mode-hook #'racer-mode)
(add-hook 'racer-mode-hook #'eldoc-mode)
(defun my/racer-mode-hook ()
  (when (featurep 'auto-complete)
    (require 'ac-racer)
    (ac-racer-setup)
    (make-local-variable 'ac-auto-start) ; �Զ������Ῠ
    (setq ac-auto-start nil)
    )
  (when (featurep 'company)
    (make-local-variable 'company-idle-delay)
    (setq company-idle-delay nil) 	; ���Զ���ȫ
    (define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
    (setq company-tooltip-align-annotations t))
  (setq-local eldoc-documentation-function #'ignore) ; eldoc����Ӱ�����룡
  (when (featurep 'smartparens-rust)
    ;; ���������smartparens-rust����ȻûЧ������ʵ��Ҫsmartparens-rust�ͺ���
    (with-eval-after-load 'smartparens-rust
      (sp-local-pair 'rust-mode "'" nil :actions nil)
      (sp-local-pair 'rust-mode "<" nil :actions nil) ;  ��4��������д">"Ҳ����
      )))
(add-hook 'racer-mode-hook 'my/racer-mode-hook)

(add-to-list 'load-path "~/.emacs.d/packages/neotree")
(autoload 'neotree-toggle "neotree" nil t)
(global-set-key (kbd "<C-f1>") 'neotree-toggle)
(setq neo-window-width 32
      neo-create-file-auto-open t
      neo-show-updir-line t
      neo-mode-line-type 'neotree
      neo-smart-open t
      neo-show-hidden-files t
      neo-auto-indent-point t
      neo-vc-integration nil)
(with-eval-after-load 'neotree (define-key neotree-mode-map (kbd "C-l") 'neotree-select-up-node))

;; �е������Զ��ضγ��е�Ч����Ĭ�ϰ󶨵�m-q��elisp-mode��Ч
(autoload 'unfill-toggle "unfill" nil t)
(global-set-key [remap fill-paragraph] #'unfill-toggle)

(require 'hungry-delete)
(global-hungry-delete-mode)
(setq-default hungry-delete-chars-to-skip " \t\f\v") ; only horizontal whitespace

(add-to-list 'load-path "~/.emacs.d/packages/smartparens")
(require 'smartparens-config)
;; (sp-use-paredit-bindings)
(sp-use-smartparens-bindings)
(define-key smartparens-mode-map (kbd "M-s") 'sp-splice-sexp)
(define-key smartparens-mode-map (kbd "M-a") 'sp-backward-sexp)
(define-key smartparens-mode-map (kbd "M-e") 'sp-forward-sexp)
;; ����paredit��M-(������ģʽ����pair��ֹ(���Բ�����
(sp-local-pair '(emacs-lisp-mode lisp-interaction-mode) "(" nil :bind "M-(") ; �����ʵ�ǰ�װ��sp-wrap��
(set-default 'sp-autoskip-closing-pair 'always)
;; Don't kill the entire symbol on C-k
(set-default 'sp-hybrid-kill-entire-symbol nil)
;; �ο�doom����
(setq sp-highlight-pair-overlay nil
      sp-highlight-wrap-overlay nil
      sp-highlight-wrap-tag-overlay nil)
(setq sp-max-prefix-length 25)
(setq sp-max-pair-length 4)
(smartparens-global-strict-mode)
;;(show-smartparens-global-mode) ;; Show parenthesis ����ûʲô������?
;;(defadvice sp-show--pair-echo-match (around my-sp-show--pair-echo-match activate)) ; ���� Matches:��Ϣ

;; ʹ֧��hungry-delete
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
;; �����Զ�indent��from https://github.com/Fuco1/smartparens/issues/80
(sp-local-pair '(c++-mode rust-mode) "{" nil :post-handlers '((my-create-newline-and-enter-sexp "RET")))
(defun my-create-newline-and-enter-sexp (&rest _ignored)
  "Open a new brace or bracket expression, with relevant newlines and indent. "
  (newline)
  (indent-according-to-mode)
  (forward-line -1)
  (indent-according-to-mode))

;; ����vim��tagbar����֮ǰ�Ǹ�sr-speedbar��֪�����ö��ٱ�!
;; �������û��neotree�ã���൯��һ��frame���Ͳ�Ĭ�Ͽ����ˣ�������ʱ������
(autoload 'imenu-list-smart-toggle "imenu-list" nil t)
(global-set-key [(control f4)] 'imenu-list-smart-toggle)

(if t
    ;; ��helm���������ö��������imenu-anywhere��popup-kill-ring��ripgrep��minibuffer-complete-cycle��etags-select��������everything(helm-locate)
    ;; �ο�helm���ߵ�����https://github.com/thierryvolpiatto/emacs-tv-config/blob/master/init-helm-thierry.el
    (progn
      (icomplete-mode 1)		; �����swiper��ͻ��helmû����
      (add-to-list 'load-path "~/.emacs.d/packages/helm/emacs-async-master")
      (require 'async-autoloads)
      (add-to-list 'load-path "~/.emacs.d/packages/helm/helm-master")
      (add-to-list 'load-path "~/.emacs.d/packages/helm")
      (require 'helm-config)
      ;;(global-set-key (kbd "C-c h") 'helm-mini)
      (global-set-key (kbd "M-x") 'undefined)
      (global-set-key (kbd "M-x") 'helm-M-x)
      (global-set-key (kbd "C-s") 'helm-occur) ;; ����helm swoop�ˣ����֧����c-x c-b��ʹ�á�����follow mode
      (global-set-key (kbd "M-y") 'helm-show-kill-ring) ; ��popup-kill-ring�õ��Ƕ�������
      (global-set-key (kbd "C-`") 'helm-show-kill-ring)
      (global-set-key [f2] 'helm-do-grep-ag) ; ʹ��ripgrep��rg����������пӰ�����Ȼ��gitignore! �ĵ�rg --help
      (autoload 'ansi-color-apply-sequence "ansi-color" nil t) ; F2ʱҪ��helm-libʹ��

      (global-set-key (kbd "C-x C-f") 'helm-find-files) ; ����������ļ��ǳ����㣡 C-c ?��ϸѧѧ��
      (global-set-key (kbd "C-x C-b") 'helm-buffers-list) ; ��ԭ���Ǹ��ð�
      (global-set-key (kbd "C-c C-r") 'helm-resume)	  ;�����ղŵ�session
      (global-set-key (kbd "<f6>") 'helm-resume)

      ;; (define-key global-map [remap find-tag]              'helm-etags-select) ;; 
      ;; (define-key global-map [remap xref-find-definitions] 'helm-etags-select) ;; ��֪��Ϊʲô������local key
      (global-set-key [(control f2)] (lambda () (interactive)
				       (require 'vc)
				       (helm-fd-1 (or (vc-find-root "." ".git") (helm-current-directory))))) ; ��fd�����ļ�����git�Ļ���git��Ŀ¼����
      (autoload 'helm-fd-1 "helm-fd" nil t) ; F2ʱҪ��helm-libʹ��

      ;; helm-do-grep-ag ���������bug������helm-swoop����������
      (setq
       ;; smart case��emacs���ƣ�Ĭ�϶�gitignoreʵ�ڲ�ϰ��
       helm-grep-ag-command "rg --color=always --smart-case --no-heading --line-number --no-ignore %s %s %s"
       ;; helm-grep-ag-pipe-cmd-switches '("--colors 'match:fg:black'" "--colors 'match:bg:yellow'") ;; ò��ûʲô��
       helm-move-to-line-cycle-in-source t ; ʹ����βʱ����ѭ����ȱ��������������б������Ǹ���C-o����M->�л���ȥ
       helm-echo-input-in-header-line t ; ���ͦawesome�ģ���ʹ��minibuffer�����м��۾��ƶ���С
       helm-split-window-in-side-p t ; ��Ȼ�Ļ���������������ڣ����ͻ�ʹ����һ�����ڡ���һ���Ǻ�Ļ��ã����ľͲ�ϰ����
       helm-ff-file-name-history-use-recentf t
       helm-ff-search-library-in-sexp t ; search for library in `require' and `declare-function' sexp.
       helm-buffers-fuzzy-matching t    ; ����ϸ����fuzzy��ϲ����
       helm-recentf-fuzzy-match    t
       helm-follow-mode-persistent t
       helm-allow-mouse t
       helm-grep-input-idle-delay 0.02 	; �����ӵ�Ĭ��0.6�����������ӳ�
       )
      
      (with-eval-after-load 'helm
	(helm-mode 1)

	;; (defadvice start-file-process-shell-command (before my-start-file-process-shell-command activate)
	;;   (message (ad-get-arg 2)))
	
	;; ����ƶ�ʱҲ�Զ���λ������λ��
	(push "Occur" helm-source-names-using-follow) ; ��Ҫhelm-follow-mode-persistentΪt
	(push "RG" helm-source-names-using-follow)

	;; �ο�swiper������ɫ�����һ��˲��о���һ��
	(custom-set-faces
	 '(helm-selection ((t (:inherit isearch-lazy-highlight-face :underline t :background "#3F3F3F")))) ; underline�ÿ���:background nilȥ��������ɫ���͸ĳ�zenburnͬɫ��
	 '(helm-selection-line ((t (:inherit isearch-lazy-highlight-face :underline t :background "#3F3F3F"))))
	 ;;helm-match-item 
	 )
	(define-key helm-map (kbd "<f1>") 'nil)
	(define-key helm-map (kbd "C-1") 'keyboard-escape-quit)

	(define-key helm-map (kbd "C-h") 'nil)
	(define-key helm-map (kbd "C-t") 'nil) ; c-t�Ƿ�ת��ʽ
	(define-key helm-map (kbd "C-t") 'helm-toggle-visible-mark)
	(define-key helm-map (kbd "C-v") 'nil)
	(define-key helm-map (kbd "<f4>") 'helm-next-line)
	(define-key helm-map (kbd "<S-f4>") 'helm-previous-line)
	;; (define-key helm-map (kbd "C-s") 'helm-next-line) ;; �����������helm-occur����helm-ff-run-grep
	;; (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
	;; tab�Զ���ȫ������ڵ�symbol��TODO��������ֻ�Կ�������Ч�������жϿ�������
	(define-key helm-map (kbd "<tab>") (lambda ()(interactive)
					     (let ((src (helm-get-current-source)))
					       (if (member (assoc-default 'name src)
							   (list "RG" "Occur"))
						   (let ((symbol-under-cursor (with-helm-current-buffer
									       (thing-at-point 'symbol))))
						     (if symbol-under-cursor
							 (helm-set-pattern symbol-under-cursor)
						       )
						     )
						 (call-interactively 'helm-execute-persistent-action)
						 )
					       )
					     ))
	
	(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
	(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z
	;; (define-key helm-map (kbd "TAB") 'helm-next-line)
	;; (define-key helm-map (kbd "<backtab>") 'helm-previous-line)
	;;(define-key helm-map (kbd "C-w") 'ivy-yank-word) ; ��Ȼ��Ĭ��

	;; �������������Ҫʹ��ԭ��������C-z��helm mode̫���ˣ��õ���Щ������
	(define-key helm-map (kbd "C-s") 'helm-next-line) ; ԭ�������ڵ�ǰ�������
	(define-key helm-find-files-map (kbd "C-s") 'helm-next-line) ; ԭ�������ڵ�ǰ�������
	(define-key helm-buffer-map (kbd "C-s") 'helm-next-line) ;ԭoccur

	;; helm-locate��everything�������λ��
	(define-key helm-generic-files-map (kbd "C-x C-d")
	  (lambda ()
	    (interactive)
	    (with-helm-alive-p
	     (helm-exit-and-execute-action (lambda (file)
					     (require 'w32-browser)
					     (w32explore file)
					     )))))
	
	(when helm-echo-input-in-header-line
	  (add-hook 'helm-minibuffer-set-up-hook
		    'helm-hide-minibuffer-maybe))        
	)
      ;; �⹦�ܲ���д���������ܱ�û�кð�
      (defun helm-grep-search-parent-directory ()
	(interactive)
	(helm-run-after-exit (lambda ()
			       (let* ((parent (file-name-directory (directory-file-name default-directory)))
				      (default-directory parent))
				 (helm-grep-ag (expand-file-name parent) nil)))))
      (defun helm-show-search()
	(interactive)
	(yank)
	)
      
      (with-eval-after-load 'helm-grep
	(define-key helm-grep-map (kbd "DEL") 'nil) ; helm-delete-backward-no-update���ӳ�
	(define-key helm-grep-map (kbd "C-l") 'helm-grep-search-parent-directory)
	;; (define-key helm-grep-map (kbd "<tab>") 'helm-show-search) ; TODO: �������ʱ���Զ���ȫ����µĵ���
	)
      (with-eval-after-load 'helm-find
	(define-key helm-find-map (kbd "DEL") 'nil) ; helm-delete-backward-no-update���ӳ�
	)
      (defadvice completing-read (before my-completing-read activate)
	(helm-mode 1))
      (global-set-key (kbd "M-m") 'helm-imenu-in-all-buffers)
      )
  (progn
    ;; ivyȷʵ���ã����ǹ�˾win7������ʱc-x c-f�����ӳ�
    (add-to-list 'load-path "~/.emacs.d/packages/swiper")
    (autoload 'swiper "swiper" nil t)
    (setq ivy-use-virtual-buffers t)
    (setq enable-recursive-minibuffers t)
    (global-set-key "\C-s" 'swiper)
    (autoload 'ivy-resume "ivy" nil t)
    (autoload 'ivy-mode "ivy" nil t)
    (global-set-key (kbd "C-c C-r") 'ivy-resume)
    (global-set-key (kbd "<f6>") 'ivy-resume)
    (global-set-key [f2] 'counsel-rg) 	; Great! ò���ǽ����rg�����������ˣ���Ƶ������rg�ķ�ʽhttps://github.com/abo-abo/swiper/pull/2552
    (autoload 'counsel-rg "counsel" nil t)
    (autoload 'counsel-M-x "counsel" nil t)
    (autoload 'counsel-find-file "counsel" nil t)
    (autoload 'counsel-describe-function "counsel" nil t)
    (autoload 'counsel-describe-variable "counsel" nil t)
    (autoload 'counsel-find-library "counsel" nil t)
    (global-set-key (kbd "M-x") 'counsel-M-x)
    (global-set-key (kbd "C-x C-f") 'counsel-find-file)
    (global-set-key (kbd "<f1> f") 'counsel-describe-function)
    (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
    (global-set-key (kbd "<f1> l") 'counsel-find-library)
    (with-eval-after-load 'ivy
      (ivy-mode 1)
      (define-key ivy-minibuffer-map (kbd "C-r") 'ivy-previous-line)
      (define-key ivy-minibuffer-map (kbd "C-s") 'ivy-next-line)
      (define-key ivy-minibuffer-map (kbd "TAB") 'ivy-next-line)
      (define-key ivy-minibuffer-map (kbd "<backtab>") 'ivy-previous-line)
      (define-key ivy-minibuffer-map (kbd "C-w") 'ivy-yank-word) ; ��Ȼ��Ĭ��
      (define-key ivy-minibuffer-map (kbd "C-v") 'nil)
      (setq ivy-more-chars-alist '((counsel-rg . 1) (t . 3)))
      )
    ;; (with-eval-after-load 'counsel
    ;;   (append counsel-rg-base-command "--no-ignore")) ; �����üӣ���������ignore��
    (defadvice completing-read (before my-completing-read activate)
      (ivy-mode 1))
    (add-to-list 'sp-ignore-modes-list 'minibuffer-mode) ; C-K����Ȼ��minibuffer�����smartparens
    ))


;; �Զ�indent
(require 'aggressive-indent)
(global-aggressive-indent-mode 1)
(with-eval-after-load 'aggressive-indent
  (add-to-list 'aggressive-indent-excluded-modes 'python-mode)
  (add-to-list
   'aggressive-indent-dont-indent-if
   '(and (derived-mode-p 'c++-mode)
	 (null (string-match "\\([;{}]\\|\\b\\(if\\|for\\|while\\)\\b\\)"
			     (thing-at-point 'line))))))


(defun copy-buffer-name (choice &optional use_win_path)
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
      (if use_win_path
	  (let ((win-path (replace-regexp-in-string "/" "\\\\" new-kill-string)))
	    (message "%s copied" win-path)
	    (kill-new win-path))
	(message "%s copied" new-kill-string)
	(kill-new new-kill-string)))))
(defun hydra-copybf4/body()
  (interactive)
  (require 'hydra)
  (funcall (defhydra hydra-copybf4 ()
	     "
Copy Buffer Name: _f_ull, _d_irectoy, n_a_me ?
"
	     ("f" (copy-buffer-name ?f) nil :color blue)
	     ("d" (copy-buffer-name ?d) nil :color blue)
	     ("a" (copy-buffer-name ?a) nil :color blue)
	     ("q" nil "" :color blue))))
(global-set-key (kbd "C-4") 'hydra-copybf4/body)
(defun hydra-copybf3/body() ()
       (interactive)
       (require 'hydra)
       (funcall (defhydra hydra-copybf3 ()
		  "
Copy Buffer Name: _f_ull, _d_irectoy, n_a_me ?
"
		  ("f" (copy-buffer-name ?f t) nil :color blue)
		  ("d" (copy-buffer-name ?d t) nil :color blue)
		  ("a" (copy-buffer-name ?a t) nil :color blue)
		  ("q" nil "" :color blue))))
(global-set-key (kbd "C-3") 'hydra-copybf3/body)

;; go lang
(autoload 'go-mode "go-mode" nil t)
(add-to-list 'auto-mode-alist (cons "\\.go\\'" 'go-mode))
;; (with-eval-after-load 'go-mode (add-hook 'before-save-hook 'gofmt-before-save))

;; magit
(add-to-list 'load-path "~/.emacs.d/packages/magit/magit-master/lisp")
(add-to-list 'load-path "~/.emacs.d/packages/magit")
(autoload 'magit "magit" nil t)
(global-set-key (kbd "C-c C-c") 'magit)

;;; zig mode
(autoload 'zig-mode "zig-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.zig\\'" . zig-mode))
(modify-coding-system-alist 'file "\\.zig\\'" 'utf-8-with-signature) ; ǿ��zig�ļ���Ϊutf8��������������ʾ����
(setq zig-format-on-save nil)
(with-eval-after-load 'zig-mode (add-hook 'zig-mode-hook (lambda () (local-set-key [(meta f8)] 'zig-format-buffer))))

;; dumb-jump��ʹ��rg���Ҷ��壡��Ҫ����project root�����������Щ�ļ������ԣ�.dumbjump .projectile .git .hg .fslckout .bzr _darcs .svn Makefile PkgInfo -pkg.el.
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
(autoload 'dumb-jump-xref-activate "dumb-jump" nil t)
(setq xref-show-definitions-function #'xref-show-definitions-completing-read) ; ����xref����helm�������C-C C-F�л�follow mode�����⣬��ʱ������
(global-set-key (kbd "<f12>") 'xref-find-definitions) 
(global-set-key (kbd "C-.") 'xref-find-definitions) ; ����ggtags֧�ֵĶ������
(global-set-key (kbd "<C-down-mouse-1>") 'xref-find-definitions)
(with-eval-after-load 'dumb-jump
  (defadvice dumb-jump-get-project-root (before my-dumb-jump-get-project-root activate)
    ;; arount����������
    (setq dumb-jump-default-project default-directory) ; Ĭ������Ϊ��ǰĿ¼
    )
  )

;; easy-kill���������vim��yi/a�Ķ�����
(add-to-list 'load-path "~/.emacs.d/packages/easy-kill")
(global-set-key [remap kill-ring-save] 'easy-kill)
(autoload 'easy-kill "easy-kill" nil t)
(autoload 'easy-mark "easy-kill" nil t)
(global-set-key "\C-t" 'easy-mark) ; �滻expand-region
(with-eval-after-load 'easy-kill
  (require 'easy-kill-er)
  (require 'extra-things)
  (require 'easy-kill-extras)
  (setq easy-kill-try-things '(line)) ; ֻ����line
  (setq easy-mark-try-things '(word sexp)) ; word���ȣ��ر����к��ʲô��ʱ��
  ;; (define-key easy-kill-base-map (kbd "C-r") 'easy-kill-er-expand) ; ��Ҫ�ٶ����ˣ�����markʱ���ܸ���
  (define-key easy-kill-base-map (kbd "C-t") 'easy-kill-er-expand)
  (define-key easy-kill-base-map (kbd "C-S-t") 'easy-kill-er-unexpand)
  (define-key easy-kill-base-map (kbd "n") 'easy-kill-expand)
  (define-key easy-kill-base-map (kbd "p") 'easy-kill-shrink)
  (define-key easy-kill-base-map (kbd "C-d") 'easy-kill-region)
  (define-key easy-kill-base-map (kbd "C-h") 'easy-kill-region)
  (autoload 'er--expand-region-1 "expand-region" nil t)
  (add-to-list 'easy-kill-alist '(?^ backward-line-edge ""))
  (add-to-list 'easy-kill-alist '(?$ forward-line-edge ""))
  (add-to-list 'easy-kill-alist '(?a buffer ""))
  ;; (add-to-list 'easy-kill-alist '(?< buffer-before-point "")) ;; �ø�copy<>�о�������
  ;; (add-to-list 'easy-kill-alist '(?> buffer-after-point ""))
  (add-to-list 'easy-kill-alist '(?f string-to-char-forward ""))
  (add-to-list 'easy-kill-alist '(?F string-up-to-char-forward ""))
  (add-to-list 'easy-kill-alist '(?t string-to-char-backward ""))
  (add-to-list 'easy-kill-alist '(?T string-up-to-char-backward ""))
  (add-to-list 'easy-kill-alist '(?W  WORD " ") t)
  (add-to-list 'easy-kill-alist '(?\' squoted-string "") t)
  (add-to-list 'easy-kill-alist '(?\" dquoted-string "") t)
  (add-to-list 'easy-kill-alist '(?\` bquoted-string "") t)
  (add-to-list 'easy-kill-alist '(?q  quoted-string "") t)
  (add-to-list 'easy-kill-alist '(?Q  quoted-string-universal "") t)
  (add-to-list 'easy-kill-alist '(?\) parentheses-pair-content "\n") t)
  (add-to-list 'easy-kill-alist '(?\( parentheses-pair "\n") t)
  (add-to-list 'easy-kill-alist '(?\] brackets-pair-content "\n") t)
  (add-to-list 'easy-kill-alist '(?\[ brackets-pair "\n") t)
  (add-to-list 'easy-kill-alist '(?}  curlies-pair-content "\n") t)
  (add-to-list 'easy-kill-alist '(?{  curlies-pair "\n") t)
  (add-to-list 'easy-kill-alist '(?>  angles-pair-content "\n") t)
  (add-to-list 'easy-kill-alist '(?<  angles-pair "\n") t)
  )

;; projectile�������rg
(add-to-list 'load-path "~/.emacs.d/packages/projectile")
(defun invoke_projectile ()
  (interactive)
  (require 'projectile)
  (projectile-mode +1)
  (set-transient-map projectile-command-map) ; ���������key��ȱ�����״ε�?������
  )
(global-set-key (kbd "C-;") 'invoke_projectile)
(global-set-key (kbd "<f5>") 'invoke_projectile) ; ԭ���ܿ�����f5 x s

(with-eval-after-load 'projectile
  (define-key projectile-mode-map (kbd "C-;") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "<f5>") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "<f5> s-") nil) ; Undefine prefix binding https://emacs.stackexchange.com/questions/3706/undefine-prefix-binding
  (define-key projectile-mode-map (kbd "<f5> s") #'projectile-ripgrep) ; ��C-; sͬ����Ч
  )

;; rg�������ͦ���õģ����޸������Ĺ���(��Ҫbuffer��д)�����๦�ܿ��˵�
(global-set-key (kbd "C-S-f") 'rg-dwim)
(autoload 'rg-dwim "rg" nil t)

;; which-keyȷʵ����
(require 'which-key)
(which-key-mode)

;; ������Ҫ������
(load-theme 'zenburn t)
