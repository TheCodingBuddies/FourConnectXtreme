(in-package #:c4x-bot)

(defun play-turn (name state)
  (when (string= name (gethash "bot" state))
    (let ((column (funcall (gethash name *bot-registry*) state))
          (hash-table (make-hash-table)))
      (setf (gethash "state" hash-table) "play")
      (setf (gethash "column" hash-table) column)
      (yason:with-output-to-string* ()
        (yason:encode hash-table)))))

(defun handle-message (client name message)
  (handler-case
      (let ((state (yason:parse (babel:octets-to-string message :encoding :utf-8))))
        (wsd:send client (play-turn name state)))
    (error ()
      (format t "~%~&Got PING from server.~%")
      (finish-output))))

(defvar *client* nil)

(defun start-client (host name)
  (setf *client* (wsd:make-client (format nil "ws://~A/~A" host name)))
  (format t "~%Trying to connect to ~A~%" host)
  (wsd:start-connection *client*)
  (wsd:on :message *client* (lambda (msg) (handle-message *client* name msg))))

(defun end-client ()
  (wsd:close-connection *client*))
