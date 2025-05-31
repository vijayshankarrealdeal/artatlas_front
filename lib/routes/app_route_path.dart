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

class UnknownPath extends AppRoutePath { // For handling undefined routes
  const UnknownPath();
}