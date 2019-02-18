;;;; i2z.lisp

(in-package #:i2z)

(defvar *config-file-name* "./config.ini")
(defvar *config* nil)

(defun get-config (value)
  (let ((v (gethash value *config*)))
    (unless v
      (error "ERROR: missing config setting ~A" value))
    v))

(defun read-file-into-string (filename)
  (with-open-file (stream filename :external-format :UTF-8)
    (let ((contents (make-string (file-length stream))))
      (read-sequence contents stream)
      contents)))

(defun main (args)
  
  ;; Read the user configuration settings.
  (setf *config*
	(if (fad:file-exists-p *config-file-name*)
	    (cl-toml:parse
	     (read-file-into-string *config-file-name*))
	    (make-hash-table)))

  (let ((redhat-access-username (get-config "redhat-access-username"))
	(redhat-access-password (get-config "redhat-access-password"))
	(zabbix-username (get-config "zabbix-username"))
	(zabbix-password (get-config "zabbix-password"))
	(zabbix-url
	  (let ((url (get-config "zabbix-url")))
	    (if (str:ends-with? "/" url)
		url
		(str:concat url "/")))))

    (multiple-value-bind (result code)
	(drakma:http-request (str:concat zabbix-url "api_jsonrpc.php")
			     :method :post
			     :content-type "application/json-rpc"
			     :content
			     (json:encode-json-alist-to-string
			      '((:id . 1)
				(:jsonrpc . "2.0")
				(:method . "user.login")
				(:params
				 (:user . zabbix-username)
				 (:password . zabbix-password))
				(:auth . nil)))))
    
    (let ((result-string (flexi-streams:octets-to-string result)))
      (print result-string))
    
    (multiple-value-bind (result code)
	(drakma:http-request "https://access.redhat.com/r/insights/v3/exports/reports"
			     :basic-authorization '(redhat-access-username
						    redhat-access-password))
      
      (let* ((csv (cl-csv:read-csv result
				   :trim-outer-whitespace t)))
	(loop for row in (cdr csv)
	      
	      do (print row)))))
  
