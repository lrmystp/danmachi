(in-package :danmachi)

(define-class gamecharacter (gameobject)
  (hp 100)
  (muteki nil)
  (muteki-count 0)
  (muteki-time 10)
  (direction 'front))

(defmethod alive-detect ((char gamecharacter) game)
  (when (<= (hp char) 0)
    (kill char)))

(defmethod dec-muteki-frame ((chr gamecharacter))
  (if (and (muteki chr) (zerop  (muteki-count chr)))
      (setf (muteki chr) nil)
      (decf (muteki-count chr))))

(defmethod update ((chr gamecharacter) game)
  (call-next-method)
  (dec-muteki-frame chr)
  (alive-detect chr game)
  (change-direction chr game)
  (change-dire-image chr game)
  (when (out-of-gamearea-p chr game)
    (kill chr)))


(defmethod damage ((obj gameobject) (char gamecharacter))
  (when (not (muteki char))
    (decf (hp char) (atk obj))
    (setf (muteki char) t
	  (muteki-count char) (muteki-time char))))

(defmethod change-direction ((char gamecharacter) game)
  (when (direction-change-p char)
    (if (< (abs (vy char)) (abs (vx char)))
	(if (< 0 (vx char))
	    (setf (direction char) 'right)
	    (setf (direction char) 'left))
	(if (< 0 (vy char))
	    (setf (direction char) 'front)
	    (setf (direction char) 'back)))))

(defmethod direction-change-p ((char gamecharacter))
  (with-accessors ((vx vx) (vy vy)) char
    (and (some (compose #'not #'zerop) (list vx vy))
	 (not (case (direction char)
		(front (plusp vy))
		(back (minusp vy))
		(right (plusp vx))
		(left (minusp vx)))))))

(defmethod change-dire-image ((char gamecharacter) game)
  (case (direction char)
    (front (setf (image char) (get-image :player-front)))
    (back (setf (image char) (get-image :player-back)))
    (right (setf (image char) (get-image :player-right)))
    (left (setf (image char) (get-image :player-left)))))
