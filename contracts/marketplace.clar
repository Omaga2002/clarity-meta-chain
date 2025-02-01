;; Marketplace for VR Assets
(use-trait vr-asset-trait .vr-asset)

;; Constants
(define-constant err-invalid-price (err u200))
(define-constant err-not-for-sale (err u201))
(define-constant err-unauthorized (err u202))

;; Listing data
(define-map listings
  uint
  {
    seller: principal,
    price: uint,
    listed-at: uint
  }
)

;; List asset for sale
(define-public (list-asset (asset-id uint) (price uint))
  (begin
    (asserts! (> price u0) err-invalid-price)
    (asserts! (is-eq (nft-get-owner? .vr-asset vr-asset asset-id) (some tx-sender)) err-unauthorized)
    (map-set listings asset-id
      {
        seller: tx-sender,
        price: price,
        listed-at: block-height
      }
    )
    (ok true)
  )
)

;; Buy listed asset
(define-public (buy-asset (asset-id uint))
  (let ((listing (unwrap! (map-get? listings asset-id) err-not-for-sale)))
    (try! (stx-transfer? (get price listing) tx-sender (get seller listing)))
    (try! (contract-call? .vr-asset transfer asset-id tx-sender))
    (map-delete listings asset-id)
    (ok true)
  )
)
