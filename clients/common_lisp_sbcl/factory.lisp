(in-package #:c4x-bot)

;; Hier werden die Evaluierungsfunktionen der Bots die via `defbot` registriert wurden
;; abgespeichert.
(defparameter *bot-registry*
  (make-hash-table :test 'equal))

(defun defbot (name get-move)
  (setf (gethash (string-upcase name) *bot-registry*) get-move))
