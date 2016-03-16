## Stripe API client in Common Lisp

Only charge/capture for now

```lisp
CL-USER> (let ((charge (stripe:charge.create {
                                               "amount" 400
                                                "currency" "usd"
                                                "source"  {
                                                  "exp_month" 12
                                                  "exp_year" 17
                                                  "number" "4242424242424242"
                                                  "object" "card"
                                                  "cvc" "123"
                                                }
                                                "description" "My Test charge"
                                                "capture" nil
                                               })))
  (gethash "description" (stripe:charge.capture charge)))
"My Test charge"
T
CL-USER>
```


## License
MIT
