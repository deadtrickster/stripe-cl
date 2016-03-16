(in-package :stripe)

(defvar *stripe*)

(defclass stripe ()
  ((secret-key :initarg :secret-key :reader stripe-secret-key)
   (ssl-ctx :initarg :ssl-ctx :reader stripe-ssl-ctx) ;; TODO: or maybe use one global context
   ))

(defun make-stripe-ssl-ctx ()
  (cl+ssl:make-context))

(defun make-stripe (secret-key)
  (let* ((ssl-ctx (make-stripe-ssl-ctx))
         (stripe (make-instance 'stripe :secret-key secret-key :ssl-ctx ssl-ctx)))
    (trivial-garbage:finalize stripe (lambda () (cl+ssl:ssl-ctx-free ssl-ctx)))))
