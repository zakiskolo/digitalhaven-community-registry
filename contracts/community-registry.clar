;; DigitalHaven 
;;
;; This smart contract enables the creation and management of digital community participants with customizable profiles, activity tracking, and access control mechanisms.
;; Version: 1.0.0
;; Last Updated: April 2025

;; ===============================
;; Global State Variables
;; ===============================

;; Registry size tracker
(define-data-var total-participants uint u0)

;; ===============================
;; Storage Mappings & Data Tables
;; ===============================

;; Core participant registry - Stores essential profile information
(define-map participant-registry
  { participant-id: uint }
  {
    display-name: (string-ascii 50),
    account-address: principal,
    enrollment-timestamp: uint,
    personal-statement: (string-ascii 160),
    interest-tags: (list 5 (string-ascii 30))
  }
)

;; Access control settings for profile information
(define-map access-control-settings
  { participant-id: uint, requestor-address: principal }
  { access-enabled: bool }
)

;; Participant engagement history
(define-map participant-engagement-history
  { participant-id: uint }
  {
    recent-access: uint,
    access-count: uint,
    recent-engagement: (string-ascii 50)
  }
)

;; ===============================
;; System Constants & Definitions
;; ===============================

;; Error code definitions
(define-constant ERROR-NOT-AUTHORIZED (err u500))
(define-constant ERROR-RECORD-NOT-FOUND (err u501))
(define-constant ERROR-PARTICIPANT-EXISTS (err u502))
(define-constant ERROR-INVALID-PARAMETERS (err u503))
(define-constant ERROR-ACCESS-DENIED (err u504))

;; Administrative settings
(define-constant ADMINISTRATOR tx-sender)


;; ===============================
;; Internal Utility Functions
;; ===============================

;; Check if participant record exists
(define-private (participant-record-exists? (participant-id uint))
  (is-some (map-get? participant-registry { participant-id: participant-id }))
)

;; Verify participant ownership
(define-private (verify-participant-owner? (participant-id uint) (address principal))
  (match (map-get? participant-registry { participant-id: participant-id })
    profile-data (is-eq (get account-address profile-data) address)
    false
  )
)

;; Validate tag length and structure
(define-private (is-tag-valid? (tag (string-ascii 30)))
  (and
    (> (len tag) u0)
    (< (len tag) u31)
  )
)

;; Validate the complete list of interest tags
(define-private (are-tags-valid? (tags (list 5 (string-ascii 30))))
  (and
    (> (len tags) u0)
    (<= (len tags) u5)
    (is-eq (len (filter is-tag-valid? tags)) (len tags))
  )
)

;; ===============================
;; Public Interface Functions
;; ===============================

;; Create new participant profile
(define-public (create-participant-profile 
    (display-name (string-ascii 50)) 
    (personal-statement (string-ascii 160)) 
    (interest-tags (list 5 (string-ascii 30))))
  (let
    (
      (new-id (+ (var-get total-participants) u1))
    )
    ;; Input validation
    (asserts! (and (> (len display-name) u0) (< (len display-name) u51)) ERROR-INVALID-PARAMETERS)
    (asserts! (and (> (len personal-statement) u0) (< (len personal-statement) u161)) ERROR-INVALID-PARAMETERS)
    (asserts! (are-tags-valid? interest-tags) ERROR-INVALID-PARAMETERS)

    ;; Create new participant entry
    (map-insert participant-registry
      { participant-id: new-id }
      {
        display-name: display-name,
        account-address: tx-sender,
        enrollment-timestamp: block-height,
        personal-statement: personal-statement,
        interest-tags: interest-tags
      }
    )

    ;; Initialize access permissions
    (map-insert access-control-settings
      { participant-id: new-id, requestor-address: tx-sender }
      { access-enabled: true }
    )

    ;; Update registry size
    (var-set total-participants new-id)
    (ok new-id)
  )
)

;; Modify participant interests
(define-public (modify-participant-interests (participant-id uint) (new-interest-tags (list 5 (string-ascii 30))))
  (let
    (
      (profile-data (unwrap! (map-get? participant-registry { participant-id: participant-id }) ERROR-RECORD-NOT-FOUND))
    )
    ;; Validation checks
    (asserts! (participant-record-exists? participant-id) ERROR-RECORD-NOT-FOUND)
    (asserts! (is-eq (get account-address profile-data) tx-sender) ERROR-ACCESS-DENIED)
    (asserts! (are-tags-valid? new-interest-tags) ERROR-INVALID-PARAMETERS)

    ;; Update interest tags
    (map-set participant-registry
      { participant-id: participant-id }
      (merge profile-data { interest-tags: new-interest-tags })
    )
    (ok true)
  )
)

;; Add new participant entry
(define-public (register-participant 
    (display-name (string-ascii 50)) 
    (personal-statement (string-ascii 160)) 
    (interest-tags (list 5 (string-ascii 30))))
  (let
    (
      (new-id (+ (var-get total-participants) u1))
    )
    ;; Input validation
    (asserts! (and (> (len display-name) u0) (< (len display-name) u51)) ERROR-INVALID-PARAMETERS)
    (asserts! (and (> (len personal-statement) u0) (< (len personal-statement) u161)) ERROR-INVALID-PARAMETERS)
    (asserts! (are-tags-valid? interest-tags) ERROR-INVALID-PARAMETERS)

    ;; Create participant entry
    (map-insert participant-registry
      { participant-id: new-id }
      {
        display-name: display-name,
        account-address: tx-sender,
        enrollment-timestamp: block-height,
        personal-statement: personal-statement,
        interest-tags: interest-tags
      }
    )

    ;; Set default access permissions
    (map-insert access-control-settings
      { participant-id: new-id, requestor-address: tx-sender }
      { access-enabled: true }
    )

    ;; Update registry counter
    (var-set total-participants new-id)
    (ok new-id)
  )
)

;; Update participant display name
(define-public (update-display-name (participant-id uint) (new-display-name (string-ascii 50)))
  (let
    (
      (profile-data (unwrap! (map-get? participant-registry { participant-id: participant-id }) ERROR-RECORD-NOT-FOUND))
    )
    ;; Validation checks
    (asserts! (participant-record-exists? participant-id) ERROR-RECORD-NOT-FOUND)
    (asserts! (is-eq (get account-address profile-data) tx-sender) ERROR-ACCESS-DENIED)
    (asserts! (and (> (len new-display-name) u0) (< (len new-display-name) u51)) ERROR-INVALID-PARAMETERS)

    ;; Update display name
    (map-set participant-registry
      { participant-id: participant-id }
      (merge profile-data { display-name: new-display-name })
    )
    (ok true)
  )
)

;; ===============================
;; Enhanced Functionality
;; ===============================

;; Optimized interest tag update implementation
(define-public (efficient-update-participant-interests (participant-id uint) (new-interest-tags (list 5 (string-ascii 30))))
  (begin
    ;; Validate participant exists
    (asserts! (participant-record-exists? participant-id) ERROR-RECORD-NOT-FOUND)
    ;; Validate tags format
    (asserts! (are-tags-valid? new-interest-tags) ERROR-INVALID-PARAMETERS)

    ;; Update interests in single operation
    (map-set participant-registry
      { participant-id: participant-id }
      (merge (unwrap! (map-get? participant-registry { participant-id: participant-id }) ERROR-RECORD-NOT-FOUND) 
        { interest-tags: new-interest-tags })
    )
    (ok "Interest tags successfully updated")
  )
)

;; Restrict profile data access to authorized addresses
(define-public (enforce-access-restrictions (participant-id uint) (address principal))
  (let
    (
      (profile-data (unwrap! (map-get? participant-registry { participant-id: participant-id }) ERROR-RECORD-NOT-FOUND))
    )
    ;; Verify access permissions
    (asserts! (is-eq (get account-address profile-data) address) ERROR-ACCESS-DENIED)
    (ok true)
  )
)

;; Comprehensive profile update with validation
(define-public (update-participant-complete-profile 
    (participant-id uint) 
    (new-display-name (string-ascii 50)) 
    (new-statement (string-ascii 160)) 
    (new-interest-tags (list 5 (string-ascii 30))))
  (let
    (
      (profile-data (unwrap! (map-get? participant-registry { participant-id: participant-id }) ERROR-RECORD-NOT-FOUND))
    )
    ;; Comprehensive validation
    (asserts! (participant-record-exists? participant-id) ERROR-RECORD-NOT-FOUND)
    (asserts! (is-eq (get account-address profile-data) tx-sender) ERROR-ACCESS-DENIED)
    (asserts! (> (len new-display-name) u0) ERROR-INVALID-PARAMETERS)
    (asserts! (< (len new-display-name) u51) ERROR-INVALID-PARAMETERS)
    (asserts! (are-tags-valid? new-interest-tags) ERROR-INVALID-PARAMETERS)

    ;; Update full profile
    (map-set participant-registry
      { participant-id: participant-id }
      (merge profile-data { 
        display-name: new-display-name, 
        personal-statement: new-statement, 
        interest-tags: new-interest-tags 
      })
    )
    (ok true)
  )
)

;; Authenticate participant account ownership
(define-public (authenticate-participant-ownership (participant-id uint) (claimed-address principal))
  (let
    (
      (profile-data (unwrap! (map-get? participant-registry { participant-id: participant-id }) ERROR-RECORD-NOT-FOUND))
    )
    ;; Return ownership verification result
    (ok (is-eq claimed-address (get account-address profile-data)))
  )
)

;; Log participant system activity
(define-public (log-participant-activity (participant-id uint))
  (let
    (
      (current-activity (default-to 
        { recent-access: u0, access-count: u0, recent-engagement: "None" }
        (map-get? participant-engagement-history { participant-id: participant-id })))
    )
    ;; Validate participant exists
    (asserts! (participant-record-exists? participant-id) ERROR-RECORD-NOT-FOUND)

    ;; Update activity log
    (map-set participant-engagement-history
      { participant-id: participant-id }
      {
        recent-access: block-height,
        access-count: (+ (get access-count current-activity) u1),
        recent-engagement: "system-access"
      }
    )
    (ok true)
  )
)

;; ===============================
;; Administrative Functions
;; ===============================

;; Verify system status
(define-public (get-system-statistics)
  (ok (var-get total-participants))
)

;; Export participant list (admin only)
(define-public (export-participant-list)
  (begin
    (asserts! (is-eq tx-sender ADMINISTRATOR) ERROR-NOT-AUTHORIZED)
    (ok (var-get total-participants))
  )
)

