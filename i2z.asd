;;;; i2z.asd

(asdf:defsystem #:i2z
  :description "Send Red Hat Access Insights notifications to Zabbix"
  :author "Anthony Green <green@redhat.com>"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :depends-on (#:drakma #:str #:cl-fad #:cl-toml #:cl-json #:cl-csv #:flexi-streams)
  :components ((:file "package")
               (:file "i2z")))

