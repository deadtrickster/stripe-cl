(asdf:defsystem :stripe-cl
  :serial t
  :version "0.0.1"
  :license "MIT"
  :depends-on ("alexandria" "drakma" "ia-hash-table" "uuid" "log4cl")
  :author "Ilya Khaprov <ilya.khaprov@publitechs.com>"
  :components ((:module "src"
                :serial t
                :components
                ((:file "package")
                 (:file "errors")
                 (:file "params")
                 (:file "stripe")
                 (:file "transport")
                 (:file "charges"))))
  :description "Stripe API in Common Lisp")
