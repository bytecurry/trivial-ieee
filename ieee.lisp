(defpackage trivial-ieee
  (:nicknames :ieee)
  (:use :cl
        #-(or sbcl clozure) :cffi)
  (:export #:without-fp-traps
           #:disable-fp-traps
           #:fp-rounding-mode

           #:+inf+
           #:+neg-inf+
           #:+nan+

           #:infinity-p
           #:nan-p))
(in-package trivial-ieee)

(defconstant +fp-traps+ '(:underflow :overflow :inexact :invalid :divide-by-zero))

#+sbcl
(progn
  (defmacro without-fp-traps (&body body)
    `(sb-int:with-float-traps-masked ,+fp-traps+
       ,@body))

  (defun disable-fp-traps ()
    (sb-int:set-floating-point-modes :traps nil))

  (defun fp-rounding-mode ()
    (getf (sb-int:get-floating-point-modes) :rounding-mode))
  (defun (setf fp-rounding-mode) (new-mode)
    (sb-int:set-floating-point-modes :rounding-mode new-mode))

  (setf (symbol-function 'infinity-p) (function sb-ext:float-infinity-p))
  (setf (symbol-function 'nan-p) (function sb-ext:float-nan-p))

  (define-symbol-macro +inf+ 'sb-ext:single-float-positive-infinity)
  (define-symbol-macro +neg-inf+ 'sb-ext:single-float-negative-infinity)
  (defconstant +nan+ (sb-kernel:make-single-float -1)))

#+clozure
(progn
  (defun disable-fp-traps ()
    (ccl:set-fpu-mode :underflow nil :overflow nil :inexact nil :invalid nil :division-by-zero nil))

  (defmacro without-fp-traps (&body body)
    (let ((old (gensym)))
      `(let ((,old (ccl:get-fpu-mode)))
         (unwind-protect
              (progn
                (disable-fp-traps)
                ,@body)
           (apply #'ccl:set-fpu-mode ,old)))))



  (defun fp-rounding-mode ()
    (ccl:get-fpu-mode :rounding-mode))
  (defun (setf fp-rounding-mode) (new-mode)
    (ccl:set-fpu-mode :rounding-mode new-mode)
    new-mode)

  (defconstant +inf+ 1E++0)
  (defconstant +neg-inf+ -1E++0)
  (defconstant +nan+ 1E+-0))

#+ecl
(progn
  (defun disable-fp-traps ()
    ;; no-op because they are already disabled
    nil)
  (defmacro without-fp-traps (&body body)
    ;; just a progn, because they are already disabled
    `(progn ,@body))

  (ffi:def-function "fegetround" () :returning :int)
  (ffi:def-function "fesetround" ((mode :int)) :returning :int)

  (defun fp-rounding-mode ()
    (let ((mode (fegetround)))
      (cond
        ((= 1 mode :nearest))
        ((= 0 mode) :zero)
        ((= 2 mode) :positive-infinity)
        ((= 3 mode) :negative-infinity))))
  (defun (setf fp-rounding-mode) (new-mode)
    (fesetround (ecase new-mode
                  (:nearest 1)
                  (:zero 0)
                  (:positive-infinity 2)
                  (:negative-infinity 3)))
    new-mode)

  (defconstant +inf+ (* 2 most-positive-long-float))
  (defconstant +neg-inf+ (* 2 most-negative-long-float))
  (defconstant +nan+ (/ 0l0 0l0)))

;;; For unsupported implementations, just make everything a no-op
#-(or sbcl clozure ecl)
(progn
  (eval-when (:compile-toplevel :load-toplevel)
    (defun %warn-unsupported ()
      (warn "trivial-ieee dosn't support this implementation yet"))
    (%warn-unsupported))

  ;; maybe we could use ffi, but
  ;; I don't know if that would work.
  (defmacro without-fp-traps (&body body)
    `(progn ,@body))

  (defun fp-rounding-mode ()
    :nearest)
  (defun (setf fp-rounding-mode) (new-mode)
    (%warn-unsupported)
    new-mode)

  (defun disable-fp-traps ()
    (%warn-unsupported))

  (defparameter +inf+ most-positive-single-float)
  (defparameter +neg-inf+ most-negative-single-float)
  (defparameter +nan+ -0.0))

#-sbcl
(defun infinity-p (value)
  (or (> value most-positive-long-float)
      (< value most-negative-long-float)))

#-sbcl
(defun nan-p ()
    (/= +nan+ +nan+))

(setf (documentation 'without-fp-traps 'function)
      "Execute BODY with all floating point traps disabled.")
(setf (documentation 'disable-fp-traps 'function)
      "Globally disablefloating point traps. Note that there isn't a portable
way to turn them back on.")
(setf (documentation 'fp-rounding-mode 'function)
      "Accessor for the IEEE floating point rounding mode. Can be one of
:nearest :zero :positive or :negative")
(setf (documentation 'infinity-p 'function)
      "Test if a value is an IEEE infinity value.")
(setf (documentation 'nan-p 'function)
      "Test if value is 'Not a Number'")
(setf (documentation '+inf+ 'variable)
      "A float that represents positive infinity")
(setf (documentation '+neg-inf+ 'variable)
      "A float that represents negative infinity")
(setf (documentation '+nan+ 'variable)
      "A float containing a NAN value.")

#+(or sbcl clozure ecl)
(push :trivial-ieee *features*)
