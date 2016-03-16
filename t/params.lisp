(assert (equal "card[address]=evergreen%20str&ewq=1.2&qwe=1"
               (encode-parameters {i
                   "qwe" 1
                   "ewq" 1.2
                   "card" {i
                      "address" "evergreen str"
                     }
                 })))

(assert (equal "a=3&b=%2Bfoo%3F&c=bar%26baz&d[a]=a&d[b]=b&e[]=0&e[]=1&f="
               (encode-parameters {i
                   "a" 3
                   "b" "+foo?"
                   "c" "bar&baz"
                   "d" {i
                       "a" "a"
                       "b" "b"
                     }
                   "e" #(0 1)
                   "f" ""
                   "g" #()
                 })))

(assert (equal "a=3&e[]=0&e[]=1"
               (encode-parameters '(("a".  3)
                                    ("e" . (0 1))))
