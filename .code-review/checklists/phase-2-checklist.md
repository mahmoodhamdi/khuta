# Phase 2: Security Hardening - Checklist

> **Status:** In Progress
> **Progress:** 2/3 milestones complete
> **Last Updated:** 2025-12-27

---

## Milestones

### 2.1 Firebase App Check Production Setup
- [ ] Create AppConfig class
- [ ] Update App Check initialization
- [ ] Configure Play Integrity (Android)
- [ ] Configure Device Check (iOS)
- [ ] Test debug mode
- [ ] Test release mode
- **Status:** Pending

### 2.2 Secure PDF Generation
- [x] Use private app directory (getApplicationDocumentsDirectory/reports)
- [x] Sanitize child names in filenames (_sanitizeFileName method)
- [x] Add cleanup for old reports (_cleanupOldReports - 24h expiry)
- [x] Added context.mounted checks for async operations
- [x] flutter analyze passes
- **Status:** Done

### 2.3 Firestore Security Rules
- [x] Create firestore.rules file with comprehensive security rules
- [ ] Deploy security rules (requires Firebase CLI: `firebase deploy --only firestore:rules`)
- [x] Add isDeleted/updatedAt fields to Child model for soft delete support
- [x] Add copyWithDeleted() method for soft delete operations
- [x] Update HomeScreen query to filter out soft-deleted children
- [x] flutter analyze passes
- **Status:** Done (deployment pending)

---

## Verification

When all milestones complete:
- [ ] App Check enforced in Firebase Console
- [x] PDFs stored in private directory
- [ ] Security rules deployed (run: firebase deploy --only firestore:rules)
- [ ] All existing functionality works

---

## Notes

_Add any notes or issues encountered during this phase:_

