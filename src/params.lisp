(in-package :stripe)

(cl-interpol:enable-interpol-syntax)

(defun escape (str &optional (safe "/"))
  "URI encodes/escapes the given string."
  (with-output-to-string (s)
    (loop for c across (flexi-streams:string-to-octets str :external-format :utf-8)
          do (if (or (find (code-char c) safe)
                     (<= 48 c 57)
                     (<= 65 c 90)
                     (<= 97 c 122)
                     (find c '(45 95 46 126)))
                 (write-char (code-char c) s)
                 (format s "%~2,'0x" c)))))

(defun join (delimiter strings)
  (when strings
    (reduce (lambda (a b)
              (concatenate 'string a (string delimiter) b))
            strings)))

(defun encode-key (key)
  (assert (stringp key) nil "Key must be string, got: ~a" key)
  (escape key "[]"))

(defmethod encode-value ((value string))
  (escape value ""))

(defmethod encode-value ((value integer))
  (princ-to-string value))

(defmethod encode-value ((value float))
  (princ-to-string value))

(defmethod encode-value ((value (eql t)))
  "true")

(defmethod encode-value ((value (eql nil)))
  "false")

(defmethod encode-value ((value (eql :false)))
  "false")

(defun flatten-params (ht &optional parent-key)
  (when (listp ht)
    (setf ht (ia-hash-table:alist-ia-hash-table ht)))
  (collectors:with-appender-output (add-param)
    (let ((sorted-keys (sort (alexandria:hash-table-keys ht) #'string<=)))
      (loop for key in sorted-keys
            as value = (gethash key ht)
            as ckey = (if parent-key #?"${parent-key}[${key}]" key) do
               (typecase value
                 (hash-table
                  (apply #'add-param (flatten-params value ckey)))
                 ((and vector (not string))
                  (apply #'add-param (flatten-params-array value ckey)))
                 (t
                  (add-param (list ckey value))))))))

(defun flatten-params-array (vector ckey)
  (collectors:with-appender-output (add-param)
    (loop for item across vector do
             (typecase item
               (hash-table
                (apply #'add-param (flatten-params item #?"${ckey}[]")))
               ((and vector (not string))
                (apply #'add-param (flatten-params-array item ckey)))
               (t
                (add-param (list #?"${ckey}[]" item)))))))

(defun encode-parameters (params)
  (let ((flatten-params (flatten-params params)))
    (join "&" (loop for (key value) on flatten-params by #'cddr
                    collect (format nil "~a=~a"
                                    (encode-key key)
                                    (encode-value value))))))
