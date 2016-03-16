(in-package :stripe)

(define-condition stripe-error-base (error)
  ((http-code :initarg :http-code)))

(define-condition stripe-generic-error (stripe-error-base)
  ((response-body :initarg :response-body
                  :initform nil)))

(define-condition stripe-client-error (stripe-error-base)
  ((type :initarg :type)
   (message :initarg :message)
   (code :initarg :code)
   (param :initarg :param)
   (request-id :initarg :param)))

(define-condition stripe-error-bad-request (stripe-client-error)
  ())

(define-condition stripe-error-unauthorized (stripe-client-error)
  ())

(define-condition stripe-error-request-failed (stripe-client-error)
  ())

(define-condition stripe-error-not-found (stripe-client-error)
  ())

(define-condition stripe-error-conflict (stripe-client-error)
  ())

(define-condition stripe-error-rate-limit (stripe-client-error)
  ())

(define-condition stripe-server-error (stripe-error-base)
  ())

(defun get-stripe-client-error-type (status-code)
  (case status-code
    (400 'stripe-error-bad-request)
    (401 'stripe-error-unauthorized)
    (402 'stripe-error-request-failed)
    (404 'stripe-error-not-found)
    (409 'stripe-error-conflict)
    (429 'stripe-error-rate-limit)
    (t 'stripe-client-error)))

(defun make-stripe-client-error (type status-code response-body headers)
  (error type :http-code status-code
              :request-id (drakma:header-value "Request-Id" headers)
              :message (gethash "message" response-body)
              :code (gethash "code" response-body)
              :param (gethash "param" response-body)))

(defun make-stripe-error (status-code response-body headers)
  (cond
    ((and (>= status-code 400)
          (< status-code 500))
     (make-stripe-client-error (get-stripe-client-error-type status-code) status-code response-body headers))
    ((and (>= status-code 500)
          (< status-code 600))
     (error 'stripe-server-error :http-code status-code))
    (t (error "Wut?"))))

;; TODO: print conditions nicely
