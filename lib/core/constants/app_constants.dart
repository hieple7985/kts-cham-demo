class AppConstants {
  // App Info
  static const String appName = 'Customer Care App';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Cache Duration
  static const Duration cacheDuration = Duration(days: 7);
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  
  // Customer Types
  static const String customerTypeVIP = 'vip';
  static const String customerTypeRegular = 'regular';
  static const String customerTypePotential = 'potential';
  
  // Customer Stages
  static const String stageReceiveInfo = 'receive_info';
  static const String stageHaveNeeds = 'have_needs';
  static const String stageResearch = 'research';
  static const String stageExplosionPoint = 'explosion_point';
  static const String stageSales = 'sales';
  static const String stageAfterSales = 'after_sales';
  static const String stageRepeat = 'repeat';
  
  // Priority Levels
  static const String priorityHigh = 'high';
  static const String priorityMedium = 'medium';
  static const String priorityLow = 'low';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  
  // Validation
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int phoneLength = 10;
  static const int maxNotesLength = 5000;
}
