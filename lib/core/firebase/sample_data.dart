import 'package:cloud_firestore/cloud_firestore.dart';

const demoUserId = 'demo-user';

const _todayId = '2023-12-13';

final sampleUserProfile = {
  'displayName': 'Martin Lee',
  'avatarUrl': 'assets/images/app/logo.png',
  'birthDate': '1998-08-01',
  'birthTime': '02:00',
  'birthPlace': 'New York, NY',
  'location': 'New York, USA',
  'sunSign': 'Leo',
  'moonSign': 'Virgo',
  'ascendantSign': 'Libra',
  'phoneNumber': '+1 921 345 67 89',
  'email': 'martin.lee@email.com',
  'bioTable': [
    {'label': 'Element', 'value': 'Fire 55%'},
    {'label': 'Mode', 'value': 'Fixed 64%'},
    {'label': 'Polarity', 'value': 'Masculine 60%'},
    {'label': 'Ruling Planet', 'value': 'Sun & Venus'},
  ],
  'friends': [
    {
      'name': 'Amanda Bynes',
      'compatibility': '88% Compatible',
      'signs': ['Virgo', 'Leo', 'Libra'],
      'avatarUrl': 'assets/images/app/navigation/Profile-pressed.png',
    },
    {
      'name': 'Natalie Haris',
      'compatibility': '82% Compatible',
      'signs': ['Libra', 'Sagittarius', 'Cancer'],
      'avatarUrl': 'assets/images/app/navigation/Profile-default.png',
    },
    {
      'name': 'Calvin Maro',
      'compatibility': '76% Compatible',
      'signs': ['Capricorn', 'Scorpio', 'Aries'],
      'avatarUrl': 'assets/images/app/logo.png',
    },
  ],
  'notificationPrefs': {
    'dailyDigest': true,
    'friendAdded': true,
    'friendAccepted': false,
  },
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
};

final sampleNotificationPrefs = {
  'dailyDigest': true,
  'friendAdded': true,
  'friendAccepted': false,
  'updatedAt': FieldValue.serverTimestamp(),
};

const Map<String, dynamic> samplePlanetsDoc = {
  'dateId': _todayId,
  'cards': [
    {
      'name': 'Venus',
      'zodiac': 'Capricorn',
      'degrees': "21°, 16' 38\"",
      'description':
          'This transit is marked by high emotional tension. People become more sensitive, passionate, vulnerable, so extremes in the expression of feelings appear.',
      'imageUrl': 'assets/images/app/planets/Venus.png',
      'accentColor': '#EC9E41',
    },
    {
      'name': 'Moon',
      'zodiac': 'Taurus',
      'degrees': "07°, 05' 28\"",
      'description':
          'People become more sensitive, passionate, vulnerable, so extremes in the expression of feelings appear.',
      'imageUrl': 'assets/images/app/planets/Moon.png',
      'accentColor': '#D9DBDB',
    },
    {
      'name': 'Sun',
      'zodiac': 'Aries',
      'degrees': "00°, 00' 00\"",
      'description':
          'Ut enim ad minim veniam, quis nostrud exerci tation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
      'imageUrl': 'assets/images/app/planets/Sun.png',
      'accentColor': '#F19550',
    },
  ],
};

const Map<String, dynamic> sampleYouTodayDoc = {
  'dateId': _todayId,
  'sections': [
    {
      'title': 'Health',
      'planets': [
        {
          'planet': 'Sun',
          'zodiac': 'Capricorn',
          'degrees': "00°, 30' 14\"",
        },
        {
          'planet': 'Moon',
          'zodiac': 'Taurus',
          'degrees': "07°, 05' 28\"",
        },
        {
          'planet': 'Mars',
          'zodiac': 'Sagittarius',
          'degrees': "20°, 24' 04\"",
        },
        {
          'planet': 'Venus',
          'zodiac': 'Scorpio',
          'degrees': "21°, 16' 38\"",
        },
      ],
      'description':
          'This day would be best to devote yourself to yoga and meditation. Even if this happens at home, create a unique atmosphere of harmony for yourself and choose the exercises you need. Watch your breathing.',
    },
    {
      'title': 'Finance',
      'planets': [
        {
          'planet': 'Mercury',
          'zodiac': 'Capricorn',
          'degrees': "00°, 51' 37\"",
        },
        {
          'planet': 'Mars',
          'zodiac': 'Sagittarius',
          'degrees': "20°, 24' 04\"",
        },
        {
          'planet': 'Jupiter',
          'zodiac': 'Taurus',
          'degrees': "05°, 42' 19\"",
        },
      ],
      'description':
          'First of all, this applies to executives, managers and civil servants. Your organizational skill will increase significantly. If you are expecting a promotion, you may be told about it today.',
    },
    {
      'title': 'Relationship',
      'planets': [
        {
          'planet': 'Jupiter',
          'zodiac': 'Capricorn',
          'degrees': "00°, 00' 00\"",
        },
        {
          'planet': 'Mars',
          'zodiac': 'Capricorn',
          'degrees': "00°, 00' 00\"",
        },
        {
          'planet': 'Saturn',
          'zodiac': 'Capricorn',
          'degrees': "00°, 00' 00\"",
        },
      ],
      'description':
          'Today your significant other will want something from you that is incomprehensible even to her. You will have to either show the wonders of telepathy and fulfill her desire, or stoically endure the whims.',
    },
  ],
};

const Map<String, dynamic> sampleTipDoc = {
  'dateId': _todayId,
  'text': 'Brave against sheep, but himself a sheep against the brave',
};

const List<Map<String, dynamic>> sampleHoroscopeArticles = [
  {
    'id': 'mercury-retrograde',
    'title': 'Mercury Retrograde',
    'date': 'Dec 13, 2023',
    'body':
        'Starting on December 13, 2023, Mercury will begin to “back away”, returning to its normal trajectory only in 2024. During this time the planet will first be in the sign of Capricorn, and then in the sign of Aquarius.',
    'buttonLabel': 'Go Deeper',
  },
];

const List<Map<String, dynamic>> sampleMatchProfiles = [
  {
    'id': 'ian-johnson',
    'name': 'Ian Johnson',
    'pronouns': 'He/Him',
    'location': 'New York, NY',
    'sunSign': 'Leo',
    'moonSign': 'AC Libra',
    'tags': ['Friendship', 'Chat'],
    'category': 'friendship',
    'bio':
        'I am a confident and charismatic guy in my mid-twenties, standing at around 5’11”. I have chiseled features, with a strong jawline, high cheekbones, and warm brown eyes.',
    'avatarUrl': 'assets/images/app/navigation/Profile-pressed.png',
  },
  {
    'id': 'victoria-donovan',
    'name': 'Victoria Donovan',
    'pronouns': 'She/Her',
    'location': 'Boston, MA',
    'sunSign': 'Libra',
    'moonSign': 'AC Capricorn',
    'tags': ['Friendship', 'Chat'],
    'category': 'romantic',
    'bio':
        'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    'avatarUrl': 'assets/images/app/navigation/Profile-default.png',
  },
  {
    'id': 'leah-lopez',
    'name': 'Leah Lopez',
    'pronouns': 'She/Her',
    'location': 'Houston, TX',
    'sunSign': 'Virgo',
    'moonSign': 'AC Gemini',
    'tags': ['Friendship', 'Chat'],
    'category': 'new',
    'bio':
        'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    'avatarUrl': 'assets/images/app/logo.png',
  },
];

const List<Map<String, dynamic>> sampleCharacteristics = [
  {
    'id': 'sun-in-leo',
    'title': 'Sun in Leo',
    'house': '10th House',
    'description':
        'You are fundamentally bold and proud. You love attention and pay it back with charm.',
    'imageUrl': 'assets/images/app/planet-icons/Sun.png',
    'order': 0,
  },
  {
    'id': 'moon-in-virgo',
    'title': 'Moon in Virgo',
    'house': '11th House',
    'description':
        'Sensitive and intuitive. You rarely express feelings openly, relying on reason.',
    'imageUrl': 'assets/images/app/planet-icons/Moon.png',
    'order': 1,
  },
  {
    'id': 'ac-in-libra',
    'title': 'AC in Libra',
    'house': '1st House',
    'description':
        'Gives the ability to find a common language with almost any person.',
    'imageUrl': 'assets/images/app/planet-icons/Venus.png',
    'order': 2,
  },
];

final List<Map<String, dynamic>> sampleChatMessages = [
  {
    'sender': 'advisor',
    'text':
        'Good morning, Martin. I see Mercury squaring your natal Moon today. How would you like to focus our reading?',
    'createdAt': FieldValue.serverTimestamp(),
  },
  {
    'sender': 'user',
    'text': 'Hi Advisor, I want to focus on career & creativity.',
    'createdAt': FieldValue.serverTimestamp(),
  },
  {
    'sender': 'advisor',
    'text':
        'Great. I recalculated your chart using the Match screen layout you love — swipe each card to expand insights.',
    'createdAt': FieldValue.serverTimestamp(),
  },
];

