(in-package :cl-async-ssl)

(defconstant +ssl-st-connect+ #x1000)
(defconstant +ssl-st-accept+ #x2000)
(defconstant +ssl-st-mask+ #x0FFF)
(defconstant +ssl-st-init+ (logior +ssl-st-connect+ +ssl-st-accept+))
(defconstant +ssl-st-before+ #x4000)
(defconstant +ssl-st-ok+ #x03)
(defconstant +ssl-st-renegotiate+ (logior #x04 +ssl-st-init+))

(defconstant +ssl-cb-loop+ #x01)
(defconstant +ssl-cb-exit+ #x02)
(defconstant +ssl-cb-read+ #x04)
(defconstant +ssl-cb-write+ #x08)
(defconstant +ssl-cb-alert+ #x4000)
(defconstant +ssl-cb-read-alert+ (logior +ssl-cb-alert+ +ssl-cb-read+))
(defconstant +ssl-cb-write-alert+ (logior +ssl-cb-alert+ +ssl-cb-write+))
(defconstant +ssl-cb-accept-loop+ (logior +ssl-st-accept+ +ssl-cb-loop+))
(defconstant +ssl-cb-accept-exit+ (logior +ssl-st-accept+ +ssl-cb-exit+))
(defconstant +ssl-cb-connect-loop+ (logior +ssl-st-connect+ +ssl-cb-loop+))
(defconstant +ssl-cb-connect-exit+ (logior +ssl-st-connect+ +ssl-cb-exit+))
(defconstant +ssl-cb-handshake-start+ #x10)
(defconstant +ssl-cb-handshake-done+ #x20)
(defconstant +ssl-received-shutdown+ 2)

(defconstant +ssl-verify-none+ #x00)
(defconstant +ssl-verify-peer+ #x01)
(defconstant +ssl-verify-fail-if-no-peer-cert+ #x02)
(defconstant +ssl-verify-client-once+ #x04)

(defconstant +ssl-bio-c-set-buf-mem-eof-return+ 130)

(cffi:defcfun ("SSL_set_shutdown" ssl-set-shutdown) :void
  (ssl :pointer)
  (mode :int))
(cffi:defcfun ("SSL_shutdown" ssl-shutdown) :int
  (ssl :pointer))
(cffi:defcfun ("ERR_get_error" ssl-get-error) :int)
(cffi:defcfun ("ERR_reason_error_string" ssl-error-string) :string
  (errcode :int))
(cffi:defcfun ("TLSv1_client_method" ssl-tls-v1-client-method) :int)
(cffi:defcfun ("SSL_CTX_new" ssl-ctx-new) :pointer
  (method :int))
(cffi:defcfun ("SSL_CTX_set_default_verify_paths" ssl-ctx-set-default-verify-paths) :int
  (ctx :pointer))
(cffi:defcfun ("SSL_CTX_set_verify" ssl-ctx-set-verify) :int
  (ctx :pointer)
  (mode :int)
  (verify-callback :pointer))
(cffi:defcfun ("SSL_new" ssl-new) :pointer
  (ctx :pointer))
(cffi:defcfun ("BIO_new" ssl-bio-new) :pointer
  (type :int))
(cffi:defcfun ("SSL_set_cipher_list" ssl-set-cipher-list) :int
  (ssl :pointer)
  (ciphers :string))
(cffi:defcfun ("SSL_set_bio" ssl-set-bio) :int
  (ssl :pointer)
  (bio-read :pointer)
  (bio-write :pointer))
(cffi:defcfun ("SSL_set_connect_state" ssl-set-connect-state) :int
  (ssl :pointer))
(cffi:defcfun ("SSL_set_info_callback" ssl-set-info-callback) :void
  (ssl :pointer)
  (callback :pointer))
(cffi:defcfun ("SSL_CTX_set_info_callback" ssl-ctx-set-info-callback) :void
  (ctx :pointer)
  (callback :pointer))
(cffi:defcfun ("SSL_state" ssl-state) :int
  (ssl :pointer))
(cffi:defcfun ("SSL_connect" ssl-connect) :int
  (ssl :pointer))
(cffi:defcfun ("SSL_accept" ssl-accept) :int
  (ssl :pointer))
(cffi:defcfun ("BIO_ctrl" ssl-bio-ctrl) :long
  (bio :pointer)
  (cmd :int)
  (arg :long)
  (parg :pointer))
(cffi:defcfun ("BIO_s_mem" ssl-bio-s-mem) :int)

(defun ssl-is-init-finished (ssl) (= (ssl-state ssl) +ssl-st-ok+))
(defun ssl-in-init (ssl) (not (zerop (logand (ssl-state ssl) +ssl-st-init+))))
(defun ssl-in-before (ssl) (not (zerop (logand (ssl-state ssl) +ssl-st-before+))))
(defun ssl-in-connect-init (ssl) (not (zerop (logand (ssl-state ssl) +ssl-st-connect+))))
(defun ssl-in-accept-init (ssl) (not (zerop (logand (ssl-state ssl) +ssl-st-accept+))))
(defun ssl-bio-set-mem-eof-return (bio v) (ssl-bio-ctrl bio +ssl-bio-c-set-buf-mem-eof-return+ v (cffi:null-pointer)))

(defun last-ssl-error ()
  "Returns the last error string (nil if none) and the last error code that
   happened in SSL land."
  (let ((errcode (ssl-get-error)))
    (values
      (ssl-error-string errcode)
      errcode)))

