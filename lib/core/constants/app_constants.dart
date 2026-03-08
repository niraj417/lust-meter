class AppConstants {
  // App Info
  static const appName = 'Lust Meter';
  static const appVersion = '1.0.0';

  // Firestore Collections
  static const usersCollection = 'users';
  static const partnersCollection = 'partners';
  static const partnerRequestsCollection = 'partner_requests';
  static const positionsCollection = 'positions';
  static const challengesCollection = 'challenges';
  static const kinksCollection = 'kinks';
  static const kinkInteractionsCollection = 'kink_interactions';
  static const doctorsCollection = 'doctors';
  static const messagesCollection = 'messages'; // Subcollection
  static const gameSessionsCollection = 'game_sessions';

  // Firestore Fields
  static const fieldUid = 'uid';
  static const fieldPartnerId = 'partnerId';
  static const fieldLustScore = 'lustScore';
  static const fieldEmotionalScore = 'emotionalScore';

  // Gemini
  static const geminiModel = 'gemini-2.0-flash';

  // Shared Prefs Keys
  static const prefKeyOnboarded = 'is_onboarded';
  static const prefKeyAgeVerified = 'age_verified';
}

class AppRoutes {
  static const splash = '/';
  static const ageGate = '/age-gate';
  static const login = '/login';
  static const signup = '/signup';
  static const onboarding = '/onboarding';
  static const shell = '/shell';
  static const home = '/shell/home';
  static const games = '/shell/games';
  static const explore = '/shell/explore';
  static const partner = '/shell/partner';
  static const profile = '/shell/profile';
  static const truthOrDare = '/games/truth-or-dare';
  static const fantasyCards = '/games/fantasy-cards';
  static const spinWheel = '/games/spin-wheel';
  static const positionDetail = '/explore/position/:id';
  static const challengeDetail = '/explore/challenge/:id';
  static const connectPartner = '/partner/connect';
  static const rewards = '/profile/rewards';
  static const compatibilityQuiz = '/compatibility-quiz';
  static const consultation = '/consultation';
  static const chat = '/chat/:connectionId';
}
