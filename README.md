# DigitalHaven Community Registry

**Version:** 1.0.0  
**Last Updated:** April 2025

## Overview
DigitalHaven is a Clarity smart contract that provides a robust framework for digital community management.  
Participants can create customizable profiles, manage their interests, control access to their data, and track activity history, all on the blockchain.

## Features
- **Participant Profiles:** Register customizable user profiles with display names, personal statements, and interest tags.
- **Access Control:** Fine-grained permission management for profile visibility.
- **Engagement Tracking:** Log and retrieve participant activity and system interactions.
- **Profile Updates:** Modify profile information securely with ownership verification.
- **Administrative Tools:** Retrieve community statistics and export participant data (admin-restricted).

## Contract Architecture
- `participant-registry`: Core storage for participant profiles.
- `access-control-settings`: Manages who can access profile information.
- `participant-engagement-history`: Records participant access and engagement metrics.

## Error Handling
The contract uses standardized error codes:
- `u500`: Not authorized
- `u501`: Record not found
- `u502`: Participant already exists
- `u503`: Invalid parameters
- `u504`: Access denied

## Setup & Deployment
1. Ensure you have [Clarity tools](https://docs.stacks.co/docs/clarity-overview) installed.
2. Deploy the `digitalhaven.clar` contract using the Stacks blockchain.
3. Interact with the contract using Clarity CLI, a frontend dApp, or a wallet that supports smart contract calls.

## Usage
- **Create a participant profile:**
  ```clarity
  (create-participant-profile "Display Name" "Personal statement here" ["tag1", "tag2"])
  ```
- **Update participant interests:**
  ```clarity
  (modify-participant-interests participant-id ["new-tag1", "new-tag2"])
  ```
- **Log system activity:**
  ```clarity
  (log-participant-activity participant-id)
  ```

## Administrative Functions
- **Get system statistics:**
  ```clarity
  (get-system-statistics)
  ```
- **Export participant list (Admin only):**
  ```clarity
  (export-participant-list)
  ```

## License
This project is open-sourced under the MIT License.
