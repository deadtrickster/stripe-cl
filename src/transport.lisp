(in-package :stripe)

(cl-interpol:enable-interpol-syntax)

(defmacro with-stripe-ssl-ctx (stripe &body body)
  `(cl+ssl:with-global-context ((stripe-ssl-ctx ,stripe))
     ,@body))

(defun stripe.request% (path method params idempotency-key)
  (let ((headers (if idempotency-key
                     `(("Stripe-Version" . "2016-03-07")
                       ("Idempotency-Key" . ,idempotency-key))
                     '(("Stripe-Version" . "2016-03-07"))))
        (query-params (when (member method '(:get :head :delete))
                        (concatenate 'string "?" (encode-parameters params)))))
    (with-stripe-ssl-ctx *stripe*
      (multiple-value-bind (body status-code headers)
          (drakma:http-request #?"https://api.stripe.com/v1/${path}${query-params}"
                               :basic-authorization (list (stripe-secret-key *stripe*) "")
                               :method method
                               :content (unless query-params (encode-parameters params))
                               :additional-headers headers)
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
           (make-stripe-error status-code body headers))))))

(defun stripe.request (path method params)
  (let* ((max-retries (slot-value *stripe* 'max-retries))
         (retry-delay (slot-value *stripe* 'retry-delay))
         (max-retry-delay (slot-value *stripe* 'max-retry-delay))
         (retries-counter 0)
         (idempotency-key (when (and (or (eql method :post)
                                         (eql method :delete))
                                     (> max-retries 0))
                            (princ-to-string (uuid:make-v4-uuid))))
         (response))
    (tagbody
     :start
       (flet ((maybe-retry (e)
                          (log:error "Error while calling Stripe API ~a" e)
                          (when (> max-retries retries-counter)
                            (log:info "Retrying after ~a seconds" retry-delay)
                            (sleep retry-delay)
                            (incf retries-counter)
                            (when (> max-retry-delay retry-delay)
                              (incf retry-delay retry-delay))
                            (go :start))))
         (handler-bind ((usocket:socket-error #'maybe-retry)
                        (usocket:ns-error #'maybe-retry))
           (setf response (stripe.request% path method params idempotency-key)))))
    response))
