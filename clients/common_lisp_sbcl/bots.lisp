(in-package #:c4x-bot)

;; Hier können Bots implementiert werden. Die Bots werden ganz einfach mit der
;; defbot Funktion erzeugt. Die lambda Funktion bekommt einen Parameter übergeben, dass ist der
;; aktuelle Spielstand. Dabei handelt es sich um eine Hash Table mit den Werten:
;; - board
;; - bombs
;; - bot name
;; - coin-id
;; - round number

;; Beispiel für einen Bot der den State dumped und random Moves spielt.
(defbot "Dumpling" 
  (lambda (state)
    (let ((board (gethash "board" state))
          (bombs (gethash "bombs" state))
          (bot (gethash "bot" state))
          (coin-id (gethash "coin_id" state))
          (round (gethash "round" state)))
      (format *standard-output* "~%Board:~%~A~%" board)
      (format *standard-output* "~%Bombs:~%~A~%" bombs)
      (format *standard-output* "~%Bot:~%~A~%" bot)
      (format *standard-output* "~%CoinId:~%~A~%" coin-id)
      (format *standard-output* "~%Round:~%~A~%" round)
      (finish-output))
    (random 7))) 

;; Beispiel für einen Bot der immer in Index 0 wirft
(defbot "FirstIsKey" (lambda (state)
                       (declare (ignore state))
                       0))

