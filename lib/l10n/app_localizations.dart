import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he')
  ];

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'add user'**
  String get addUser;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'clients'**
  String get clients;

  /// No description provided for @clientInfo.
  ///
  /// In en, this message translates to:
  /// **'client info'**
  String get clientInfo;

  /// No description provided for @openTicket.
  ///
  /// In en, this message translates to:
  /// **'openTicket'**
  String get openTicket;

  /// No description provided for @editClient.
  ///
  /// In en, this message translates to:
  /// **'edit Client info'**
  String get editClient;

  /// No description provided for @callType.
  ///
  /// In en, this message translates to:
  /// **'call type'**
  String get callType;

  /// No description provided for @callTime.
  ///
  /// In en, this message translates to:
  /// **'call time'**
  String get callTime;

  /// No description provided for @clientHistory.
  ///
  /// In en, this message translates to:
  /// **'call history'**
  String get clientHistory;

  /// No description provided for @filterPaid.
  ///
  /// In en, this message translates to:
  /// **'paid'**
  String get filterPaid;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'options'**
  String get options;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Enter Client name'**
  String get clientName;

  /// No description provided for @clientEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Client email '**
  String get clientEmail;

  /// No description provided for @clientAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter Client address'**
  String get clientAddress;

  /// No description provided for @clientPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter Client phone'**
  String get clientPhone;

  /// No description provided for @callsHistory.
  ///
  /// In en, this message translates to:
  /// **'calls history'**
  String get callsHistory;

  /// No description provided for @addParts.
  ///
  /// In en, this message translates to:
  /// **'add parts'**
  String get addParts;

  /// No description provided for @calldescription.
  ///
  /// In en, this message translates to:
  /// **'call description'**
  String get calldescription;

  /// No description provided for @filtering.
  ///
  /// In en, this message translates to:
  /// **'filter'**
  String get filtering;

  /// No description provided for @ramainingBalance.
  ///
  /// In en, this message translates to:
  /// **'ramaining balance'**
  String get ramainingBalance;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment Amount'**
  String get paymentAmount;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'call Description'**
  String get description;

  /// No description provided for @typeofService.
  ///
  /// In en, this message translates to:
  /// **'Type of Service'**
  String get typeofService;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'product name'**
  String get product;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'cost price'**
  String get costPrice;

  /// No description provided for @finalPrice.
  ///
  /// In en, this message translates to:
  /// **'customer price'**
  String get finalPrice;

  /// No description provided for @callDetails.
  ///
  /// In en, this message translates to:
  /// **'call details'**
  String get callDetails;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'date'**
  String get date;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'paid'**
  String get paid;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'add'**
  String get add;

  /// No description provided for @signout.
  ///
  /// In en, this message translates to:
  /// **'sign out'**
  String get signout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'settings'**
  String get settings;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'loading'**
  String get loading;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'choose Time'**
  String get chooseTime;

  /// No description provided for @missingDetails.
  ///
  /// In en, this message translates to:
  /// **'missing Details'**
  String get missingDetails;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get save;

  /// No description provided for @savedSuccess.
  ///
  /// In en, this message translates to:
  /// **'saved Successfully'**
  String get savedSuccess;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'filter'**
  String get filter;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'amount'**
  String get amount;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'edit'**
  String get edit;

  /// No description provided for @openCall.
  ///
  /// In en, this message translates to:
  /// **'open call'**
  String get openCall;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'delete'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get done;

  /// No description provided for @todo.
  ///
  /// In en, this message translates to:
  /// **'todo'**
  String get todo;

  /// No description provided for @noTodoCalls.
  ///
  /// In en, this message translates to:
  /// **'no open calls'**
  String get noTodoCalls;

  /// No description provided for @extraPayment.
  ///
  /// In en, this message translates to:
  /// **'extraPayment'**
  String get extraPayment;

  /// No description provided for @sumHours.
  ///
  /// In en, this message translates to:
  /// **'total hours'**
  String get sumHours;

  /// No description provided for @totalCosts.
  ///
  /// In en, this message translates to:
  /// **'total costs'**
  String get totalCosts;

  /// No description provided for @searchcustomer.
  ///
  /// In en, this message translates to:
  /// **'search customer'**
  String get searchcustomer;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'quantity'**
  String get quantity;

  /// No description provided for @officeVersion.
  ///
  /// In en, this message translates to:
  /// **'office Version'**
  String get officeVersion;

  /// No description provided for @windowsLicense.
  ///
  /// In en, this message translates to:
  /// **'רשיון WINDOWS'**
  String get windowsLicense;

  /// No description provided for @officeLicense.
  ///
  /// In en, this message translates to:
  /// **'רשיון OFFICE'**
  String get officeLicense;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'בחר מוצר'**
  String get selectProduct;

  /// No description provided for @miniDell.
  ///
  /// In en, this message translates to:
  /// **'Mini Dell'**
  String get miniDell;

  /// No description provided for @hpI5.
  ///
  /// In en, this message translates to:
  /// **'HP i5'**
  String get hpI5;

  /// No description provided for @lenovoI7.
  ///
  /// In en, this message translates to:
  /// **'Lenovo i7'**
  String get lenovoI7;

  /// No description provided for @macMini.
  ///
  /// In en, this message translates to:
  /// **'Mac Mini'**
  String get macMini;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
