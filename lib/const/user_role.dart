enum UserRole { tenant, owner }

String roleToString(UserRole r) => r == UserRole.tenant ? "tenant" : "owner";

UserRole roleFromString(String? s) {
  if (s == "owner") return UserRole.owner;
  return UserRole.tenant;
}

String roleTitle(UserRole r) => r == UserRole.tenant ? "مستأجر" : "مالك / وكيل";
