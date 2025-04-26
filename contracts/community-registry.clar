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
