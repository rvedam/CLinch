;;;; transform.lisp
;;;; Please see the licence.txt for the CLinch 

(in-package #:clinch)

(defconstant +pi+ (coerce pi 'single-float))

(defmacro ensure-float (x)
  `(coerce ,x 'single-float))


(defmacro degrees->radians (degrees)
  `(coerce (* 2 pi (/ ,degrees 360)) 'single-float))

(defmacro radians->degrees (radians)
  `(coerce (* 180 (/ ,radians pi)) 'single-float))

(defun make-matrix (m11 m12 m13 m14 
		    m21 m22 m23 m24
		    m31 m32 m33 m34
		    m41 m42 m43 m44)
  (sb-cga:matrix (ENSURE-FLOAT M11) (ENSURE-FLOAT M12) (ENSURE-FLOAT M13) (ENSURE-FLOAT M14) 
		 (ENSURE-FLOAT M21) (ENSURE-FLOAT M22) (ENSURE-FLOAT M23) (ENSURE-FLOAT M24) 
		 (ENSURE-FLOAT M31) (ENSURE-FLOAT M32) (ENSURE-FLOAT M33) (ENSURE-FLOAT M34)
		 (ENSURE-FLOAT M41) (ENSURE-FLOAT M42) (ENSURE-FLOAT M43) (ENSURE-FLOAT M44)))


(defun make-orthogonal-transform (width height near far)
  "Create a raw CFFI orthogonal matrix."
  (make-matrix (/ 2 width) 0.0 0.0 0.0
	       0.0 (/ 2 height) 0.0 0.0
	       0.0 0.0 (/ (- far near)) (/ (- near) (- far near)) 
	       0.0 0.0 0.0 1.0))

(defun make-frustum-transform (left right bottom top near far)
  "Create a raw CFFI frustum matrix."  
  (let ((a (/ (+ right left) (- right left)))
	(b (/ (+ top bottom) (- top bottom)))
	(c (- (/ (+ far near) (- far near))))
	(d (- (/ (* 2 far near) (- far near)))))
    
    (make-matrix (/ (* 2 near) (- right left)) 0 A 0
		 0 (/ (* 2 near) (- top bottom)) B 0
		 0 0 C D
		 0 0 -1 0)))

(defun make-perspective-transform  (fovy aspect znear zfar)
  "Create a raw CFFI perspective matrix."
  (let* ((ymax (* znear (tan fovy)))
	 (xmax (* ymax aspect)))
    (make-frustum-transform (- xmax) xmax (- ymax) ymax znear zfar)))


(defun transform-point (p m)
  (let ((w (/
	    (+ (* (elt m 3) (elt p 0))
	       (* (elt m 7) (elt p 1))
	       (* (elt m 11) (elt p 2))
	       (elt m 15)))))
    (make-vector (* w (+ (* (elt m 0) (elt p 0))
			 (* (elt m 4) (elt p 1))
			 (* (elt m 8) (elt p 2))
			 (elt m 12)))
		 (* w (+ (* (elt m 1) (elt p 0))
			 (* (elt m 5) (elt p 1))
			 (* (elt m 9) (elt p 2))
			 (elt m 13)))
		 (* w (+ (* (elt m 2) (elt p 0))
			 (* (elt m 6) (elt p 1))
			 (* (elt m 10) (elt p 2))
			 (elt m 14))))))

						     

(defun unproject (x y width height inv-transform)
  (let* ((new-x (1- (/ (* 2 x) width)))
	 (new-y (- (1- (/ (* 2 y) height))))
	 (start (clinch:transform-point (clinch:make-vector new-x new-y 0) inv-transform))
	 (end   (clinch:transform-point (clinch:make-vector new-x new-y 1) inv-transform)))

    (values start
	    (sb-cga:normalize (sb-cga:vec- end start)))))
  

(defun get-screen-direction (lens-1)
  (let ((start-of-box (clinch:transform-point (clinch:make-vector 0 0 0)
					lens-1))
	(end-of-box   (clinch:transform-point (clinch:make-vector 0 0 1)
						 lens-1)))
    (values start-of-box
	   (sb-cga:normalize (sb-cga:vec- end-of-box start-of-box)))))

