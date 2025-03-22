;; Device Registration Contract
;; Records details of used medical equipment

(define-data-var last-id uint u0)

(define-map devices
  { id: uint }
  {
    name: (string-ascii 100),
    type: (string-ascii 50),
    manufacturer: (string-ascii 100),
    serial-number: (string-ascii 50),
    condition: (string-ascii 20),
    owner: principal,
    registered-at: uint
  }
)

;; Register a device
(define-public (register
    (name (string-ascii 100))
    (type (string-ascii 50))
    (manufacturer (string-ascii 100))
    (serial-number (string-ascii 50))
    (condition (string-ascii 20))
  )
  (let
    (
      (new-id (+ (var-get last-id) u1))
    )
    (var-set last-id new-id)

    (map-set devices
      { id: new-id }
      {
        name: name,
        type: type,
        manufacturer: manufacturer,
        serial-number: serial-number,
        condition: condition,
        owner: tx-sender,
        registered-at: block-height
      }
    )

    (ok new-id)
  )
)

;; Update device condition
(define-public (update-condition
    (device-id uint)
    (condition (string-ascii 20))
  )
  (let
    (
      (device (unwrap! (map-get? devices { id: device-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner device)) (err u403))

    (map-set devices
      { id: device-id }
      (merge device { condition: condition })
    )

    (ok true)
  )
)

;; Transfer device ownership
(define-public (transfer
    (device-id uint)
    (new-owner principal)
  )
  (let
    (
      (device (unwrap! (map-get? devices { id: device-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner device)) (err u403))

    (map-set devices
      { id: device-id }
      (merge device { owner: new-owner })
    )

    (ok true)
  )
)

;; Get device
(define-read-only (get-device (id uint))
  (map-get? devices { id: id })
)

;; Get device count
(define-read-only (get-count)
  (var-get last-id)
)

