(in-package :stripe)

(defvar *stripe*)

(defclass stripe ()
  ((secret-key :initarg :secret-key :reader stripe-secret-key)
   (max-retries :initarg :max-retries)
   (max-retry-delay :initarg :max-retry-delay)
   (retry-delay :initarg :retry-delay)
   (ssl-ctx :initarg :ssl-ctx :reader stripe-ssl-ctx) ;; TODO: or maybe use one global context
   ))

(defun make-stripe (secret-key &key (ssl-options '(:verify-location :default)) (max-retries 0) (max-retry-delay 10) (retry-delay 2))
  (let* ((ssl-ctx (apply #'cl+ssl:make-context ssl-options))
         (stripe (make-instance 'stripe :secret-key secret-key
                                        :ssl-ctx ssl-ctx
                                        :max-retries max-retries
                                        :max-retry-delay max-retry-delay
                                        :retry-delay retry-delay)))
    (trivial-garbage:finalize stripe (lambda () (cl+ssl:ssl-ctx-free ssl-ctx)))))
