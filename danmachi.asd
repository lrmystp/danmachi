;;;; danmachi.asd


;; To load eval (require :danmachi)
;; To reload eval (asdf:operate 'asdf:load-op :danmachi)

(asdf:defsystem #:danmachi
  :description "Describe danmachi here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :serial t
  :components ((:file "package")
	       (:file "move")
               (:file "danmachi"))
  :depends-on (:lispbuilder-sdl :alexandria :closer-mop :split-sequence :iterate))
