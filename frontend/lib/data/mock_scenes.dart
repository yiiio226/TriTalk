import '../models/scene.dart';

const List<Scene> mockScenes = [
  Scene(
    id: 's1',
    title: 'Rent an Apartment',
    description: 'Ask the landlord about early check-in.',
    emoji: '🏠',
    aiRole: 'Jessica (Landlord)',
    userRole: 'Tenant',
    initialMessage: 'Hi! Thanks for your booking. How can I help you?',
    category: 'Travel',
  ),
  Scene(
    id: 's2',
    title: 'Ordering Coffee',
    description: 'Order a latte with specific customizations.',
    emoji: '☕',
    aiRole: 'Barista',
    userRole: 'Customer',
    initialMessage: 'Hi there! What can I get started for you today?',
    category: 'Daily Life',
  ),
  Scene(
    id: 's3',
    title: 'Work Email',
    description: 'Decline a request from a colleague politely.',
    emoji: '💼',
    aiRole: 'Mark (Colleague)',
    userRole: 'Colleague',
    initialMessage: 'Hey, do you have time to help me with this report by EOD?',
    category: 'Business',
  ),
  Scene(
    id: 's4',
    title: 'Dating App',
    description: 'Break the ice with a new match.',
    emoji: '💕',
    aiRole: 'Alex',
    userRole: 'User',
    initialMessage: 'Hey! I saw you like hiking too. What\'s your favorite trail?',
    category: 'Social',
  ),
];
