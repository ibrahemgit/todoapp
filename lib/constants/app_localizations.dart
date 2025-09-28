import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ar', ''),
  ];

  // Common
  String get appName => _getText('appName');
  String get save => _getText('save');
  String get cancel => _getText('cancel');
  String get delete => _getText('delete');
  String get edit => _getText('edit');
  String get add => _getText('add');
  String get update => _getText('update');
  String get search => _getText('search');
  String get settings => _getText('settings');
  String get home => _getText('home');
  String get todos => _getText('todos');
  String get notifications => _getText('notifications');
  String get notificationSettings => _getText('notificationSettings');
  String get testNotification => _getText('testNotification');
  String get testNotificationSent => _getText('testNotificationSent');
  String get noNotificationsYet => _getText('noNotificationsYet');
  String get notificationsDescription => _getText('notificationsDescription');
  String get permissionGranted => _getText('permissionGranted');
  String get permissionDenied => _getText('permissionDenied');
  String get about => _getText('about');

  // Todo related
  String get addTodo => _getText('addTodo');
  String get editTodo => _getText('editTodo');
  String get todoTitle => _getText('todoTitle');
  String get todoDescription => _getText('todoDescription');
  String get dueDate => _getText('dueDate');
  String get reminderTime => _getText('reminderTime');
  String get priority => _getText('priority');
  String get status => _getText('status');
  String get low => _getText('low');
  String get medium => _getText('medium');
  String get high => _getText('high');
  String get urgent => _getText('urgent');
  String get pending => _getText('pending');
  String get inProgress => _getText('inProgress');
  String get completed => _getText('completed');
  String get cancelled => _getText('cancelled');

  // Time related
  String get today => _getText('today');
  String get tomorrow => _getText('tomorrow');
  String get yesterday => _getText('yesterday');
  String get inDays => _getText('inDays');
  String get daysAgo => _getText('daysAgo');
  String get overdue => _getText('overdue');
  String get dueNow => _getText('dueNow');
  String get dueToday => _getText('dueToday');
  String get dueSoon => _getText('dueSoon');
  String get upcoming => _getText('upcoming');

  // Statistics
  String get totalTodos => _getText('totalTodos');
  String get completedTodos => _getText('completedTodos');
  String get pendingTodos => _getText('pendingTodos');
  String get overdueTodos => _getText('overdueTodos');

  // Settings
  String get themeSettings => _getText('themeSettings');
  String get languageSettings => _getText('languageSettings');
  String get lightMode => _getText('lightMode');
  String get darkMode => _getText('darkMode');
  String get systemMode => _getText('systemMode');
  String get english => _getText('english');
  String get arabic => _getText('arabic');

  // Messages
  String get todoAddedSuccessfully => _getText('todoAddedSuccessfully');
  String get todoUpdatedSuccessfully => _getText('todoUpdatedSuccessfully');
  String get todoDeletedSuccessfully => _getText('todoDeletedSuccessfully');
  String get areYouSureDelete => _getText('areYouSureDelete');
  String get noTodosFound => _getText('noTodosFound');
  String get welcomeMessage => _getText('welcomeMessage');

  // Additional UI Text
  String get selectDate => _getText('selectDate');
  String get selectTime => _getText('selectTime');
  String get selectPriority => _getText('selectPriority');
  String get selectStatus => _getText('selectStatus');
  String get repeating => _getText('repeating');
  String get daily => _getText('daily');
  String get weekly => _getText('weekly');
  String get monthly => _getText('monthly');
  String get yearly => _getText('yearly');
  String get quickActions => _getText('quickActions');
  String get recentTodos => _getText('recentTodos');
  String get allTodos => _getText('allTodos');
  String get filter => _getText('filter');
  String get sort => _getText('sort');
  String get clear => _getText('clear');
  String get back => _getText('back');
  String get next => _getText('next');
  String get previous => _getText('previous');
  String get done => _getText('done');
  String get ok => _getText('ok');
  String get yes => _getText('yes');
  String get no => _getText('no');
  String get close => _getText('close');
  String get open => _getText('open');
  String get loading => _getText('loading');
  String get error => _getText('error');
  String get success => _getText('success');
  String get warning => _getText('warning');
  String get info => _getText('info');
  String get required => _getText('required');
  String get optional => _getText('optional');
  String get description => _getText('description');
  String get title => _getText('title');
  String get name => _getText('name');
  String get date => _getText('date');
  String get time => _getText('time');
  String get created => _getText('created');
  String get updated => _getText('updated');
  String get deleted => _getText('deleted');
  String get view => _getText('view');
  String get hide => _getText('hide');
  String get show => _getText('show');
  String get refresh => _getText('refresh');
  String get retry => _getText('retry');
  String get confirm => _getText('confirm');
  String get saveChanges => _getText('saveChanges');
  String get discardChanges => _getText('discardChanges');
  String get reset => _getText('reset');
  String get apply => _getText('apply');
  String get submit => _getText('submit');
  String get continueText => _getText('continue');
  String get finish => _getText('finish');
  String get start => _getText('start');
  String get stop => _getText('stop');
  String get pause => _getText('pause');
  String get resume => _getText('resume');
  String get complete => _getText('complete');
  String get incomplete => _getText('incomplete');
  String get active => _getText('active');
  String get inactive => _getText('inactive');
  String get enabled => _getText('enabled');
  String get disabled => _getText('disabled');
  String get on => _getText('on');
  String get off => _getText('off');
  String get empty => _getText('empty');
  String get full => _getText('full');
  String get total => _getText('total');
  String get count => _getText('count');
  String get number => _getText('number');
  String get size => _getText('size');
  String get level => _getText('level');
  String get grade => _getText('grade');
  String get score => _getText('score');
  String get rating => _getText('rating');
  String get percentage => _getText('percentage');
  String get rate => _getText('rate');
  String get characters => _getText('characters');
  String get mustBeLessThan => _getText('mustBeLessThan');
  String get direction => _getText('direction');
  String get position => _getText('position');
  String get location => _getText('location');
  String get coordinates => _getText('coordinates');
  String get latitude => _getText('latitude');
  String get longitude => _getText('longitude');
  String get altitude => _getText('altitude');
  String get depth => _getText('depth');
  String get work => _getText('work');
  String get heat => _getText('heat');
  String get energy => _getText('energy');
  String get power => _getText('power');
  String get force => _getText('force');
  String get speed => _getText('speed');
  String get acceleration => _getText('acceleration');
  String get velocity => _getText('velocity');
  String get momentum => _getText('momentum');
  String get mass => _getText('mass');
  String get temperature => _getText('temperature');
  String get pressure => _getText('pressure');
  String get density => _getText('density');
  String get frequency => _getText('frequency');
  String get voltage => _getText('voltage');
  String get current => _getText('current');
  String get resistance => _getText('resistance');
  String get capacitance => _getText('capacitance');
  String get inductance => _getText('inductance');
  String get impedance => _getText('impedance');
  String get conductance => _getText('conductance');
  String get conductivity => _getText('conductivity');
  String get resistivity => _getText('resistivity');
  String get reactance => _getText('reactance');
  String get susceptance => _getText('susceptance');
  String get admittance => _getText('admittance');
  String get entropy => _getText('entropy');
  String get enthalpy => _getText('enthalpy');
  String get freeEnergy => _getText('freeEnergy');
  String get internalEnergy => _getText('internalEnergy');
  String get kineticEnergy => _getText('kineticEnergy');
  String get potentialEnergy => _getText('potentialEnergy');
  String get mechanicalEnergy => _getText('mechanicalEnergy');
  String get thermalEnergy => _getText('thermalEnergy');
  String get electricalEnergy => _getText('electricalEnergy');
  String get magneticEnergy => _getText('magneticEnergy');
  String get electromagneticEnergy => _getText('electromagneticEnergy');
  String get nuclearEnergy => _getText('nuclearEnergy');
  String get chemicalEnergy => _getText('chemicalEnergy');
  String get radiantEnergy => _getText('radiantEnergy');
  String get soundEnergy => _getText('soundEnergy');
  String get lightEnergy => _getText('lightEnergy');
  String get heatEnergy => _getText('heatEnergy');
  String get coldEnergy => _getText('coldEnergy');
  String get windEnergy => _getText('windEnergy');
  String get solarEnergy => _getText('solarEnergy');
  String get hydroEnergy => _getText('hydroEnergy');
  String get geothermalEnergy => _getText('geothermalEnergy');
  String get biomassEnergy => _getText('biomassEnergy');
  String get tidalEnergy => _getText('tidalEnergy');
  String get waveEnergy => _getText('waveEnergy');
  String get oceanEnergy => _getText('oceanEnergy');
  String get fusionEnergy => _getText('fusionEnergy');
  String get fissionEnergy => _getText('fissionEnergy');
  String get renewableEnergy => _getText('renewableEnergy');
  String get nonRenewableEnergy => _getText('nonRenewableEnergy');
  String get cleanEnergy => _getText('cleanEnergy');
  String get dirtyEnergy => _getText('dirtyEnergy');
  String get greenEnergy => _getText('greenEnergy');
  String get blueEnergy => _getText('blueEnergy');
  String get yellowEnergy => _getText('yellowEnergy');
  String get redEnergy => _getText('redEnergy');
  String get whiteEnergy => _getText('whiteEnergy');
  String get blackEnergy => _getText('blackEnergy');
  String get grayEnergy => _getText('grayEnergy');
  String get brownEnergy => _getText('brownEnergy');
  String get pinkEnergy => _getText('pinkEnergy');
  String get purpleEnergy => _getText('purpleEnergy');
  String get orangeEnergy => _getText('orangeEnergy');
  String get cyanEnergy => _getText('cyanEnergy');
  String get magentaEnergy => _getText('magentaEnergy');
  String get limeEnergy => _getText('limeEnergy');
  String get indigoEnergy => _getText('indigoEnergy');
  String get violetEnergy => _getText('violetEnergy');
  String get turquoiseEnergy => _getText('turquoiseEnergy');
  String get silverEnergy => _getText('silverEnergy');
  String get goldEnergy => _getText('goldEnergy');
  String get bronzeEnergy => _getText('bronzeEnergy');
  String get copperEnergy => _getText('copperEnergy');
  String get ironEnergy => _getText('ironEnergy');
  String get steelEnergy => _getText('steelEnergy');
  String get aluminumEnergy => _getText('aluminumEnergy');
  String get titaniumEnergy => _getText('titaniumEnergy');
  String get chromiumEnergy => _getText('chromiumEnergy');
  String get nickelEnergy => _getText('nickelEnergy');
  String get zincEnergy => _getText('zincEnergy');
  String get leadEnergy => _getText('leadEnergy');
  String get tinEnergy => _getText('tinEnergy');
  String get mercuryEnergy => _getText('mercuryEnergy');
  String get cadmiumEnergy => _getText('cadmiumEnergy');
  String get bismuthEnergy => _getText('bismuthEnergy');
  String get antimonyEnergy => _getText('antimonyEnergy');
  String get arsenicEnergy => _getText('arsenicEnergy');
  String get seleniumEnergy => _getText('seleniumEnergy');
  String get telluriumEnergy => _getText('telluriumEnergy');
  String get poloniumEnergy => _getText('poloniumEnergy');
  String get astatineEnergy => _getText('astatineEnergy');
  String get radonEnergy => _getText('radonEnergy');
  String get franciumEnergy => _getText('franciumEnergy');
  String get radiumEnergy => _getText('radiumEnergy');
  String get actiniumEnergy => _getText('actiniumEnergy');
  String get thoriumEnergy => _getText('thoriumEnergy');
  String get protactiniumEnergy => _getText('protactiniumEnergy');
  String get uraniumEnergy => _getText('uraniumEnergy');
  String get neptuniumEnergy => _getText('neptuniumEnergy');
  String get plutoniumEnergy => _getText('plutoniumEnergy');
  String get americiumEnergy => _getText('americiumEnergy');
  String get curiumEnergy => _getText('curiumEnergy');
  String get berkeliumEnergy => _getText('berkeliumEnergy');
  String get californiumEnergy => _getText('californiumEnergy');
  String get einsteiniumEnergy => _getText('einsteiniumEnergy');
  String get fermiumEnergy => _getText('fermiumEnergy');
  String get mendeleviumEnergy => _getText('mendeleviumEnergy');
  String get nobeliumEnergy => _getText('nobeliumEnergy');
  String get lawrenciumEnergy => _getText('lawrenciumEnergy');
  String get rutherfordiumEnergy => _getText('rutherfordiumEnergy');
  String get dubniumEnergy => _getText('dubniumEnergy');
  String get seaborgiumEnergy => _getText('seaborgiumEnergy');
  String get bohriumEnergy => _getText('bohriumEnergy');
  String get hassiumEnergy => _getText('hassiumEnergy');
  String get meitneriumEnergy => _getText('meitneriumEnergy');
  String get darmstadtiumEnergy => _getText('darmstadtiumEnergy');
  String get roentgeniumEnergy => _getText('roentgeniumEnergy');
  String get coperniciumEnergy => _getText('coperniciumEnergy');
  String get nihoniumEnergy => _getText('nihoniumEnergy');
  String get fleroviumEnergy => _getText('fleroviumEnergy');
  String get moscoviumEnergy => _getText('moscoviumEnergy');
  String get livermoriumEnergy => _getText('livermoriumEnergy');
  String get tennessineEnergy => _getText('tennessineEnergy');
  String get oganessonEnergy => _getText('oganessonEnergy');

  String _getText(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Smart Todo',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'update': 'Update',
      'search': 'Search',
      'settings': 'Settings',
      'home': 'Home',
      'todos': 'Todos',
      'notifications': 'Notifications',
      'notificationSettings': 'Notification Settings',
      'testNotification': 'Test Notification',
      'testNotificationSent': 'Test notification sent',
      'noNotificationsYet': 'No notifications yet',
      'notificationsDescription': 'You\'ll see your todo reminders here',
      'permissionGranted': 'Permission granted',
      'permissionDenied': 'Permission denied',
      'about': 'About',
      'addTodo': 'Add Todo',
      'editTodo': 'Edit Todo',
      'todoTitle': 'Todo Title',
      'todoDescription': 'Description',
      'dueDate': 'Due Date',
      'reminderTime': 'Reminder Time',
      'priority': 'Priority',
      'status': 'Status',
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'urgent': 'Urgent',
      'pending': 'Pending',
      'inProgress': 'In Progress',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'yesterday': 'Yesterday',
      'inDays': 'In {days} days',
      'daysAgo': '{days} days ago',
      'overdue': 'Overdue',
      'dueNow': 'Due Now',
      'dueToday': 'Due Today',
      'dueSoon': 'Due Soon',
      'upcoming': 'Upcoming',
      'totalTodos': 'Total Todos',
      'completedTodos': 'Completed',
      'pendingTodos': 'Pending',
      'overdueTodos': 'Overdue',
      'themeSettings': 'Theme Settings',
      'languageSettings': 'Language Settings',
      'lightMode': 'Light Mode',
      'darkMode': 'Dark Mode',
      'systemMode': 'System Mode',
      'english': 'English',
      'arabic': 'Arabic',
      'todoAddedSuccessfully': 'Todo added successfully',
      'todoUpdatedSuccessfully': 'Todo updated successfully',
      'todoDeletedSuccessfully': 'Todo deleted successfully',
      'areYouSureDelete': 'Are you sure you want to delete this todo?',
      'noTodosFound': 'No todos found',
      'welcomeMessage': 'Welcome to Smart Todo!',
      'selectDate': 'Select Date',
      'selectTime': 'Select Time',
      'selectPriority': 'Select Priority',
      'selectStatus': 'Select Status',
      'repeating': 'Repeating',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'quickActions': 'Quick Actions',
      'recentTodos': 'Recent Todos',
      'allTodos': 'All Todos',
      'filter': 'Filter',
      'sort': 'Sort',
      'clear': 'Clear',
      'back': 'Back',
      'next': 'Next',
      'previous': 'Previous',
      'done': 'Done',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'close': 'Close',
      'open': 'Open',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Info',
      'required': 'Required',
      'optional': 'Optional',
      'description': 'Description',
      'title': 'Title',
      'name': 'Name',
      'date': 'Date',
      'time': 'Time',
      'created': 'Created',
      'updated': 'Updated',
      'deleted': 'Deleted',
      'view': 'View',
      'hide': 'Hide',
      'show': 'Show',
      'refresh': 'Refresh',
      'retry': 'Retry',
      'confirm': 'Confirm',
      'saveChanges': 'Save Changes',
      'discardChanges': 'Discard Changes',
      'reset': 'Reset',
      'apply': 'Apply',
      'submit': 'Submit',
      'continue': 'Continue',
      'finish': 'Finish',
      'start': 'Start',
      'stop': 'Stop',
      'pause': 'Pause',
      'resume': 'Resume',
      'complete': 'Complete',
      'incomplete': 'Incomplete',
      'active': 'Active',
      'inactive': 'Inactive',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      'on': 'On',
      'off': 'Off',
      'empty': 'Empty',
      'full': 'Full',
      'total': 'Total',
      'count': 'Count',
      'number': 'Number',
      'size': 'Size',
      'level': 'Level',
      'grade': 'Grade',
      'score': 'Score',
      'rating': 'Rating',
      'percentage': 'Percentage',
      'rate': 'Rate',
      'characters': 'characters',
      'mustBeLessThan': 'must be less than',
      'direction': 'Direction',
      'position': 'Position',
      'location': 'Location',
      'coordinates': 'Coordinates',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
      'altitude': 'Altitude',
      'depth': 'Depth',
      'work': 'Work',
      'heat': 'Heat',
      'energy': 'Energy',
      'power': 'Power',
      'force': 'Force',
      'speed': 'Speed',
      'acceleration': 'Acceleration',
      'velocity': 'Velocity',
      'momentum': 'Momentum',
      'mass': 'Mass',
      'temperature': 'Temperature',
      'pressure': 'Pressure',
      'density': 'Density',
      'frequency': 'Frequency',
      'voltage': 'Voltage',
      'current': 'Current',
      'resistance': 'Resistance',
      'capacitance': 'Capacitance',
      'inductance': 'Inductance',
      'impedance': 'Impedance',
      'conductance': 'Conductance',
      'conductivity': 'Conductivity',
      'resistivity': 'Resistivity',
      'reactance': 'Reactance',
      'susceptance': 'Susceptance',
      'admittance': 'Admittance',
      'entropy': 'Entropy',
      'enthalpy': 'Enthalpy',
      'freeEnergy': 'Free Energy',
      'internalEnergy': 'Internal Energy',
      'kineticEnergy': 'Kinetic Energy',
      'potentialEnergy': 'Potential Energy',
      'mechanicalEnergy': 'Mechanical Energy',
      'thermalEnergy': 'Thermal Energy',
      'electricalEnergy': 'Electrical Energy',
      'magneticEnergy': 'Magnetic Energy',
      'electromagneticEnergy': 'Electromagnetic Energy',
      'nuclearEnergy': 'Nuclear Energy',
      'chemicalEnergy': 'Chemical Energy',
      'radiantEnergy': 'Radiant Energy',
      'soundEnergy': 'Sound Energy',
      'lightEnergy': 'Light Energy',
      'heatEnergy': 'Heat Energy',
      'coldEnergy': 'Cold Energy',
      'windEnergy': 'Wind Energy',
      'solarEnergy': 'Solar Energy',
      'hydroEnergy': 'Hydro Energy',
      'geothermalEnergy': 'Geothermal Energy',
      'biomassEnergy': 'Biomass Energy',
      'tidalEnergy': 'Tidal Energy',
      'waveEnergy': 'Wave Energy',
      'oceanEnergy': 'Ocean Energy',
      'fusionEnergy': 'Fusion Energy',
      'fissionEnergy': 'Fission Energy',
      'renewableEnergy': 'Renewable Energy',
      'nonRenewableEnergy': 'Non-Renewable Energy',
      'cleanEnergy': 'Clean Energy',
      'dirtyEnergy': 'Dirty Energy',
      'greenEnergy': 'Green Energy',
      'blueEnergy': 'Blue Energy',
      'yellowEnergy': 'Yellow Energy',
      'redEnergy': 'Red Energy',
      'whiteEnergy': 'White Energy',
      'blackEnergy': 'Black Energy',
      'grayEnergy': 'Gray Energy',
      'brownEnergy': 'Brown Energy',
      'pinkEnergy': 'Pink Energy',
      'purpleEnergy': 'Purple Energy',
      'orangeEnergy': 'Orange Energy',
      'cyanEnergy': 'Cyan Energy',
      'magentaEnergy': 'Magenta Energy',
      'limeEnergy': 'Lime Energy',
      'indigoEnergy': 'Indigo Energy',
      'violetEnergy': 'Violet Energy',
      'turquoiseEnergy': 'Turquoise Energy',
      'silverEnergy': 'Silver Energy',
      'goldEnergy': 'Gold Energy',
      'bronzeEnergy': 'Bronze Energy',
      'copperEnergy': 'Copper Energy',
      'ironEnergy': 'Iron Energy',
      'steelEnergy': 'Steel Energy',
      'aluminumEnergy': 'Aluminum Energy',
      'titaniumEnergy': 'Titanium Energy',
      'chromiumEnergy': 'Chromium Energy',
      'nickelEnergy': 'Nickel Energy',
      'zincEnergy': 'Zinc Energy',
      'leadEnergy': 'Lead Energy',
      'tinEnergy': 'Tin Energy',
      'mercuryEnergy': 'Mercury Energy',
      'cadmiumEnergy': 'Cadmium Energy',
      'bismuthEnergy': 'Bismuth Energy',
      'antimonyEnergy': 'Antimony Energy',
      'arsenicEnergy': 'Arsenic Energy',
      'seleniumEnergy': 'Selenium Energy',
      'telluriumEnergy': 'Tellurium Energy',
      'poloniumEnergy': 'Polonium Energy',
      'astatineEnergy': 'Astatine Energy',
      'radonEnergy': 'Radon Energy',
      'franciumEnergy': 'Francium Energy',
      'radiumEnergy': 'Radium Energy',
      'actiniumEnergy': 'Actinium Energy',
      'thoriumEnergy': 'Thorium Energy',
      'protactiniumEnergy': 'Protactinium Energy',
      'uraniumEnergy': 'Uranium Energy',
      'neptuniumEnergy': 'Neptunium Energy',
      'plutoniumEnergy': 'Plutonium Energy',
      'americiumEnergy': 'Americium Energy',
      'curiumEnergy': 'Curium Energy',
      'berkeliumEnergy': 'Berkelium Energy',
      'californiumEnergy': 'Californium Energy',
      'einsteiniumEnergy': 'Einsteinium Energy',
      'fermiumEnergy': 'Fermium Energy',
      'mendeleviumEnergy': 'Mendelevium Energy',
      'nobeliumEnergy': 'Nobelium Energy',
      'lawrenciumEnergy': 'Lawrencium Energy',
      'rutherfordiumEnergy': 'Rutherfordium Energy',
      'dubniumEnergy': 'Dubnium Energy',
      'seaborgiumEnergy': 'Seaborgium Energy',
      'bohriumEnergy': 'Bohrium Energy',
      'hassiumEnergy': 'Hassium Energy',
      'meitneriumEnergy': 'Meitnerium Energy',
      'darmstadtiumEnergy': 'Darmstadtium Energy',
      'roentgeniumEnergy': 'Roentgenium Energy',
      'coperniciumEnergy': 'Copernicium Energy',
      'nihoniumEnergy': 'Nihonium Energy',
      'fleroviumEnergy': 'Flerovium Energy',
      'moscoviumEnergy': 'Moscovium Energy',
      'livermoriumEnergy': 'Livermorium Energy',
      'tennessineEnergy': 'Tennessine Energy',
      'oganessonEnergy': 'Oganesson Energy',
    },
    'ar': {
      'appName': 'مهام ذكية',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'add': 'إضافة',
      'update': 'تحديث',
      'search': 'بحث',
      'settings': 'الإعدادات',
      'home': 'الرئيسية',
      'todos': 'المهام',
      'notifications': 'الإشعارات',
      'notificationSettings': 'إعدادات الإشعارات',
      'testNotification': 'اختبار الإشعار',
      'testNotificationSent': 'تم إرسال إشعار الاختبار',
      'noNotificationsYet': 'لا توجد إشعارات بعد',
      'notificationsDescription': 'ستظهر تذكيرات المهام هنا',
      'permissionGranted': 'تم منح الإذن',
      'permissionDenied': 'تم رفض الإذن',
      'about': 'حول',
      'addTodo': 'إضافة مهمة',
      'editTodo': 'تعديل المهمة',
      'todoTitle': 'عنوان المهمة',
      'todoDescription': 'الوصف',
      'dueDate': 'تاريخ الاستحقاق',
      'reminderTime': 'وقت التذكير',
      'priority': 'الأولوية',
      'status': 'الحالة',
      'low': 'منخفضة',
      'medium': 'متوسطة',
      'high': 'عالية',
      'urgent': 'عاجلة',
      'pending': 'معلقة',
      'inProgress': 'قيد التنفيذ',
      'completed': 'مكتملة',
      'cancelled': 'ملغية',
      'today': 'اليوم',
      'tomorrow': 'غداً',
      'yesterday': 'أمس',
      'inDays': 'خلال {days} أيام',
      'daysAgo': 'منذ {days} أيام',
      'overdue': 'متأخرة',
      'dueNow': 'مستحقة الآن',
      'dueToday': 'مستحقة اليوم',
      'dueSoon': 'مستحقة قريباً',
      'upcoming': 'قادمة',
      'totalTodos': 'إجمالي المهام',
      'completedTodos': 'مكتملة',
      'pendingTodos': 'معلقة',
      'overdueTodos': 'متأخرة',
      'themeSettings': 'إعدادات الثيم',
      'languageSettings': 'إعدادات اللغة',
      'lightMode': 'الوضع الفاتح',
      'darkMode': 'الوضع الداكن',
      'systemMode': 'وضع النظام',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'todoAddedSuccessfully': 'تم إضافة المهمة بنجاح',
      'todoUpdatedSuccessfully': 'تم تحديث المهمة بنجاح',
      'todoDeletedSuccessfully': 'تم حذف المهمة بنجاح',
      'areYouSureDelete': 'هل أنت متأكد من حذف هذه المهمة؟',
      'noTodosFound': 'لم يتم العثور على مهام',
      'welcomeMessage': 'مرحباً بك في مهام ذكية!',
      'selectDate': 'اختر التاريخ',
      'selectTime': 'اختر الوقت',
      'selectPriority': 'اختر الأولوية',
      'selectStatus': 'اختر الحالة',
      'repeating': 'التكرار',
      'daily': 'يومي',
      'weekly': 'أسبوعي',
      'monthly': 'شهري',
      'yearly': 'سنوي',
      'quickActions': 'الإجراءات السريعة',
      'recentTodos': 'المهام الأخيرة',
      'allTodos': 'جميع المهام',
      'filter': 'تصفية',
      'sort': 'ترتيب',
      'clear': 'مسح',
      'back': 'رجوع',
      'next': 'التالي',
      'previous': 'السابق',
      'done': 'تم',
      'ok': 'موافق',
      'yes': 'نعم',
      'no': 'لا',
      'close': 'إغلاق',
      'open': 'فتح',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'warning': 'تحذير',
      'info': 'معلومات',
      'required': 'مطلوب',
      'optional': 'اختياري',
      'description': 'الوصف',
      'title': 'العنوان',
      'name': 'الاسم',
      'date': 'التاريخ',
      'time': 'الوقت',
      'created': 'تم الإنشاء',
      'updated': 'تم التحديث',
      'deleted': 'تم الحذف',
      'view': 'عرض',
      'hide': 'إخفاء',
      'show': 'إظهار',
      'refresh': 'تحديث',
      'retry': 'إعادة المحاولة',
      'confirm': 'تأكيد',
      'saveChanges': 'حفظ التغييرات',
      'discardChanges': 'تجاهل التغييرات',
      'reset': 'إعادة تعيين',
      'apply': 'تطبيق',
      'submit': 'إرسال',
      'continue': 'متابعة',
      'finish': 'إنهاء',
      'start': 'بدء',
      'stop': 'توقف',
      'pause': 'إيقاف مؤقت',
      'resume': 'استئناف',
      'complete': 'مكتمل',
      'incomplete': 'غير مكتمل',
      'active': 'نشط',
      'inactive': 'غير نشط',
      'enabled': 'مفعل',
      'disabled': 'معطل',
      'on': 'تشغيل',
      'off': 'إيقاف',
      'empty': 'فارغ',
      'full': 'ممتلئ',
      'total': 'المجموع',
      'count': 'العدد',
      'number': 'الرقم',
      'size': 'الحجم',
      'level': 'المستوى',
      'grade': 'الدرجة',
      'score': 'النقاط',
      'rating': 'التقييم',
      'percentage': 'النسبة المئوية',
      'rate': 'المعدل',
      'characters': 'حرف',
      'mustBeLessThan': 'يجب أن يكون أقل من',
      'direction': 'الاتجاه',
      'position': 'الموضع',
      'location': 'الموقع',
      'coordinates': 'الإحداثيات',
      'latitude': 'خط العرض',
      'longitude': 'خط الطول',
      'altitude': 'الارتفاع',
      'depth': 'العمق',
      'work': 'العمل',
      'heat': 'الحرارة',
      'energy': 'الطاقة',
      'power': 'القوة',
      'force': 'القوة',
      'speed': 'السرعة',
      'acceleration': 'التسارع',
      'velocity': 'السرعة',
      'momentum': 'الزخم',
      'mass': 'الكتلة',
      'temperature': 'درجة الحرارة',
      'pressure': 'الضغط',
      'density': 'الكثافة',
      'frequency': 'التردد',
      'voltage': 'الجهد',
      'current': 'التيار',
      'resistance': 'المقاومة',
      'capacitance': 'السعة',
      'inductance': 'التحريض',
      'impedance': 'المعاوقة',
      'conductance': 'الموصلية',
      'conductivity': 'الموصلية',
      'resistivity': 'المقاومة النوعية',
      'reactance': 'المعاوقة',
      'susceptance': 'القابلية',
      'admittance': 'القبول',
      'entropy': 'الإنتروبيا',
      'enthalpy': 'الإنثالبي',
      'freeEnergy': 'الطاقة الحرة',
      'internalEnergy': 'الطاقة الداخلية',
      'kineticEnergy': 'الطاقة الحركية',
      'potentialEnergy': 'الطاقة الكامنة',
      'mechanicalEnergy': 'الطاقة الميكانيكية',
      'thermalEnergy': 'الطاقة الحرارية',
      'electricalEnergy': 'الطاقة الكهربائية',
      'magneticEnergy': 'الطاقة المغناطيسية',
      'electromagneticEnergy': 'الطاقة الكهرومغناطيسية',
      'nuclearEnergy': 'الطاقة النووية',
      'chemicalEnergy': 'الطاقة الكيميائية',
      'radiantEnergy': 'الطاقة المشعة',
      'soundEnergy': 'الطاقة الصوتية',
      'lightEnergy': 'الطاقة الضوئية',
      'heatEnergy': 'الطاقة الحرارية',
      'coldEnergy': 'الطاقة الباردة',
      'windEnergy': 'طاقة الرياح',
      'solarEnergy': 'الطاقة الشمسية',
      'hydroEnergy': 'الطاقة المائية',
      'geothermalEnergy': 'الطاقة الحرارية الأرضية',
      'biomassEnergy': 'طاقة الكتلة الحيوية',
      'tidalEnergy': 'طاقة المد والجزر',
      'waveEnergy': 'طاقة الأمواج',
      'oceanEnergy': 'طاقة المحيط',
      'fusionEnergy': 'طاقة الاندماج',
      'fissionEnergy': 'طاقة الانشطار',
      'renewableEnergy': 'الطاقة المتجددة',
      'nonRenewableEnergy': 'الطاقة غير المتجددة',
      'cleanEnergy': 'الطاقة النظيفة',
      'dirtyEnergy': 'الطاقة الملوثة',
      'greenEnergy': 'الطاقة الخضراء',
      'blueEnergy': 'الطاقة الزرقاء',
      'yellowEnergy': 'الطاقة الصفراء',
      'redEnergy': 'الطاقة الحمراء',
      'whiteEnergy': 'الطاقة البيضاء',
      'blackEnergy': 'الطاقة السوداء',
      'grayEnergy': 'الطاقة الرمادية',
      'brownEnergy': 'الطاقة البنية',
      'pinkEnergy': 'الطاقة الوردية',
      'purpleEnergy': 'الطاقة البنفسجية',
      'orangeEnergy': 'الطاقة البرتقالية',
      'cyanEnergy': 'الطاقة السماوية',
      'magentaEnergy': 'الطاقة الأرجوانية',
      'limeEnergy': 'طاقة الليمون',
      'indigoEnergy': 'طاقة النيلي',
      'violetEnergy': 'طاقة البنفسج',
      'turquoiseEnergy': 'طاقة التركواز',
      'silverEnergy': 'طاقة الفضة',
      'goldEnergy': 'طاقة الذهب',
      'bronzeEnergy': 'طاقة البرونز',
      'copperEnergy': 'طاقة النحاس',
      'ironEnergy': 'طاقة الحديد',
      'steelEnergy': 'طاقة الفولاذ',
      'aluminumEnergy': 'طاقة الألومنيوم',
      'titaniumEnergy': 'طاقة التيتانيوم',
      'chromiumEnergy': 'طاقة الكروم',
      'nickelEnergy': 'طاقة النيكل',
      'zincEnergy': 'طاقة الزنك',
      'leadEnergy': 'طاقة الرصاص',
      'tinEnergy': 'طاقة القصدير',
      'mercuryEnergy': 'طاقة الزئبق',
      'cadmiumEnergy': 'طاقة الكادميوم',
      'bismuthEnergy': 'طاقة البزموت',
      'antimonyEnergy': 'طاقة الأنتيمون',
      'arsenicEnergy': 'طاقة الزرنيخ',
      'seleniumEnergy': 'طاقة السيلينيوم',
      'telluriumEnergy': 'طاقة التيلوريوم',
      'poloniumEnergy': 'طاقة البولونيوم',
      'astatineEnergy': 'طاقة الأستاتين',
      'radonEnergy': 'طاقة الرادون',
      'franciumEnergy': 'طاقة الفرانسيوم',
      'radiumEnergy': 'طاقة الراديوم',
      'actiniumEnergy': 'طاقة الأكتينيوم',
      'thoriumEnergy': 'طاقة الثوريوم',
      'protactiniumEnergy': 'طاقة البروتاكتينيوم',
      'uraniumEnergy': 'طاقة اليورانيوم',
      'neptuniumEnergy': 'طاقة النبتونيوم',
      'plutoniumEnergy': 'طاقة البلوتونيوم',
      'americiumEnergy': 'طاقة الأمريسيوم',
      'curiumEnergy': 'طاقة الكوريوم',
      'berkeliumEnergy': 'طاقة البركيليوم',
      'californiumEnergy': 'طاقة الكاليفورنيوم',
      'einsteiniumEnergy': 'طاقة الأينشتاينيوم',
      'fermiumEnergy': 'طاقة الفيرميوم',
      'mendeleviumEnergy': 'طاقة المندليفيوم',
      'nobeliumEnergy': 'طاقة النوبليوم',
      'lawrenciumEnergy': 'طاقة اللورنسيوم',
      'rutherfordiumEnergy': 'طاقة الروذرفورديوم',
      'dubniumEnergy': 'طاقة الدوبنيوم',
      'seaborgiumEnergy': 'طاقة السيبورغيوم',
      'bohriumEnergy': 'طاقة البوريوم',
      'hassiumEnergy': 'طاقة الهاسيوم',
      'meitneriumEnergy': 'طاقة المايتنريوم',
      'darmstadtiumEnergy': 'طاقة الدارمشتاديوم',
      'roentgeniumEnergy': 'طاقة الرونتجينيوم',
      'coperniciumEnergy': 'طاقة الكوبرنيسيوم',
      'nihoniumEnergy': 'طاقة النيهونيوم',
      'fleroviumEnergy': 'طاقة الفليروفيوم',
      'moscoviumEnergy': 'طاقة الموسكوفيوم',
      'livermoriumEnergy': 'طاقة الليفرموريوم',
      'tennessineEnergy': 'طاقة التينيسين',
      'oganessonEnergy': 'طاقة الأوجانيسون',
    },
  };
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}