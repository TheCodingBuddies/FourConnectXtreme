;;;; common_lisp_sbcl.asd

(asdf:defsystem #:c4x-bot
  :description "The client for the Connect4 Extreme tournament."
  :author "Timo Netzer <ecso@ecsodikas.eu>"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :depends-on (:clack
               :websocket-driver-client
               :yason)
  :components ((:file "package")
               (:file "factory")
               (:file "bots")
               (:file "core")
               (:file "main")))
