(in-package :danmachi)

(defun init-game (game)
  (set-nil (object-list game)
	   (floor-list game)
	   (player game))
  (pop-state game))

;;新しいマップ突入時の初期化

(defun get-mapfile-name (game)
  (concatenate 'string "floor"
	       (to-s (map-id game)) ".map"))

(defun init-map (game)
  (set-nil (object-list game)
	   (floor-list game))
  (load-map (get-mapfile-name game) game)
  (pop-state game))

(defun gaming-state (game)
  (sdl:clear-display sdl:*black*)
  (update-camera game)  
  (update-game game)
  (round-robin (lambda (obj1 obj2)
		 (collide obj1 obj2 game))
	       (object-list game))
  (unless (alive (player game))
    (pop-state game)
    (push-state :gameover game))
  (draw-game game))

(defun title-state (game)
  (with-slots (up down left right z)
      (keystate game)
    (sdl:clear-display sdl:*black*)
    (sdl:draw-string-solid-* "楽しい人生"
			     30 30)
    (when (key-down-p z)
      (pop-state game)
      (push-stateset '(:init-game
		       :init-map
		       :game)
		     game))))

(defun gameover-state (game)
  (with-slots (up down left right z)
      (keystate game)
    (sdl:draw-string-solid-* "gameover"
			     200 150)
    (when (key-down-p z)
      (pop-state game)
      (push-state :title game))))


(let* ((cursor 0)
       (contents-table
	'("equip" "item"))
       (menu-size
	(length contents-table)))
  (defun menu-index-state (game)
    (with-slots (up down z x)
	(keystate game)
      (sdl:clear-display sdl:*black*)
      (sdl:draw-string-solid-* "menu index"
			       30 30)
      (loop for i
	 from 0 below menu-size
	 do (sdl:draw-string-solid-*
	     (nth i contents-table)
	     100
	     (+ (* i 30) 50)))
      (sdl:draw-string-solid-* "->"
	     70 (+ (* cursor 30) 50))
      (whens
	((key-down-p up)
	 (setf cursor
	       (mod (1- cursor) menu-size)))
	((key-down-p down)
	 (setf cursor
	       (mod (1- cursor) menu-size)))
	((key-down-p x) (pop-state game))
	((key-down-p z)
	 (case cursor
	   (0 (push-state :select-equip game))
	   (1 (push-state :item-table game))))))))

(defun select-equip-state (game)
  (with-slots (x) (keystate game)
    (sdl:clear-display sdl:*black*)
    (sdl:draw-string-solid-* "select equip"
			     30 30)
    (when (key-down-p x)
      (pop-state game))))

(let ((namelist nil)
      (size nil)
      (topindex nil)
      (cursor nil))
  (defun init-expendmenu (expend-list)
    (setf namelist
	  (loop for i below (length expend-list) by 2
	     collect (nth i expend-list))
	  size (length namelist)))
  (defun item-table-state (game)
    (with-slots (expend-list) (player game)
      (sdl:clear-display sdl:*black*)
      (when (and (null namelist)
		 (not (null expend-list)))
	(init-expendmenu expend-list)
	(setf topindex 0
	      cursor 0))
      (with-slots (z x down up) (keystate game)
	(unless (null namelist)
	  (cond ((key-down-p down)
		 (setf cursor (clamp (1+ cursor) 0 (1- size))))
		((key-down-p up)
		 (setf cursor (clamp (1- cursor) 0 (1- size)))))
	  (when (key-down-p z)
	    (let ((itemsym (nth cursor namelist)))
	      (funcall (effect (get-item itemsym)) game)
	      (decf (getf expend-list itemsym))
	      (when (zerop (getf expend-list itemsym))
		(remf expend-list itemsym)
		(init-expendmenu expend-list)
		(setf cursor (max 0 (1- cursor))))))
	  (cond ((< cursor topindex) (decf topindex))
		((> cursor (+ topindex 10)) (incf topindex)))
	  (loop for i from topindex below (min (- size topindex) 10)
	     do (let ((itemsym (nth i namelist)))
		  (sdl:draw-string-solid-* (name (get-item itemsym))
					   50 (+ (* (- i topindex) 20)
						 10))
		  (sdl:draw-string-solid-* (to-s (getf expend-list itemsym))
					   180 (+ (* (- i topindex) 20)
					      10)))
	  (sdl:draw-string-solid-* "->"
				   0 (+ (* (- cursor topindex) 20) 10))))
	(when (key-down-p x)
	  (pop-state game))))))

(defun push-text-state (filename game)
  (let ((lines nil)
	(size nil))
    (with-open-file (stream (lib-path filename))
      (iter (for l in-stream stream using #'read-line)
	    (push l lines)))
    (setf lines (reverse lines)
	  size (length lines))
    (push-stateset (loop for i below size by 4 collect
			(list :display-text
			      (loop for j
				 below (min 4 (- size i))
				 collect (nth (+ i j) lines))))
		   game)))

(defun display-text-state (strlist game)
    (with-slots (c) (keystate game)
      (sdl:draw-box-* 0 300 640 180
		      :color sdl:*black*)
      (loop for i below (length strlist) do
	   (let ((str (nth i strlist)))
	     (unless (string= str "")
	       (sdl:draw-string-solid-* str
					20 (+ 320 (* i 40))))))
      (when (key-down-p c)
	(pop-state game))))


(defvar *state-func-table* nil)

(defun load-state-func ()
    (setf *state-func-table*
     (list :title #'title-state
	   :gameover #'gameover-state
	   :init-game #'init-game
	   :init-map #'init-map
	   :game #'gaming-state
	   :menu-index #'menu-index-state
	   :select-equip #'select-equip-state
	   :item-table #'item-table-state
	   :display-text #'display-text-state)))

(defun run-state (game)
  (if (null (state-stack game))
      (error "state-stack is empty")
      (let* ((state-sym (caar (state-stack game)))
	     (state-arg (cdar (state-stack game)))
	     (state-func (getf *state-func-table*
			       state-sym)))
	(if (null state-func)
	    (error "undefined state")
	    (apply state-func (append state-arg (list game)))))))

