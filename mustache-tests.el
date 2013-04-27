(require 'mustache)
(require 'ert)
(require 'ht)

(ert-deftest mustache-test-simple-string ()
  (should (equal "foo" (mustache-render "foo" nil))))

(ert-deftest mustache-test-variable ()
  (let ((context (ht ("blah" "bar"))))
    (should
     (equal
      "foo bar"
      (mustache-render "foo {{blah}}" context)))))

(ert-deftest mustache-test-variable-missing ()
  (let ((context (ht-create)))
    (should
     (equal
      "foo "
      (mustache-render "foo {{blah}}" context)))))

(ert-deftest mustache-test-section-inner-whitespace ()
  (should
   (equal
    "="
    (mustache-render "{{# boolean }}={{/ boolean }}" (ht ("boolean" t))))))

(ert-deftest mustache-test-standalone-lines ()
  (should
   (equal "| This Is
|
| A Line
"
    (mustache-render "| This Is
{{#boolean}}
|
{{/boolean}}
| A Line
" (ht ("boolean" t))))))

(ert-deftest mustache-test-extra-section-close ()
  (should-error
   (mustache-render "{{/blah}}" (ht-create))))

(ert-deftest mustache-test-extra-section-open ()
  (should-error
   (mustache-render "{{#blah}}" (ht-create))))

(ert-deftest mustache-test-mismatched-section-close ()
  (should-error
   (mustache-render "{{#blah}}{{/foo}}" (ht-create))))

(ert-deftest mustache-test-variable-escaped ()
  (let ((context (ht ("blah" "<bar> &baz ' \""))))
    (should
     (equal
      "&lt;bar&gt; &amp;baz &#39; &quot;"
      (mustache-render "{{blah}}" context)))))

(ert-deftest mustache-test-section-hash ()
  (let ((context (ht ("user"  (ht ("name" "bob"))))))
    (should
     (equal
      "bob"
      (mustache-render "{{#user}}{{name}}{{/user}}" context)))))

(ert-deftest mustache-test-section-hash-nested ()
  (let ((context (ht
                  ("foo" "bar")
                  ("user"  (ht ("name" "bob"))))))
    (should
     (equal
      "barbob"
      (mustache-render "{{#user}}{{foo}}{{name}}{{/user}}" context)))))

(ert-deftest mustache-test-section-list ()
  (let ((context (ht ("users" (list (ht ("name" "bob"))
                                    (ht ("name" "chris")))))))
    (should
     (equal
      "bobchris"
      (mustache-render "{{#users}}{{name}}{{/users}}" context)))))

(ert-deftest mustache-test-section-with-vector ()
  "Vectors should behave the same as a list in a context."
  (let ((context (ht ("users" `[,(ht ("name" "bob"))
                                ,(ht ("name" "chris"))]))))
    (should
     (equal
      "bobchris"
      (mustache-render "{{#users}}{{name}}{{/users}}" context)))))

(ert-deftest mustache-test-unescaped ()
  (let ((context (ht ("blah" "<bar>"))))
    (should
     (equal
      "<bar>"
      (mustache-render "{{& blah}}" context)))))

(ert-deftest mustache-test-triple-mustache ()
  (let ((context (ht ("blah" "<bar>"))))
    (should
     (equal
      "<bar>"
      (mustache-render "{{{blah}}}" context)))))

(ert-deftest mustache-test-conditional-true ()
  (let ((context (ht ("yes" 't))))
    (should
     (equal
      "foo bar"
      (mustache-render "foo {{#yes}}bar{{/yes}}" context)))))

(ert-deftest mustache-test-conditional-false ()
  (let ((context (ht ("no" nil))))
    (should
     (equal
      "foo "
      (mustache-render "foo {{#no}}bar{{/no}}" context)))))

(ert-deftest mustache-test-inverted ()
  (let ((context (ht ("no" nil))))
    (should
     (equal
      "foo bar"
      (mustache-render "foo {{^no}}bar{{/no}}" context)))))

(ert-deftest mustache-test-comment ()
  (let ((context (ht-create)))
    (should
     (equal
      ""
      (mustache-render "{{! whatever}}" context)))))

(defun mustache-run-tests ()
  (interactive)
  (ert-run-tests-interactively "mustache-test-"))

(provide 'mustache-tests)
;;; mustache-tests.el ends here
