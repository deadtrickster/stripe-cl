(in-package :stripe)

(defmacro with-stripe-ssl-ctx (stripe &body body)
  `(cl+ssl:with-global-context ((stripe-ssl-ctx ,stripe))
     ,@body))

(defun stripe.request (path method params)
  (with-stripe-ssl-ctx *stripe*
    (multiple-value-bind (body status-code headers)
        (drakma:http-request #?"https://api.stripe.com/v1/${path}"
                             :basic-authorization (list (stripe-secret-key *stripe*) "")
                             :method method
                             :content (encode-parameters params)
                             :additional-headers '(("Stripe-Version" . "2016-03-07")))
      (if body
          (handler-case
              (setf body (yason:parse (babel:octets-to-string body)))
            (error ()
              (error 'stripe-generic-error :http-code status-code
                                           :response-body "Unable to decode non-empty body ~a" body)))
          (error 'stripe-generic-error :http-code status-code))

      (if(and (>= status-code 200)
              (< status-code 300))
         body
         (make-stripe-error status-code body headers)))))
