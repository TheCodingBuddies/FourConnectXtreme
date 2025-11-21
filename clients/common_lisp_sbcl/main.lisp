;;;; main.lisp

(in-package #:c4x-bot)

(defun main ()
  (let* ((args sb-ext:*posix-argv*)
         (name (string-upcase (nth 1 args)))
         (host (nth 2 args)))
    (format t "~A" args)
    (when (null (gethash name *bot-registry*))
      (error (format nil "Bot with name ~A not registered." name)))
    (start-client host name)
    (loop :for i :from 0
          :do (sleep 1))))
