;; VR Asset NFT Implementation
(define-non-fungible-token vr-asset uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Asset properties
(define-map asset-properties
  uint
  {
    name: (string-utf8 64),
    description: (string-utf8 256),
    uri: (string-utf8 256),
    creator: principal,
    created-at: uint,
    properties: (list 10 {key: (string-utf8 32), value: (string-utf8 64)})
  }
)

;; Mint new VR asset
(define-public (mint (asset-id uint) 
                   (name (string-utf8 64))
                   (description (string-utf8 256))
                   (uri (string-utf8 256))
                   (properties (list 10 {key: (string-utf8 32), value: (string-utf8 64)})))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (nft-mint? vr-asset asset-id tx-sender))
    (map-set asset-properties asset-id
      {
        name: name,
        description: description,
        uri: uri,
        creator: tx-sender,
        created-at: block-height,
        properties: properties
      }
    )
    (ok true)
  )
)

;; Transfer asset
(define-public (transfer (asset-id uint) (recipient principal))
  (begin
    (asserts! (is-eq (nft-get-owner? vr-asset asset-id) (some tx-sender)) err-unauthorized)
    (try! (nft-transfer? vr-asset asset-id tx-sender recipient))
    (ok true)
  )
)

;; Get asset details
(define-read-only (get-asset (asset-id uint))
  (match (map-get? asset-properties asset-id)
    asset (ok asset)
    err-not-found
  )
)

;; Update asset properties
(define-public (update-properties (asset-id uint) 
                                (properties (list 10 {key: (string-utf8 32), value: (string-utf8 64)})))
  (let ((asset (unwrap! (map-get? asset-properties asset-id) err-not-found)))
    (asserts! (is-eq (nft-get-owner? vr-asset asset-id) (some tx-sender)) err-unauthorized)
    (map-set asset-properties asset-id
      (merge asset {properties: properties})
    )
    (ok true)
  )
)
