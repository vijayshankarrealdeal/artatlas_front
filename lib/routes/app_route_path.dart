// lib/routing/app_route_path.dart
abstract class AppRoutePath {
  const AppRoutePath();
}

class HomePath extends AppRoutePath {
  const HomePath();
}

class GalleryPath extends AppRoutePath {
  const GalleryPath();
}

class CollectionsPath extends AppRoutePath {
  const CollectionsPath();
}

// New Auth Paths
class LoginPath extends AppRoutePath {
  const LoginPath();
}

class SignupPath extends AppRoutePath {
  const SignupPath();
}


class UnknownPath extends AppRoutePath {
  const UnknownPath();
}