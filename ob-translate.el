;;; ob-translate.el --- Translation of text blocks in org-mode.
;; Copyright 2013 Kris Jenkins

;; Author: Kris Jenkins <krisajenkins@gmail.com>
;; Maintainer: Kris Jenkins <krisajenkins@gmail.com>
;; Keywords: org babel translate translation
;; URL: https://github.com/krisajenkins/ob-translate
;; Created: 16th July 2013
;; Version: 0.1.0
;; Package-Requires: ((google-translate "0.4") (org "8"))

;;; Commentary:
;;
;; Supports translation of text blocks in org-mode.

;;; Code:
(require 'ob)
(require 'google-translate)

(defgroup ob-translate nil
  "Translate org-mode blocks."
  :group 'org)

(defcustom ob-translate:default-src "auto"
  "Default language to translate from."
  :group 'ob-translate
  :type 'string)

(defcustom ob-translate:default-dest "en"
  "Default language to translate to."
  :group 'ob-translate
  :type 'string)

(defun ob-translate:google-translate (text src dest)
  "Translate TEXT from the SRC langauge to the DEST language."
  (let* ((text-stripped (replace-regexp-in-string "[[:space:]\n\r]+" " " text))
		 (json (json-read-from-string
				(google-translate-insert-nulls
				 ;; Google Translate won't let us make a request unless we
				 ;; send a "User-Agent" header it recognizes.
				 ;; "Mozilla/5.0" seems to work.
				 (let ((url-request-extra-headers
						'(("User-Agent" . "Mozilla/5.0"))))
				   (google-translate-http-response-body
					(google-translate-format-request-url
					 `(("client" . "t")
					   ("ie"     . "UTF-8")
					   ("oe"     . "UTF-8")
					   ("sl"     . ,src)
					   ("tl"     . ,dest)
					   ("text"   . ,text-stripped))))))))
		 (text-phonetic (mapconcat #'(lambda (item) (aref item 3))
								   (aref json 0) ""))
		 (translation (mapconcat #'(lambda (item) (aref item 0))
								 (aref json 0) ""))
		 (translation-phonetic (mapconcat #'(lambda (item) (aref item 2))
										  (aref json 0) ""))
		 (dict (aref json 1)))
	translation))

;;;###autoload
(defun org-babel-execute:translate (text params)
  "org-babel translation hook."
  (let* ((src (or (cdr (assoc :src params))
				  ob-translate:default-src))
		 (dest (or (cdr (assoc :dest params))
				   ob-translate:default-dest)))
	(ob-translate:google-translate text src dest)))

(provide 'ob-translate)

;;; ob-translate.el ends here
