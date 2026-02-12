enum UserRole {
  syndic,
  adjoint,
  concierge,
  resident,
  unknown,
}

class RoleGuards {
  static bool canEditFinance(UserRole role) {
    return role == UserRole.syndic;
  }

  static bool canWriteIncidents(UserRole role) {
    return role == UserRole.syndic || role == UserRole.adjoint || role == UserRole.resident;
  }

  static bool canViewAllIncidents(UserRole role) {
    return role == UserRole.syndic || role == UserRole.adjoint;
  }
}
