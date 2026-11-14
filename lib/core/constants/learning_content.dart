import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CourseDef {
  const CourseDef({
    required this.key,
    required this.icon,
    required this.color,
    required this.lessons,
  });

  final String key;
  final IconData icon;
  final Color color;
  final List<Map<String, String>> lessons;
}

class CourseCatalog {
  CourseCatalog._();

  static const List<CourseDef> courses = [
    CourseDef(
      key: 'python',
      icon: Icons.terminal_rounded,
      color: AppColors.info,
      lessons: [
        {'uz': "Python o'rnatish va birinchi dastur", 'ru': 'Установка Python и первая программа'},
        {'uz': "O'zgaruvchilar va ma'lumot turlari", 'ru': 'Переменные и типы данных'},
        {'uz': 'Shartli operatorlar (if, elif, else)', 'ru': 'Условные операторы (if, elif, else)'},
        {'uz': 'Tsikllar: for va while', 'ru': 'Циклы: for и while'},
        {'uz': 'Funksiyalar va parametrlar', 'ru': 'Функции и параметры'},
        {'uz': "Ro'yxatlar va lug'atlar", 'ru': 'Списки и словари'},
        {'uz': 'Fayllar bilan ishlash', 'ru': 'Работа с файлами'},
        {'uz': 'Mini loyiha: kalkulyator', 'ru': 'Мини-проект: калькулятор'},
      ],
    ),
    CourseDef(
      key: 'english',
      icon: Icons.language_rounded,
      color: AppColors.roseGold,
      lessons: [
        {'uz': 'Alifbo va talaffuz asoslari', 'ru': 'Алфавит и основы произношения'},
        {'uz': 'Salomlashish va tanishuv', 'ru': 'Приветствие и знакомство'},
        {'uz': 'Present Simple zamoni', 'ru': 'Время Present Simple'},
        {'uz': 'Sonlar, sana va vaqt', 'ru': 'Числа, даты и время'},
        {'uz': 'Kundalik suhbat iboralari', 'ru': 'Фразы для повседневного общения'},
        {'uz': "O'tgan zamon (Past Simple)", 'ru': 'Прошедшее время (Past Simple)'},
        {'uz': 'Kelgusi rejalar (Future)', 'ru': 'Планы на будущее (Future)'},
        {'uz': "Mini loyiha: o'zingizni tanishtiring", 'ru': 'Мини-проект: рассказ о себе'},
      ],
    ),
    CourseDef(
      key: 'russian',
      icon: Icons.translate_rounded,
      color: AppColors.copper,
      lessons: [
        {'uz': 'Kirill alifbosi va talaffuz', 'ru': 'Кириллица и произношение'},
        {'uz': 'Salomlashish va kundalik iboralar', 'ru': 'Приветствие и повседневные фразы'},
        {'uz': 'Otlar va holatlar', 'ru': 'Существительные и падежи'},
        {'uz': "Fe'llar va zamonlar", 'ru': 'Глаголы и времена'},
        {'uz': 'Sifatlar va joylashuv', 'ru': 'Прилагательные и расположение'},
        {'uz': 'Rasmiy va norasmiy nutq', 'ru': 'Официальная и неформальная речь'},
        {'uz': "O'qish va tushunish mashqi", 'ru': 'Практика чтения и понимания'},
        {'uz': 'Mini loyiha: xat yozish', 'ru': 'Мини-проект: написание письма'},
      ],
    ),
    CourseDef(
      key: 'cybersecurity',
      icon: Icons.security_rounded,
      color: AppColors.success,
      lessons: [
        {'uz': 'Kiberxavfsizlik asoslari', 'ru': 'Основы кибербезопасности'},
        {'uz': 'Parollar va autentifikatsiya', 'ru': 'Пароли и аутентификация'},
        {'uz': 'Fishing va ijtimoiy muhandislik', 'ru': 'Фишинг и социальная инженерия'},
        {'uz': 'Parol menejerlari va 2FA', 'ru': 'Менеджеры паролей и 2FA'},
        {'uz': "Shaxsiy ma'lumotlarni himoya qilish", 'ru': 'Защита персональных данных'},
        {'uz': 'Wi-Fi va tarmoq xavfsizligi', 'ru': 'Безопасность Wi-Fi и сетей'},
        {'uz': 'Zararli dasturlar turlari', 'ru': 'Виды вредоносных программ'},
        {'uz': 'Raqamli gigiyena rejasi', 'ru': 'План цифровой гигиены'},
      ],
    ),
    CourseDef(
      key: 'ai',
      icon: Icons.psychology_rounded,
      color: AppColors.violet,
      lessons: [
        {'uz': "Sun'iy intellekt nima?", 'ru': 'Что такое искусственный интеллект?'},
        {'uz': "Mashinaviy o'rganish asoslari", 'ru': 'Основы машинного обучения'},
        {'uz': 'Neyron tarmoqlar bilan tanishuv', 'ru': 'Знакомство с нейронными сетями'},
        {'uz': 'Katta til modellari (LLM)', 'ru': 'Большие языковые модели (LLM)'},
        {'uz': 'Prompt muhandisligi asoslari', 'ru': 'Основы промпт-инжиниринга'},
        {'uz': 'AI axloqi va xavflar', 'ru': 'Этика и риски ИИ'},
        {'uz': 'Kundalik hayotda AI vositalari', 'ru': 'ИИ-инструменты в повседневной жизни'},
        {'uz': 'Mini loyiha: AI yordamchisi rejasi', 'ru': 'Мини-проект: план ИИ-ассистента'},
      ],
    ),
    CourseDef(
      key: 'cyber_diplomacy',
      icon: Icons.public_rounded,
      color: AppColors.warning,
      lessons: [
        {'uz': 'Kiberdiplomatiya nima?', 'ru': 'Что такое кибердипломатия?'},
        {'uz': 'Raqamli davlat siyosati', 'ru': 'Цифровая государственная политика'},
        {'uz': 'Xalqaro kiberbitimlar', 'ru': 'Международные киберсоглашения'},
        {'uz': 'Kiberjinoyat va huquq', 'ru': 'Киберпреступность и право'},
        {'uz': 'Raqamli suverenitet', 'ru': 'Цифровой суверенитет'},
        {'uz': 'Kibermustahkamlik siyosati', 'ru': 'Политика киберустойчивости'},
        {'uz': 'Xalqaro tashkilotlar roli', 'ru': 'Роль международных организаций'},
        {'uz': 'Mini loyiha: kibersiyosat taqdimoti', 'ru': 'Мини-проект: презентация киберполитики'},
      ],
    ),
  ];

  static CourseDef byKey(String key) =>
      courses.firstWhere((c) => c.key == key, orElse: () => courses.first);

  static int get totalLessons => courses.fold(0, (n, c) => n + c.lessons.length);
}
