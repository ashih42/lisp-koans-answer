;; EXTRA CREDIT:
;;
;; Create a program that will play the Greed Game.
;; Rules for the game are in GREED_RULES.TXT.
;;
;; You already have a DiceSet class and score function you can use.
;; Write a player class and a Game class to complete the project.  This
;; is a free form assignment, so approach it however you desire.

(defun print-scores (score-array)
    (loop for score across score-array
          for player from 0
          do (format t "~%Player ~a: ~a" player score))
    (format t "~%~%"))

(defun find-winner (score-array)
    (position (loop for score across score-array maximizing score)
              score-array))

(defun resolve-turn (score-array turn-id current-player num-players sudden-death-player)
    (if (eq current-player sudden-death-player)
            ;; game ended
            (let ((winner (find-winner score-array)))
                (fresh-line)
                (format t "Player ~a is WINNER with score ~a"
                        winner (aref score-array winner)))
            ;; game ongoing, sudden-death might or might not have started
            (progn (let ((temp-score (handle-roll
                                        turn-id
                                        current-player
                                        0
                                        5)))
                        (when (or (>= (aref score-array current-player) 300)
                                  (>= temp-score 300))
                            (incf (aref score-array current-player) temp-score)))
                    ;; print scores
                   (print-scores score-array)
                   ;; check if sudden death just kicked in
                   (if (and (null sudden-death-player)
                            (>= (aref score-array current-player) 3000))
                        (progn (fresh-line)
                            (format t "SUDDEN DEATH!!")
                            (resolve-turn
                                    score-array
                                    (1+ turn-id)
                                    (mod (1+ current-player) num-players)
                                    num-players
                                    current-player))
                        (resolve-turn
                            score-array
                            (1+ turn-id)
                            (mod (1+ current-player) num-players)
                            num-players
                            sudden-death-player)))))

(defun start-game (num-players)
    (if (and (integerp num-players)
             (> num-players 0))
        (resolve-turn (make-array num-players) 1 0 num-players nil)
        (princ "wtf mang")))

(defun roll-again? ()
    (fresh-line)
    (princ "Roll again? (y/n): ")
    (force-output)
    (eq (read) 'y))

(defun print-roll-outcome (turn-id player-id result acc-score score next-num-dice)
    (fresh-line)
    (format t "[Turn ~a] Player ~a rolled ~a and accumulated score ~a"
            turn-id
            player-id
            result
            (if (> score 0)
                acc-score
                0))
    (when (> score 0)
        (format t " (next roll ~a dice)" next-num-dice)))

;; Return acc-score
(defun handle-roll (turn-id player-id acc-score num-dice)
    (let ((result (roll num-dice)))
        (multiple-value-bind (score num-scoring-dice)
                             (get-score-and-num-scoring-dice result)
            (let ((next-num-dice (if (= num-dice num-scoring-dice)
                                    5
                                    (- num-dice num-scoring-dice))))
                (print-roll-outcome turn-id player-id result (+ acc-score score) score next-num-dice)
                (if (> score 0)
                    (if (roll-again?)
                        (handle-roll turn-id
                                    player-id
                                    (+ acc-score score)
                                    next-num-dice)
                        (+ acc-score score))
                    0)))))

(defun roll (num-dice)
    (loop repeat num-dice collect (1+ (random 6))))

(defun get-score-and-num-scoring-dice (result)
            ;; calculate score when num occurs as part of a match-3
    (flet ((score-triplet (num)
                (if (= num 1)
                    1000
                    (* num 100)))
            ;; calculate score when num occurs alone
           (score-singlet (num)
                (cond ((= num 1) 100)
                      ((= num 5) 50)
                      (t 0))))
        (let ((tab (make-hash-table))
              (score 0)
              (num-scoring-dice 0))
            ;; build hash table
            (loop for num in result
                do (push num (gethash num tab)))
            ;; iterate over values in each key, and add score to sum
            (maphash #'(lambda (key value)
                            (when (>= (length value) 3)
                                (setf value (cdddr value))
                                (incf score (score-triplet key))
                                (incf num-scoring-dice 3))
                            (incf score (* (score-singlet key) (length value)))
                            (when (or (= key 1) (= key 5))
                                (incf num-scoring-dice (length value))))
                     tab)
            (values score num-scoring-dice))))
