;; compile all: C-u 0 M-x byte-recompile-directory
;; �����ܷ������Ŀ¼��Ӧ�÷�pluginĿ¼������require��ʱ���Ҳ���
(mapc 'load (directory-files "~/.emacs.d/settings" t "^[a-zA-Z0-9].*.el$"))

;; .emacs��Ҫ����Բ�ͬ����Ҫ�ı�����ݣ�
;; ���ڸĽ�Ϊ���ݵ�¼�û�����ϵͳ�汾���ֱ�����

(defun add-path-to-execute-path (path)
  (setenv "PATH" (concat (getenv "PATH") path))
  (setq exec-path (append exec-path (list path))))
(cond 
 ;; home
 ((and
   (string-equal system-type "windows-nt")
   (string-equal "20100910-1853" (system-name)) ; computer name
   (equal (user-real-login-name) "Administrator")
   (equal (list 5 1 2600) (w32-version))	; xp
   )

  ;; learn org remember http://members.optusnet.com.au/~charles57/GTD/remember.html
  (setq org-remember-templates
	'(("Todo" ?t "* TODO %i\n%?\n��: %U %a" "~/org/TODO.org" "Tasks")
	  ))
  ;(setq org-directory "~/org");
  ;; remember default file save to (if not use with org)
  ;; (setq remember-data-file (convert-standard-filename "~/org/.notes"))
  (setq org-default-notes-file "~/org/default.org") ; ��������
  (setq everything-procname "Everything-1.2.1.371.exe")
  ;; etags table
  (setq etags-table-alist
	(list
	 ;; For jumping to standard headers:
	 '(".*\\.\\([ch]\\|cpp\\)" "c:/Program Files/Microsoft SDKs/Windows/v6.0A/Include/TAGS" 
	   "D:/Program Files/Microsoft Visual Studio 9.0/VC/atlmfc/TAGS"
	   "D:/Program Files/Microsoft Visual Studio 9.0/VC/crt/src/TAGS"
	   "D:/Program Files/Microsoft Visual Studio 9.0/VC/include/TAGS"
	   "D:/Program Files/Microsoft Visual Studio 9.0/VC/WTL81_9127/Include/TAGS")
	 ;; '(".*\\.\\(hrl\\|erl\\)" "d:/erl5.9.3.1/TAGS")
	 '(".*\\.el" "D:/green/emacs-24.3/lisp/TAGS")
	 ;; For jumping across project:
	 ;; '("/home/devel/proj1/" "/home/devel/proj2/TAGS" "/home/devel/proj3/TAGS")
	 ;; '("/home/devel/proj2/" "/home/devel/proj1/TAGS" "/home/devel/proj3/TAGS")
	 ;; '("/home/devel/proj3/" "/home/devel/proj1/TAGS" "/home/devel/proj2/TAGS")
	 ))
  
  (add-path-to-execute-path "D:/Python27")
  (add-path-to-execute-path "D:/Python27/Scripts")
  
;;; D:\MinGWCRT64\lib\gcc\i686-w64-mingw32\4.6.3\include\c++
  ;; (setq cscope-database-regexps
  ;;       '(
  ;; 	( "^"
  ;; 	  ( "D:/MinGWCRT64/lib/gcc/i686-w64-mingw32/4.6.3/include/c++/bits" ("-d") )
  ;; 	  ( "D:/MinGWCRT64/i686-w64-mingw32/include" ("-d") )
  ;; 	  )
  ;; 	))
  
  ) ;; end home
 
 ;; work
 ((and 
   (string-equal system-type "windows-nt")
   (string-equal "LYNNPC" (system-name))
   (equal (list 6 2 9200) (w32-version)) ;; win8
   )
  
  (add-path-to-execute-path "D:/Python27")
  (add-path-to-execute-path "D:/Python27/Scripts")
  
  ;; org remember
  (setq org-directory "F:/kp/org")
  (setq org-remember-templates
  	'(("Todo" ?t "* TODO %i%?\n\n��: %U %a" "F:/kp/org/remember/TODO.org" "Tasks")
  	  ("IDEA" ?i "* IDEA %?\n %i\n %a" "F:/kp/org/remember/Idea.org" "Idea")
  	  ))
  (setq org-default-notes-file "F:/kp/org/remember/default.org")
  (setq org-agenda-files (list "F:/kp/org/remember/TODO.org")) ;;����ط�д��ᵼ��org-mode����������TODO����ʾ��ɫ
  ;; ;; ��վ
  ;; (setq website-org-path "F:/kp/org/website")
  ;; (setq website-org-publish-path (concat website-org-path "/public_html"))
  
  ;; (setq inferior-lisp-program "d:/green/sbcl/sbcl.exe")

  ;; Erlang, ��װĿ¼��Ҫ���ո�!
  ;; (setq load-path (cons "D:/erl5.9.3.1/lib/tools-2.6.8/emacs" load-path))
  ;; (setq erlang-root-dir "D:/erl5.9.3.1")
  ;; (setq exec-path (cons "D:/erl5.9.3.1/bin" exec-path))
					;(require 'erlang-start) ;; ������ûװ�Ļ����������
  ;; Distel  
  ;; (add-to-list 'load-path
  ;; 	       "D:/erl5.9.3.1/lib/distel/elisp")
  ;; everything
  (setq everything-procname "Everything.exe")
  
  )
 
 ;; 
 (t 
  ;; (setq org-remember-templates
  ;; 	'(("TODO" ?t "* TODO %?\n %x\n %a" "F:/org/remember.org" "Tasks")
  ;; 	  ("IDEA" ?i "* IDEA %?\n %i\n %a" "F:/org/remember.org" "Idea")
  ;; 	  ))
  ;; (setq org-default-notes-file "F:/org/.notes")
  t)
)
