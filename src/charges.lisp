(in-package :stripe)

(cl-interpol:enable-interpol-syntax)

(defun charges.list (&optional params)
  (stripe.request "charges"
                  :get
                  params))

(defun charge.create (params)
  (stripe.request "charges"
                  :post
                  params))

(defun charge.capture (charge)
  (let ((charge-id (or (and (stringp charge)
                            charge)
                       (gethash "id" charge))))
    (stripe.request #?"charges/${charge-id}/capture"
                    :post
                    nil)))
