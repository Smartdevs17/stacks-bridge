
;; btc-peg-out-v1
;; Simulates a Bitcoin Peg-Out mechanism for the Stacks Bridge.
;;
;; This contract allows users to request a withdrawal to a Bitcoin address.
;; It emits an event that the Relayer network listens for.

;; Error Codes
(define-constant err-invalid-amount (err u100))
(define-constant err-paused (err u103))

(define-data-var is-paused bool false)
(define-data-var request-count uint u0)

(define-map peg-out-requests uint {
    requester: principal,
    amount: uint,
    btc-address: (string-ascii 64),
    status: (string-ascii 10) ;; "pending", "processed"
})

(define-public (request-peg-out (amount uint) (btc-address (string-ascii 64)))
    (let (
        (request-id (+ (var-get request-count) u1))
    )
        (asserts! (not (var-get is-paused)) err-paused)
        (asserts! (> amount u0) err-invalid-amount)
        
        ;; In production, we would burn sBTC/xBTC here
        ;; (contract-call? .wrapped-btc burn amount tx-sender)
        
        (map-set peg-out-requests request-id {
            requester: tx-sender,
            amount: amount,
            btc-address: btc-address,
            status: "pending"
        })
        
        (var-set request-count request-id)
        
        (print {
            event: "btc-peg-out-request",
            request-id: request-id,
            requester: tx-sender,
            amount: amount,
            btc-dest: btc-address
        })
        
        (ok request-id)
    )
)
