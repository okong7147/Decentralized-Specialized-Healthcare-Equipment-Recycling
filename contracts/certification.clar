;; Certification Contract
;; Validates safety and functionality after reconditioning

(define-data-var last-id uint u0)

(define-map certifications
  { id: uint }
  {
    device-id: uint,
    certifier: principal,
    safety-check: bool,
    functionality-check: bool,
    certification-date: uint,
    expiration-date: uint,
    notes: (string-ascii 200),
    status: (string-ascii 20) ;; "certified", "expired", "revoked"
  }
)

;; Certify device
(define-public (certify
    (device-id uint)
    (safety-check bool)
    (functionality-check bool)
    (expiration-date uint)
    (notes (string-ascii 200))
  )
  (let
    (
      (new-id (+ (var-get last-id) u1))
    )
    (asserts! (and safety-check functionality-check) (err u400))
    (asserts! (> expiration-date block-height) (err u400))

    (var-set last-id new-id)

    (map-set certifications
      { id: new-id }
      {
        device-id: device-id,
        certifier: tx-sender,
        safety-check: safety-check,
        functionality-check: functionality-check,
        certification-date: block-height,
        expiration-date: expiration-date,
        notes: notes,
        status: "certified"
      }
    )

    (ok new-id)
  )
)

;; Revoke certification
(define-public (revoke
    (certification-id uint)
    (notes (string-ascii 200))
  )
  (let
    (
      (certification (unwrap! (map-get? certifications { id: certification-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get certifier certification)) (err u403))
    (asserts! (is-eq (get status certification) "certified") (err u400))

    (map-set certifications
      { id: certification-id }
      (merge certification {
        notes: notes,
        status: "revoked"
      })
    )

    (ok true)
  )
)

;; Get certification
(define-read-only (get-certification (id uint))
  (map-get? certifications { id: id })
)

;; Get certification by device ID
(define-read-only (get-certification-by-device (device-id uint))
  (let
    (
      (certification-id (var-get last-id))
    )
    (map-get? certifications { id: certification-id })
  )
)

