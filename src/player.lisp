(in-package :danmachi)

;;player object
(define-class player (gamecharacter)
  (player-speed 5)
  (width 64)
  (height 64)
  move-floor  ;kari
  (image (get-image :player_front)))

(defmethod add-object ((p player) (game game))
  (if (player game)
      (with-accessors ((x point-x) (y point-y)) (player game)
	(setf x (point-x p)
	      y (point-y p))
	(pushnew (player game) (object-list game)))
      (progn
	(setf (player game) p)
	(call-next-method))))

(defmethod update ((p player) (game game))
  (with-accessors ((vx vx) (vy vy) (x point-x) (y point-y)
		   (speed player-speed) (move-floor move-floor)) p
    (with-slots (up down right left z) (keystate game)
      (cond ((key-pressed-p right) (setf vx speed))
	    ((key-pressed-p left)  (setf vx (- speed)))
	    (t (setf vx 0)))
      (cond ((key-pressed-p up)   (setf vy (- speed)))
	    ((key-pressed-p down) (setf vy speed))
	    (t (setf vy 0)))
      (cond ((key-down-p z) (attack p game))))
    
    ;; slanting move
    (when (and (/= vx 0) (/= vy 0))
      (setf vx (/ vx (sqrt 2))
	    vy (/ vy (sqrt 2))))
   ;;kari
    (when move-floor
      (push-state
       (case move-floor
	 (:up '(:init-map "large.map"))
	 (:down '(:init-map "large2.map"))) game)
      (setf move-floor nil))
    ;;
  (call-next-method)))

(defmethod attack ((p player) (game game))
  (add-object (make-instance 'player-attack) game))

(define-class player-attack (bullet)
  (width 16)
  (height 32)
  (atk 50)
  (time-limit (make-timer 10)))

(defmethod update ((patk player-attack) (game game))
  (call-next-method)
  (when (funcall (time-limit patk))
    (kill patk)))

(defmethod attack ((p player) (game game))
  (add-object (make-instance 'player-attack
			     :vx 0
			     :vy 0
			     :point-x (point-x p)
			     :point-y (+ (point-y p) (height p)))
	      game))
