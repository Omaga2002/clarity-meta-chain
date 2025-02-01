;; Rental system for VR Assets
(use-trait vr-asset-trait .vr-asset)

;; Constants
(define-constant err-invalid-duration (err u300))
(define-constant err-not-for-rent (err u301))
(define-constant err-unauthorized (err u302))

;; Rental data
(define-map rentals
  uint 
  {
    owner: principal,
    renter: (optional principal),
    price-per-block: uint,
    min-duration: uint,
    max-duration: uint,
    rental-start: (optional uint),
    rental-end: (optional uint)
  }
)

;; List asset for rent
(define-public (list-for-rent (asset-id uint) 
                            (price-per-block uint)
                            (min-duration uint)
                            (max-duration uint))
  (begin
    (asserts! (and (> price-per-block u0) (> min-duration u0)) err-invalid-duration)
    (asserts! (is-eq (nft-get-owner? .vr-asset vr-asset asset-id) (some tx-sender)) err-unauthorized)
    (map-set rentals asset-id
      {
        owner: tx-sender,
        renter: none,
        price-per-block: price-per-block,
        min-duration: min-duration,
        max-duration: max-duration,
        rental-start: none,
        rental-end: none
      }
    )
    (ok true)
  )
)

;; Rent asset
(define-public (rent-asset (asset-id uint) (duration uint))
  (let ((rental (unwrap! (map-get? rentals asset-id) err-not-for-rent)))
    (asserts! (and (>= duration (get min-duration rental))
                  (<= duration (get max-duration rental))) err-invalid-duration)
    (let ((total-cost (* duration (get price-per-block rental))))
      (try! (stx-transfer? total-cost tx-sender (get owner rental)))
      (map-set rentals asset-id
        (merge rental {
          renter: (some tx-sender),
          rental-start: (some block-height),
          rental-end: (some (+ block-height duration))
        })
      )
      (ok true)
    )
  )
)
