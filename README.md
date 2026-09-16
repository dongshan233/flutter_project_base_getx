# flutter_project_base

lib/
│
├── main.dart
│
├── app/
│   ├── bindings/
│   │   └── app_binding.dart
│   │
│   └── routes/
│       ├── app_pages.dart
│       └── app_routes.dart
│
├── core/
│   ├── network/
│   │   └── api_client.dart
│   │
│   └── storage/
│       └── token_storage.dart
│
├── data/
│   ├── models/
│   │   └── user.dart
│   │
│   └── repositories/
│       ├── auth_repository.dart
│       └── user_repository.dart
│
└── modules/
    ├── login/
    │   ├── login_binding.dart
    │   ├── login_controller.dart
    │   └── login_page.dart
    │
    └── home/
        ├── home_binding.dart
        ├── home_controller.dart
        └── home_page.dart