;;;; package.lisp

(defpackage #:sdlutils
  (:use #:cl #:alexandria #:iterate)
  (:export ROUND-ROBIN 
	   SLOT-LIST 
	   NMAPSLOT 
	   TO-S 
	   MAKE-TIMER
	   CHARGE-TIMER 
	   PRINT-IF 
	   DEFINE-CLASS 
	   WHENS 
	   DEFINTERACT-METHOD
	   DEFCOLLIDE 
	   PMIF 
	   ALAMBDA 
	   LETREC 
	   WHILE 
	   DBIND 
	   KEY-PRESSED-P 
	   KEY-DOWN-P
	   KEY-UP-P 
	   update-key-state
	   next-key-state
	   update-joy-state
	   update-input
	   DEFKEYSTATE 
	   DEFJOYSTICK 
	   AXIS-VALUE-MINUS-P
	   AXIS-VALUE-PLUS-P 
	   AXIS-VALUE-MIDDLE-P 
	   NEW-JOYSTICK 
	   DEFINPUT 
	   RAD
	   VEC-ABS
	   EUC-DIST
	   UNIVEC
	   DIR-UNIVEC
	   A-TO-B-VECTOR
	   DISTANCE
	   UVEC
	   LOAD-PNG-IMAGE
	   LOAD-IMAGE
	   LOAD-ANIMATION
	   LOAD-IMAGES
	   LOAD-ANIMATIONS
	   GET-IMAGE
	   GET-IMAGE-LIST))
