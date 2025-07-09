import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:bloquinho/core/models/user_profile.dart';
import 'package:bloquinho/core/services/user_profile_service.dart';
import 'package:bloquinho/shared/providers/user_profile_provider.dart';
import 'package:bloquinho/features/profile/screens/profile_screen.dart';
import 'package:bloquinho/features/profile/widgets/profile_avatar.dart';

// Generate mocks
@GenerateMocks([UserProfileService])
import 'user_profile_test.mocks.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('Should create UserProfile with required fields', () {
      final profile = UserProfile.create(
        name: 'João Silva',
        email: 'joao@email.com',
      );

      expect(profile.name, equals('João Silva'));
      expect(profile.email, equals('joao@email.com'));
      expect(profile.createdAt, isNotNull);
      expect(profile.updatedAt, isNotNull);
      expect(profile.id, isNotNull);
      expect(profile.isPublic, isTrue);
    });

    test('Should serialize and deserialize UserProfile correctly', () {
      final originalProfile = UserProfile(
        id: 'test_id',
        name: 'Maria Santos',
        email: 'maria@email.com',
        bio: 'Desenvolvedora Flutter',
        phone: '+55 11 99999-9999',
        location: 'São Paulo, Brasil',
        website: 'https://maria.dev',
        profession: 'Desenvolvedora',
        interests: ['Flutter', 'Dart', 'Mobile'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        isPublic: true,
      );

      // Serialize to JSON
      final json = originalProfile.toJson();
      expect(json['id'], equals('test_id'));
      expect(json['name'], equals('Maria Santos'));
      expect(json['email'], equals('maria@email.com'));
      expect(json['bio'], equals('Desenvolvedora Flutter'));
      expect(json['phone'], equals('+55 11 99999-9999'));
      expect(json['location'], equals('São Paulo, Brasil'));
      expect(json['website'], equals('https://maria.dev'));
      expect(json['profession'], equals('Desenvolvedora'));
      expect(json['interests'], equals(['Flutter', 'Dart', 'Mobile']));
      expect(json['isPublic'], isTrue);

      // Deserialize from JSON
      final deserializedProfile = UserProfile.fromJson(json);
      expect(deserializedProfile.id, equals(originalProfile.id));
      expect(deserializedProfile.name, equals(originalProfile.name));
      expect(deserializedProfile.email, equals(originalProfile.email));
      expect(deserializedProfile.bio, equals(originalProfile.bio));
      expect(deserializedProfile.phone, equals(originalProfile.phone));
      expect(deserializedProfile.location, equals(originalProfile.location));
      expect(deserializedProfile.website, equals(originalProfile.website));
      expect(
          deserializedProfile.profession, equals(originalProfile.profession));
      expect(deserializedProfile.interests, equals(originalProfile.interests));
      expect(deserializedProfile.isPublic, equals(originalProfile.isPublic));
    });

    test('Should handle JSON string serialization', () {
      final profile = UserProfile.create(
        name: 'Pedro Oliveira',
        email: 'pedro@email.com',
      );

      final jsonString = profile.toJsonString();
      expect(jsonString, isA<String>());
      expect(jsonString.isNotEmpty, isTrue);

      final deserializedProfile = UserProfile.fromJsonString(jsonString);
      expect(deserializedProfile.name, equals(profile.name));
      expect(deserializedProfile.email, equals(profile.email));
    });

    test('Should validate profile correctly', () {
      final validProfile = UserProfile.create(
        name: 'Ana Costa',
        email: 'ana@email.com',
      );
      expect(validProfile.isValid, isTrue);

      final invalidEmailProfile = UserProfile.create(
        name: 'Ana Costa',
        email: 'email_inválido',
      );
      expect(invalidEmailProfile.isValid, isFalse);

      final emptyNameProfile = UserProfile.create(
        name: '',
        email: 'ana@email.com',
      );
      expect(emptyNameProfile.isValid, isFalse);
    });

    test('Should calculate initials correctly', () {
      final profile1 = UserProfile.create(
        name: 'João Silva',
        email: 'joao@email.com',
      );
      expect(profile1.initials, equals('JS'));

      final profile2 = UserProfile.create(
        name: 'Maria',
        email: 'maria@email.com',
      );
      expect(profile2.initials, equals('M'));

      final profile3 = UserProfile.create(
        name: 'Ana Paula Santos',
        email: 'ana@email.com',
      );
      expect(profile3.initials, equals('AS'));
    });

    test('Should calculate age correctly', () {
      final now = DateTime.now();
      final birthDate = DateTime(now.year - 25, now.month, now.day);

      final profile = UserProfile.create(
        name: 'Carlos Mendes',
        email: 'carlos@email.com',
      ).copyWith(birthDate: birthDate);

      expect(profile.age, equals(25));

      final profileWithoutBirthDate = UserProfile.create(
        name: 'Carlos Mendes',
        email: 'carlos@email.com',
      );
      expect(profileWithoutBirthDate.age, isNull);
    });

    test('Should check if profile is complete', () {
      final incompleteProfile = UserProfile.create(
        name: 'Test User',
        email: 'test@email.com',
      );
      expect(incompleteProfile.isComplete, isFalse);

      final completeProfile = incompleteProfile.copyWith(
        bio: 'Test bio',
        avatarPath: '/path/to/avatar.jpg',
      );
      expect(completeProfile.isComplete, isTrue);
    });

    test('Should copy profile with modified fields', () {
      final originalProfile = UserProfile.create(
        name: 'Original Name',
        email: 'original@email.com',
      );

      final modifiedProfile = originalProfile.copyWith(
        name: 'Modified Name',
        bio: 'New bio',
      );

      expect(modifiedProfile.name, equals('Modified Name'));
      expect(modifiedProfile.email, equals('original@email.com'));
      expect(modifiedProfile.bio, equals('New bio'));
      expect(modifiedProfile.id, equals(originalProfile.id));
    });
  });

  group('ProfileValidator Tests', () {
    test('Should validate empty name', () {
      final profile = UserProfile.create(
        name: '',
        email: 'test@email.com',
      );

      final errors = ProfileValidator.validate(profile);
      expect(errors, contains(ProfileValidationError.emptyName));
    });

    test('Should validate short name', () {
      final profile = UserProfile.create(
        name: 'A',
        email: 'test@email.com',
      );

      final errors = ProfileValidator.validate(profile);
      expect(errors, contains(ProfileValidationError.nameTooShort));
    });

    test('Should validate invalid email', () {
      final profile = UserProfile.create(
        name: 'Test User',
        email: 'invalid-email',
      );

      final errors = ProfileValidator.validate(profile);
      expect(errors, contains(ProfileValidationError.invalidEmail));
    });

    test('Should validate bio length', () {
      final longBio = 'a' * 501;
      final profile = UserProfile.create(
        name: 'Test User',
        email: 'test@email.com',
      ).copyWith(bio: longBio);

      final errors = ProfileValidator.validate(profile);
      expect(errors, contains(ProfileValidationError.bioTooLong));
    });

    test('Should validate phone format', () {
      final profile = UserProfile.create(
        name: 'Test User',
        email: 'test@email.com',
      ).copyWith(phone: '123');

      final errors = ProfileValidator.validate(profile);
      expect(errors, contains(ProfileValidationError.invalidPhone));
    });

    test('Should validate website format', () {
      final profile = UserProfile.create(
        name: 'Test User',
        email: 'test@email.com',
      ).copyWith(website: 'invalid-website');

      final errors = ProfileValidator.validate(profile);
      expect(errors, contains(ProfileValidationError.invalidWebsite));
    });

    test('Should validate correct profile', () {
      final profile = UserProfile.create(
        name: 'Test User',
        email: 'test@email.com',
      ).copyWith(
        bio: 'Valid bio',
        phone: '+55 11 99999-9999',
        website: 'https://example.com',
      );

      final errors = ProfileValidator.validate(profile);
      expect(errors, isEmpty);
    });
  });

  group('ProfileValidationError Messages', () {
    test('Should return correct error messages', () {
      expect(ProfileValidationError.emptyName.message,
          equals('Nome é obrigatório'));
      expect(ProfileValidationError.emptyEmail.message,
          equals('Email é obrigatório'));
      expect(ProfileValidationError.invalidEmail.message,
          equals('Email inválido'));
      expect(ProfileValidationError.nameTooShort.message,
          equals('Nome deve ter pelo menos 2 caracteres'));
      expect(ProfileValidationError.bioTooLong.message,
          equals('Bio deve ter no máximo 500 caracteres'));
      expect(ProfileValidationError.invalidPhone.message,
          equals('Telefone inválido'));
      expect(ProfileValidationError.invalidWebsite.message,
          equals('Website inválido'));
    });
  });

  group('UserProfileService Tests', () {
    late MockUserProfileService mockService;

    setUp(() {
      mockService = MockUserProfileService();
    });

    test('Should create new profile', () async {
      final expectedProfile = UserProfile.create(
        name: 'Test User',
        email: 'test@email.com',
      );

      when(mockService.createProfile(
        name: anyNamed('name'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => expectedProfile);

      final result = await mockService.createProfile(
        name: 'Test User',
        email: 'test@email.com',
      );

      expect(result.name, equals('Test User'));
      expect(result.email, equals('test@email.com'));
      verify(mockService.createProfile(
        name: 'Test User',
        email: 'test@email.com',
      )).called(1);
    });

    test('Should update existing profile', () async {
      final originalProfile = UserProfile.create(
        name: 'Original Name',
        email: 'original@email.com',
      );

      final updatedProfile = originalProfile.copyWith(
        name: 'Updated Name',
        bio: 'Updated bio',
      );

      when(mockService.updateProfile(
        name: anyNamed('name'),
        bio: anyNamed('bio'),
      )).thenAnswer((_) async => updatedProfile);

      final result = await mockService.updateProfile(
        name: 'Updated Name',
        bio: 'Updated bio',
      );

      expect(result.name, equals('Updated Name'));
      expect(result.bio, equals('Updated bio'));
      verify(mockService.updateProfile(
        name: 'Updated Name',
        bio: 'Updated bio',
      )).called(1);
    });

    test('Should get current profile', () async {
      final expectedProfile = UserProfile.create(
        name: 'Test User',
        email: 'test@email.com',
      );

      when(mockService.getCurrentProfile())
          .thenAnswer((_) async => expectedProfile);

      final result = await mockService.getCurrentProfile();

      expect(result?.name, equals('Test User'));
      expect(result?.email, equals('test@email.com'));
      verify(mockService.getCurrentProfile()).called(1);
    });

    test('Should check if profile exists', () async {
      when(mockService.hasProfile()).thenAnswer((_) async => true);

      final result = await mockService.hasProfile();

      expect(result, isTrue);
      verify(mockService.hasProfile()).called(1);
    });

    test('Should get profile stats', () async {
      final stats = {
        'isComplete': true,
        'hasAvatar': false,
        'daysCreated': 10,
        'interestsCount': 3,
      };

      when(mockService.getProfileStats()).thenAnswer((_) async => stats);

      final result = await mockService.getProfileStats();

      expect(result['isComplete'], isTrue);
      expect(result['hasAvatar'], isFalse);
      expect(result['daysCreated'], equals(10));
      expect(result['interestsCount'], equals(3));
      verify(mockService.getProfileStats()).called(1);
    });

    test('Should delete profile', () async {
      when(mockService.deleteProfile()).thenAnswer((_) async => {});

      await mockService.deleteProfile();

      verify(mockService.deleteProfile()).called(1);
    });
  });

  group('Profile Widget Tests', () {
    testWidgets('ProfileScreen should show empty state when no profile',
        (tester) async {
      final mockService = MockUserProfileService();
      when(mockService.initialize()).thenAnswer((_) async => {});
      when(mockService.getCurrentProfile()).thenAnswer((_) async => null);
      when(mockService.getProfileStats()).thenAnswer((_) async => {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider
                .overrideWith((ref) => UserProfileNotifier(mockService)),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nenhum perfil encontrado'), findsOneWidget);
      expect(find.text('Criar Perfil'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('ProfileScreen should show loading state', (tester) async {
      final mockService = MockUserProfileService();
      when(mockService.initialize()).thenAnswer((_) async => {});
      when(mockService.getCurrentProfile()).thenAnswer((_) async => null);
      when(mockService.getProfileStats()).thenAnswer((_) async => {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider
                .overrideWith((ref) => UserProfileNotifier(mockService)),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ProfileAvatar should show initials when no avatar',
        (tester) async {
      final profile = UserProfile.create(
        name: 'João Silva',
        email: 'joao@email.com',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileAvatar(profile: profile),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('JS'), findsOneWidget);
    });

    testWidgets('ProfileAvatarPlaceholder should show person icon',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatarPlaceholder(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('ProfileAvatarCompact should be smaller', (tester) async {
      final profile = UserProfile.create(
        name: 'Test User',
        email: 'test@email.com',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileAvatarCompact(profile: profile),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );

      // Should be smaller than default size
      expect(container.constraints?.maxWidth, lessThan(50));
    });
  });

  group('Profile Extension Tests', () {
    test('Should create avatar widget from profile', () {
      final profile = UserProfile.create(
        name: 'Test User',
        email: 'test@email.com',
      );

      final avatar = profile.avatar();
      expect(avatar, isA<Widget>());

      final avatarCompact = profile.avatarCompact();
      expect(avatarCompact, isA<Widget>());

      final avatarLarge = profile.avatarLarge();
      expect(avatarLarge, isA<Widget>());
    });
  });
}
