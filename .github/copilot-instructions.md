# AI-Powered Vedic Astrologer App - Coding Agent Instructions

## Project Overview

This project is an AI-powered Vedic Astrologer App built with Flutter. It provides users with personalized Vedic astrology readings, horoscope generation, and astrological insights using modern AI and data-driven techniques. The app follows **Clean Architecture** with a feature-based structure, leveraging best practices for maintainability and scalability.

### Current Architecture State

**⚠️ Important**: The project is in development and only partially implements the full clean architecture patterns described in the detailed guidelines below. Key current realities:

- **State Management**: Uses simplified Bloc/Cubit without the `DataState` utility mentioned in guidelines
- **Dependencies**: Uses Dio and Retrofit for all networking
- **Service Locator**: Not implemented - uses direct instantiation
- **Error Handling**: Uses basic `Result<T, E>` pattern, not the full error mapping described

### Quick Development Guide

1. **Adding Features**: Follow the feature-based structure: `lib/feature_name/{domain,infrastructure,application,presentation}/`
2. **State Management**: Create `feature_cubit.dart` and `feature_state.dart` using Freezed
3. **Models**: Use Freezed with `@Default()` values and `abstract class` syntax (current codebase style)
4. **UI Constants**: Always use `KSizes` from `lib/core/constants/k_sizes.dart` - never hardcode measurements
5. **App Images**: All app-required images must be placed in `assets/images/app/`.
6. **User Images**: All user-uploaded or user-specific images must be placed in `assets/images/users/`.
7. **Code Generation**: Run `dart run build_runner build` after adding Freezed models

### Essential Commands

```bash
# Install dependencies and generate code
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Clean build (if issues)
flutter clean && flutter pub get
```

### Current Dependencies (pubspec.yaml)

- `freezed_annotation: ^3.1.0` + `freezed: ^3.2.0` (code generation)
- `result_type: ^1.0.0` (error handling)
- `flutter_bloc: ^9.1.1` (state management)
- `dio: ^5.9.0` (networking)
- `retrofit: ^4.7.2` (networking)

### Project-Specific Patterns

1. **State Classes**: Use simple state structure vs complex DataState wrapper:

   ```dart
   @freezed
   abstract class FeatureState with _$FeatureState {
     const factory FeatureState({
       @Default([]) List<Model> items,
       @Default(false) bool isLoading,
       @Default(false) bool hasError,
     }) = _FeatureState;
   }
   ```

2. **Service Constructor Pattern**: Direct instantiation fallback:

   ```dart
   FeatureCubit({IFeatureService? service})
     : _service = service ?? FeatureService(),
       super(FeatureState.initial());
   ```

3. **KSizes Usage**: Mandatory for all UI measurements:
   ```dart
   padding: EdgeInsets.all(KSizes.margin4x),  // ✅ Correct
   padding: EdgeInsets.all(16.0),             // ❌ Never do this
   ```

### Asset Management

- All app-required images must be stored in `assets/images/app/`.
- All user-uploaded or user-specific images must be stored in `assets/images/users/`.
- Update `pubspec.yaml` to include these asset folders:

  ```yaml
  flutter:
    assets:
      - assets/images/app/
      - assets/images/users/
  ```

### Dio + Retrofit Networking Pattern

All networking in this app is handled using Dio and Retrofit. Do not use the `http` package. Follow these steps for any new API integration:

1. **Add Dependencies** (already in pubspec.yaml):

   ```yaml
   dependencies:
     dio: ^5.9.0
     retrofit: ^4.7.2
     retrofit_generator: ^10.0.2
   dev_dependencies:
     build_runner: ^2.4.9
   ```

2. **Create Core HTTP Infrastructure**:

   ```dart
   // lib/core/api/http_client.dart
   class HttpClient {
     static Dio createDio({required String baseUrl}) {
       final dio = Dio();
       dio.options.baseUrl = baseUrl;
       dio.options.connectTimeout = const Duration(seconds: 30);
       dio.options.receiveTimeout = const Duration(seconds: 30);
       return dio;
     }
   }
   ```

3. **Create Retrofit API Clients**:

   ```dart
   // lib/feature/infrastructure/api/feature_api_client.dart
   @RestApi()
   abstract class FeatureApiClient {
     factory FeatureApiClient(Dio dio, {String baseUrl}) = _FeatureApiClient;

     @GET('/endpoint')
     Future<List<FeatureDto>> getItems();
   }
   ```

4. **Update Service Implementation**:

   ```dart
   class FeatureService extends BaseApiService implements IFeatureService {
     final FeatureApiClient _apiClient;

     FeatureService({Dio? dio})
       : _apiClient = FeatureApiClient(
           dio ?? HttpClient.createDio(baseUrl: FeatureApiKeys.baseUrl),
         ),
         super(dio ?? HttpClient.createDio(baseUrl: FeatureApiKeys.baseUrl));

     @override
     Future<Result<List<FeatureModel>, FeatureError>> getItems() async {
       try {
         final dtos = await _apiClient.getItems();
         return Success(dtos.map((dto) => dto.toDomain()).toList());
       } on DioException catch (e) {
         return Failure(_mapDioError(e));
       }
     }
   }
   ```

5. **Generate Retrofit Code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

**Example**: See `lib/sun/infrastructure/sun_service.dart` for a static implementation. For real API calls, always use Dio + Retrofit as shown above.

---

# Flutter Project Structure and Naming Conventions

## Directory Structure

```
lib/
  ├── core/
  │   └── constants/
  │       └── k_sizes.dart
  └── feature_name/
      ├── application/
      │   ├── feature_cubit.dart
      │   └── feature_state.dart
      ├── domain/
      │   ├── i_feature_service.dart
      │   └── feature_model.dart
      ├── infrastructure/
      │   ├── dtos/
      │   │   └── feature_dto.dart
      │   └── feature_service.dart
      └── presentation/
          ├── feature_page.dart
          └── widgets/
              └── feature_widget.dart
```

## Naming Conventions

### Files and Directories

1. All file and directory names should use snake_case
2. Feature directories should be descriptive and domain-specific
3. Interface files should be prefixed with `i_` (e.g., `i_service.dart`)
4. State management files should use the suffix matching their type:
   - Cubit files: `_cubit.dart`
   - State files: `_state.dart`
5. Model files should use the suffix `_model.dart`
6. Widget files should use the suffix `_widget.dart`
7. DTO files should use the suffix `_dto.dart`
8. Constant files should be prefixed with `k_` (e.g., `k_sizes.dart`)

### Classes

1. Use PascalCase for class names
2. Widget classes should match their file names in PascalCase
3. Interface classes should be prefixed with 'I'
4. State classes should be suffixed with 'State'
5. Cubit classes should be suffixed with 'Cubit'
6. Constant classes should be prefixed with 'K' (e.g., 'KSizes')

### Code Organization

1. Group related widgets in the same directory
2. Separate concerns into appropriate layers:
   - application: State management (Cubit, State)
   - domain: Business logic and interfaces
   - infrastructure: Concrete implementations of interfaces
   - presentation: UI components and pages
3. Core functionality and constants should reside in the core directory

### Layout Constants (KSizes)

1. All UI measurements must use predefined constants from KSizes:
   - Margins and padding (e.g., KSize.margin4x, KSize.margin8x)
   - Font sizes (e.g., KSize.fontSizeS, KSize.fontSizeM)
   - Border radius (e.g., KSize.radiusDefault)
   - Icon sizes (e.g., KSize.iconS, KSize.iconM)
   - Component sizes (e.g., KSize.buttonHeight)
2. Never use hard-coded numeric values for:
   - Spacing and layout
   - Typography
   - Component dimensions
3. KSizes should follow a consistent scaling system:
   - Base unit multiplication (e.g., 4x, 8x, 12x for margins)
   - Semantic naming for sizes (e.g., S, M, L for fonts)
4. All new layout-related constants should be added to KSizes for reusability

### Widget Structure

1. Main feature widgets should be stateful when managing complex state
2. Smaller, presentational components should be stateless
3. Each widget should be in its own file
4. Test-related widget components should be marked with @visibleForTesting

## Best Practices

1. Keep widget files focused on a single responsibility
2. Maintain a clear separation between presentation and business logic
3. Follow a consistent pattern for state management implementation
4. Implement interfaces for external services
5. All business logic should be testable and independent of UI

## Testing Guidelines

1. Directory Structure:

   ```
   test/
     └── feature_name/
         ├── application/
         │   └── feature_cubit_test.dart
         ├── domain/
         │   └── feature_model_test.dart
         ├── infrastructure/
         │   ├── dtos/
         │   │   └── feature_dto_test.dart
         │   └── feature_service_test.dart
         └── presentation/
             ├── feature_page_test.dart
             └── widgets/
                 └── feature_widget_test.dart
   ```

2. Testing Requirements:

   - All business logic must have unit tests
   - All widgets must have widget tests
   - Mock all external dependencies
   - Test files should mirror source code structure

3. Testing Conventions:

   - Test files should end with `_test.dart`
   - Use meaningful test group and test case names
   - Each test should focus on a single behavior
   - Maintain test independence (no shared state)

4. Testability Guidelines:
   - Keep UI logic separate from business logic
   - Avoid static methods for testable code
   - Use interfaces for external services
   - Provide test keys for important UI elements

# Domain Layer Guidelines

## Directory Structure

```
lib/
  └── feature_name/
      └── domain/
          ├── i_feature_service.dart
          └── feature_model.dart
```

## Domain Layer Conventions

### Model Structure

1. Models must:

   - Be immutable
   - Use freezed annotation
   - Have an empty constructor with default values

2. Model Properties:
   - Use proper types (no dynamic)
   - Include proper documentation

### Interface Structure

1. Interfaces must:

   - Define clear contract for implementations
   - Be prefixed with 'I'
   - Include method documentation
   - Define error cases and types
   - Return Result<T, E> for operations that can fail (using result_type: ^0.0.1 package)

2. Interface Methods:
   - Should be future-based for async operations
   - Have clear parameter names
   - Use Result<T, E> as return type
   - Document possible error types in E

## Naming Conventions

### Files

1. Model files:

   - Use `_model.dart` suffix
   - Use snake_case
   - Be descriptive of the model content

2. Interface files:
   - Use `i_` prefix
   - Use `_service.dart` suffix for services
   - Use snake_case

### Classes

1. Model classes:

   - Use PascalCase
   - End with 'Model'
   - Match their file names

2. Interface classes:
   - Use PascalCase
   - Start with 'I'
   - End with 'Service' for services

## Code Organization

1. Models:

   - One model per file
   - Group related models in same directory

2. Interfaces:
   - One interface per file
   - Define clear method contracts
   - Include error types
   - Document all methods

## Best Practices

1. Domain Models:

   - Keep models focused and specific
   - Use proper value types
   - Include validation logic
   - Use empty constructor with defaults

2. Interfaces:
   - Define clear method contracts
   - Use Result type for error handling
   - Keep methods focused
   - Document error types

## Testing Guidelines

1. Directory Structure:

   ```
   test/
     └── feature_name/
         └── domain/
             ├── feature_model_test.dart
             └── feature_service_test.dart
   ```

2. Model Testing:

   - Test empty constructor defaults
   - Test copyWith methods
   - Test equality comparisons
   - Test validation logic

3. Testing Conventions:
   - Group tests logically
   - Test success cases (Result.success)
   - Test failure cases (Result.failure)
   - Use meaningful test names

## Code Example

```dart

@freezed
class FeatureModel with _$FeatureModel {
  const factory FeatureModel({
    @Default('') String id,
    @Default('') String name,
    @Default(false) bool isActive,
  }) = _FeatureModel;
}
import 'package:result_type/result_type.dart';

abstract class IFeatureService {
  /// Fetches feature by ID.
  ///
  /// Returns [Result.failure] with [FeatureError.notFound] if feature doesn't exist.
  Future<Result<FeatureModel, FeatureError>> getFeature(String id);

  /// Creates a new feature.
  ///
  /// Returns [Result.failure] with [FeatureError.validation] if validation fails.
  Future<Result<FeatureModel, FeatureError>> createFeature(FeatureModel feature);
}
```

# Infrastructure Layer Guidelines

## Directory Structure

```
lib/
  └── feature_name/
      └── infrastructure/
          ├── dtos/
          │   └── feature_dto.dart
          ├── constants/
          │   └── feature_api_keys.dart
          └── feature_service.dart
```

## Infrastructure Layer Conventions

### DTO Structure

1. DTOs must:

   - Be immutable
   - Use freezed annotation
   - Have an empty constructor with default values
   - Include fromJson/toJson methods
   - Have toDomain() method to convert to domain model

2. DTO Properties:
   - Match API response structure
   - Use proper types (no dynamic)
   - Include proper documentation
   - Handle null values appropriately

### API Keys Structure

1. API Keys must:

   - Be in a separate constants file
   - Use static const strings
   - Follow proper naming convention
   - Include proper documentation

2. API Keys file should:
   - Be named `feature_api_keys.dart`
   - Group related keys together
   - Include endpoint paths
   - Document key usage

### Service Implementation Structure

1. Services must:

   - Implement domain interface
   - Handle all error cases
   - Convert DTOs to domain models
   - Use Result type for error handling
   - Include proper error mapping
   - Use API keys from constants

2. Service Methods:
   - Handle network errors
   - Map API errors to domain errors
   - Convert DTOs to domain models
   - Return Result<T, E> types

## Naming Conventions

### Files

1. DTO files:

   - Use `_dto.dart` suffix
   - Use snake_case
   - Match API resource names

2. Service files:

   - Remove 'i\_' prefix from interface name
   - Use `_service.dart` suffix
   - Use snake_case

3. API Keys files:
   - Use `_api_keys.dart` suffix
   - Use feature name prefix
   - Use snake_case

### Classes

1. DTO classes:

   - Use PascalCase
   - End with 'Dto'
   - Match their file names

2. Service classes:
   - Use PascalCase
   - Remove 'I' prefix from interface name
   - End with 'Service'

## Code Organization

1. DTOs:

   - One DTO per file
   - Group in dtos folder
   - Include JSON serialization
   - Include domain conversion

2. Services:

   - One service per file
   - Handle all error cases
   - Include proper logging
   - Document error handling

3. API Keys:
   - Group by feature
   - Include endpoints
   - Document usage
   - Keep in constants folder

## Best Practices

1. DTOs:

   - Match API structure exactly
   - Handle null values safely
   - Include proper JSON serialization
   - Provide domain model conversion

2. Services:
   - Handle all network errors
   - Map to domain errors
   - Use Result type consistently
   - Log important events
   - Use API keys from constants

## Code Example

```dart
import 'package:result_type/result_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import './constants/feature_api_keys.dart';

// API Keys
abstract class FeatureApiKeys {
  static const baseUrl = 'https://api.example.com';
  static const featureEndpoint = '/features';
  static const apiKey = 'your_api_key';

  // Endpoints
  static String getFeatureById(String id) => '$featureEndpoint/$id';
  static String createFeature() => featureEndpoint;
}

@freezed
class FeatureDto with _$FeatureDto {
  const factory FeatureDto({
    @Default('') String id,
    @Default('') String name,
    @Default(false) @JsonKey(name: 'is_active') bool isActive,
  }) = _FeatureDto;

  factory FeatureDto.fromJson(Map<String, dynamic> json) =>
      _$FeatureDtoFromJson(json);

  FeatureModel toDomain() => FeatureModel(
    id: id,
    name: name,
    isActive: isActive,
  );
}

class FeatureService implements IFeatureService {
  final ApiClient _apiClient;

  FeatureService(this._apiClient);

  @override
  Future<Result<FeatureModel, FeatureError>> getFeature(String id) async {
    try {
      final response = await _apiClient.get(
        FeatureApiKeys.getFeatureById(id),
        headers: {'Authorization': 'Bearer ${FeatureApiKeys.apiKey}'},
      );
      final dto = FeatureDto.fromJson(response.data);
      return Success(dto.toDomain());
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return Failure(FeatureError.notFound);
      }
      return Failure(FeatureError.unknown);
    }
  }

  @override
  Future<Result<FeatureModel, FeatureError>> createFeature(FeatureModel feature) async {
    try {
      final response = await _apiClient.post(
        FeatureApiKeys.createFeature(),
        headers: {'Authorization': 'Bearer ${FeatureApiKeys.apiKey}'},
        data: feature.toJson(),
      );
      final dto = FeatureDto.fromJson(response.data);
      return Success(dto.toDomain());
    } on ApiException catch (e) {
      if (e.statusCode == 400) {
        return Failure(FeatureError.validation);
      }
      return Failure(FeatureError.unknown);
    }
  }
}
```

# Presentation Layer Guidelines

## Directory Structure

```
lib/
  └── feature_name/
      └── presentation/
          ├── feature_page.dart
          └── widgets/
              └── feature_widget.dart
```

## Presentation Layer Conventions

### Page Structure

1. Pages must:

   - Use BlocProvider for state management
   - Follow single responsibility principle
   - Handle all UI states (loading, error, success)
   - Use proper layout constants from KSizes

2. Page Properties:
   - Keep state in Cubit
   - Use proper widget keys for testing
   - Follow proper lifecycle management
   - Handle proper error display

### Widget Structure

1. Widgets must:

   - Be focused on single responsibility
   - Use KSizes for all measurements
   - Follow proper widget lifecycle
   - Be properly documented
   - Use proper error boundaries

2. Widget Properties:
   - Use named parameters
   - Document required parameters
   - Use proper types
   - Follow immutability principles

## Naming Conventions

### Files

1. Page files:

   - Use `_page.dart` suffix
   - Use snake_case
   - Be descriptive of content

2. Widget files:
   - Use `_widget.dart` suffix
   - Use snake_case
   - Describe widget purpose

### Classes

1. Page classes:

   - Use PascalCase
   - End with 'Page'
   - Match their file names

2. Widget classes:
   - Use PascalCase
   - End with 'Widget' if not obvious
   - Match their file names

## Code Organization

1. Pages:

   - One page per file
   - Include BlocProvider setup
   - Handle all UI states
   - Use proper error boundaries

2. Widgets:
   - Group related widgets in widgets folder
   - Keep widgets focused and small
   - Extract reusable components
   - Document widget purpose

## Best Practices

1. Layout:

   - Use KSizes for all measurements
   - Never use hard-coded values
   - Follow proper spacing guidelines
   - Use proper widget constraints

2. State Management:

   - Use BlocBuilder for state consumption
   - Use BlocListener for side effects
   - Keep widgets pure
   - Handle all state cases

3. Error Handling:
   - Show user-friendly error messages
   - Provide retry mechanisms
   - Handle edge cases
   - Use proper error boundaries

## Code Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeatureCubit()..initialize(),
      child: const FeatureView(),
    );
  }
}

class FeatureView extends StatelessWidget {
  const FeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(KSize.margin4x),
        child: BlocBuilder<FeatureCubit, FeatureState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const LoadingWidget();
            }

            if (state.hasError) {
              return ErrorWidget(
                onRetry: () => context.read<FeatureCubit>().initialize(),
              );
            }

            return const FeatureContent();
          },
        ),
      ),
    );
  }
}

class FeatureContent extends StatelessWidget {
  const FeatureContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: KSize.margin4x),
        Text(
          'Feature Title',
          style: TextStyle(
            fontSize: KSize.fontSizeL,
            fontWeight: KSize.fontWeightBold,
          ),
        ),
        SizedBox(height: KSize.margin2x),
        const FeatureWidget(),
      ],
    );
  }
}

class FeatureWidget extends StatelessWidget {
  const FeatureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(KSize.margin4x),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KSize.radiusDefault),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: BlocBuilder<FeatureCubit, FeatureState>(
        builder: (context, state) {
          return Column(
            children: [
              // Widget content using KSizes for layout
            ],
          );
        },
      ),
    );
  }
}

```

# State Management Guidelines

## Directory Structure

```
lib/
  └── feature_name/
      └── application/
          ├── feature_cubit.dart
          └── feature_state.dart
```

## State Management Conventions

### State Class Structure

1. State classes must:
   - Use freezed annotation
   - Have a private constructor with \_()
   - Have factory constructor for initial state
   - Be immutable

### Cubit Class Structure

1. Cubit classes should:
   - Have a single responsibility
   - Handle a specific feature or workflow
   - Contain only business logic
2. Constructor must:
   - Accept all required services via parameters
   - Use GetIt fallback for dependencies

### Naming Conventions

1. Files:
   - State file: `feature_state.dart`
   - Cubit file: `feature_cubit.dart`
2. Classes:
   - State class: `FeatureState`
   - Cubit class: `FeatureCubit`
3. Methods:
   - initialize() for setup
   - retryX() for error recovery
   - clear descriptive method names for actions

## State Properties

1. Common State Properties:

   ```dart
   @freezed
   class FeatureState with _$FeatureState {
     const FeatureState._(); // Private constructor for making the class extendable

     const factory FeatureState({
       required DataState<MainData> dataState,
       @Default(false) bool secondaryData,
     }) = _FeatureState;

     // Helper getters for derived states
     bool get isLoading => dataState.isLoading;
     bool get hasError => dataState.hasError;
     bool get isSuccess => dataState.isSuccess;
     bool get isIdle => dataState.isIdle;

     factory FeatureState.initial() => const FeatureState(
       dataState: DataState.idle(),
       secondaryData: false,
     );
   }
   ```

## Error Handling

1. Use DataState for handling loading/error/success states
2. Show appropriate UI feedback for errors

## Best Practices

1. State Management:

   - Use DataState for async operations
   - Provide helper getters for common state checks
   - Keep state immutable
   - Use proper state tracking for operations

2. Testing:
   - Test all state transitions
   - Test error handling
   - Mock all dependencies
   - Test retry mechanisms

## Code Example

```dart
class FeatureCubit extends Cubit<FeatureState> {
  final IFeatureService _service;

  FeatureCubit({
    IFeatureService? service,
  })  : _service = service ?? getdep<IFeatureService>(),
        super(FeatureState.initial());

  Future<void> initialize({required String param}) async {
    emit(state.copyWith(
      dataState: const DataState.loading(),
    ));

    try {
      final data = await _service.getData(param);
      emit(state.copyWith(
        dataState: DataState.success(data),
      ));
    } catch (e) {
      emit(state.copyWith(
        dataState: const DataState.error(),
      ));
    }
  }

  Future<void> operation() async {
    // Operation logic
  }
}
```
