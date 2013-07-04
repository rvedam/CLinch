;;;; clinch.asd
;;;; Please see the licence.txt for the CLinch 

(asdf:defsystem #:clinch
  :serial t
  :description "Describe CLinch here"
  :author "Brad Beer (WarWeasle)"
  :license "BSD"
  :version "0.1"
  :depends-on (#:cl-opengl
	       #:sb-cga)
  :components ((:file "package")
	       (:file "transform")
	       (:file "vector")
	       (:file "node")
	       (:file "shader")
	       (:file "buffer")
	       (:file "texture")
	       (:file "entity")
	       (:file "viewport")
	       (:file "pipeline")))


