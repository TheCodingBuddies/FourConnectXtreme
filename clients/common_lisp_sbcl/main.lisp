;;;; main.lisp

(in-package #:c4x-bot)

;; Diese Funktion muss den Index der Column zurückgeben.
;; 0-6
(defun get-move (state)
  (let ((board (gethash "board" state))
        (bombs (gethash "bombs" state))
        (bot (gethash "bot" state))
        (coin-id (gethash "coin_id" state))
        (round (gethash "round" state)))
    ;; Hier die Logik einfügen.
    (format *standard-output* "Board:~%~A~%" board)
    (format *standard-output* "Bombs:~%~A~%" board)
    (format *standard-output* "Bot:~%~A~%" board)
    (format *standard-output* "CoinId:~%~A~%" board)
    (format *standard-output* "Round:~%~A~%" board)
    (finish-output))
  1)

(defun play-turn (name state)
  (when (string= name (gethash "bot" state))
    (let ((column (get-move state))
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
      (format t "~&Got PING from server.~%")
      (finish-output))))

(defvar *client* nil)
(defun start-client (port name)
  (setf *client* (wsd:make-client (format nil "ws://localhost:~D/~A" port name)))
  (wsd:start-connection *client*)
  (wsd:on :message *client* (lambda (msg) (handle-message *client* name msg))))

(defun end-client ()
  (wsd:close-connection *client*))

(defun main ()
  (let ((name nil)
        (port nil))
    (format *standard-output* "Bitte den Namen des Bots eingeben: ")
    (finish-output)
    (setf name (read))
    (format *standard-output* "Bitte den Port des Servers eingeben: ")
    (finish-output)
    (setf port (read))
    (start-client port name)
    (loop :for i :from 0
          :do (sleep 1))))

(defun create-executable (name)
  (setq uiop:*image-entry-point* #'main)
  (uiop:dump-image name :executable t))
