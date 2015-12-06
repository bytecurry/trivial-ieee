(in-package :asdf-user)

(defsystem "trivial-ieee"
  :author "Thayne McCombs"
  :description "Compatibility layer for IEEE features."
  :version "0.1.0"
  :components ((:file "ieee"))
  :long-description #.(uiop:read-file-string "README.md"))
