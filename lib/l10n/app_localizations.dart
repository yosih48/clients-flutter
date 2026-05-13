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
  /// **'Add client'**
  String get addUser;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @clientInfo.
  ///
  /// In en, this message translates to:
  /// **'Client info'**
  String get clientInfo;

  /// No description provided for @openTicket.
  ///
  /// In en, this message translates to:
  /// **'Open ticket'**
  String get openTicket;

  /// No description provided for @editClient.
  ///
  /// In en, this message translates to:
  /// **'Edit client'**
  String get editClient;

  /// No description provided for @callType.
  ///
  /// In en, this message translates to:
  /// **'Call type'**
  String get callType;

  /// No description provided for @callTime.
  ///
  /// In en, this message translates to:
  /// **'Call time'**
  String get callTime;

  /// No description provided for @clientHistory.
  ///
  /// In en, this message translates to:
  /// **'Call history'**
  String get clientHistory;

  /// No description provided for @filterPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get filterPaid;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Enter client name'**
  String get clientName;

  /// No description provided for @clientEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter client email'**
  String get clientEmail;

  /// No description provided for @clientAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter client address'**
  String get clientAddress;

  /// No description provided for @clientPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter client phone'**
  String get clientPhone;

  /// No description provided for @callsHistory.
  ///
  /// In en, this message translates to:
  /// **'Calls history'**
  String get callsHistory;

  /// No description provided for @addParts.
  ///
  /// In en, this message translates to:
  /// **'Add parts'**
  String get addParts;

  /// No description provided for @calldescription.
  ///
  /// In en, this message translates to:
  /// **'Call description'**
  String get calldescription;

  /// No description provided for @filtering.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filtering;

  /// No description provided for @ramainingBalance.
  ///
  /// In en, this message translates to:
  /// **'Outstanding balance'**
  String get ramainingBalance;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment amount'**
  String get paymentAmount;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Call description'**
  String get description;

  /// No description provided for @typeofService.
  ///
  /// In en, this message translates to:
  /// **'Type of service'**
  String get typeofService;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get paymentStatus;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost price'**
  String get costPrice;

  /// No description provided for @finalPrice.
  ///
  /// In en, this message translates to:
  /// **'Customer price'**
  String get finalPrice;

  /// No description provided for @callDetails.
  ///
  /// In en, this message translates to:
  /// **'Call details'**
  String get callDetails;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @signout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose time'**
  String get chooseTime;

  /// No description provided for @missingDetails.
  ///
  /// In en, this message translates to:
  /// **'Missing details'**
  String get missingDetails;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @savedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccess;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @openCall.
  ///
  /// In en, this message translates to:
  /// **'Open call'**
  String get openCall;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @todo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get todo;

  /// No description provided for @noTodoCalls.
  ///
  /// In en, this message translates to:
  /// **'No open calls'**
  String get noTodoCalls;

  /// No description provided for @extraPayment.
  ///
  /// In en, this message translates to:
  /// **'Extra payment'**
  String get extraPayment;

  /// No description provided for @sumHours.
  ///
  /// In en, this message translates to:
  /// **'Total hours'**
  String get sumHours;

  /// No description provided for @totalCosts.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get totalCosts;

  /// No description provided for @searchcustomer.
  ///
  /// In en, this message translates to:
  /// **'Search client'**
  String get searchcustomer;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @officeVersion.
  ///
  /// In en, this message translates to:
  /// **'Office version'**
  String get officeVersion;

  /// No description provided for @windowsLicense.
  ///
  /// In en, this message translates to:
  /// **'Windows license'**
  String get windowsLicense;

  /// No description provided for @officeLicense.
  ///
  /// In en, this message translates to:
  /// **'Office license'**
  String get officeLicense;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select product'**
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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'App Making'**
  String get appName;

  /// No description provided for @incomeTable.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeTable;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportComplete.
  ///
  /// In en, this message translates to:
  /// **'Export complete'**
  String get exportComplete;

  /// No description provided for @exportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Data has been exported.'**
  String get exportSuccessMessage;

  /// No description provided for @noClientsYet.
  ///
  /// In en, this message translates to:
  /// **'No clients yet'**
  String get noClientsYet;

  /// No description provided for @noClientsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first client'**
  String get noClientsHint;

  /// No description provided for @noMatchingClients.
  ///
  /// In en, this message translates to:
  /// **'No matching clients'**
  String get noMatchingClients;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @noCallsYet.
  ///
  /// In en, this message translates to:
  /// **'No calls yet'**
  String get noCallsYet;

  /// No description provided for @noCallsHint.
  ///
  /// In en, this message translates to:
  /// **'New service tickets will appear here'**
  String get noCallsHint;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'(no description)'**
  String get noDescription;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldestFirst;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get allCaughtUp;

  /// No description provided for @noCallsInProgress.
  ///
  /// In en, this message translates to:
  /// **'No calls in progress'**
  String get noCallsInProgress;

  /// No description provided for @noCallsInProgressHint.
  ///
  /// In en, this message translates to:
  /// **'Start working on a ticket to see it here'**
  String get noCallsInProgressHint;

  /// No description provided for @noPendingTickets.
  ///
  /// In en, this message translates to:
  /// **'No pending tickets right now'**
  String get noPendingTickets;

  /// No description provided for @todoTab.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get todoTab;

  /// No description provided for @inProgressTab.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgressTab;

  /// No description provided for @callAction.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callAction;

  /// No description provided for @emailAction.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailAction;

  /// No description provided for @directionsAction.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directionsAction;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @sectionWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get sectionWork;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get sectionSecurity;

  /// No description provided for @sectionMisc.
  ///
  /// In en, this message translates to:
  /// **'Misc'**
  String get sectionMisc;

  /// No description provided for @hourlyRate.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate'**
  String get hourlyRate;

  /// No description provided for @hourlyRateNative.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate'**
  String get hourlyRateNative;

  /// No description provided for @lockInBackground.
  ///
  /// In en, this message translates to:
  /// **'Lock app in background'**
  String get lockInBackground;

  /// No description provided for @useFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint'**
  String get useFingerprint;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source & licenses'**
  String get openSourceLicenses;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @newTicket.
  ///
  /// In en, this message translates to:
  /// **'New ticket'**
  String get newTicket;

  /// No description provided for @editTicket.
  ///
  /// In en, this message translates to:
  /// **'Edit ticket'**
  String get editTicket;

  /// No description provided for @serviceType.
  ///
  /// In en, this message translates to:
  /// **'Service type'**
  String get serviceType;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What did you do for this client?'**
  String get descriptionHint;

  /// No description provided for @hardwareAndLicenses.
  ///
  /// In en, this message translates to:
  /// **'Hardware & licenses'**
  String get hardwareAndLicenses;

  /// No description provided for @optionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Optional details'**
  String get optionalDetails;

  /// No description provided for @summaryHardware.
  ///
  /// In en, this message translates to:
  /// **'Hardware'**
  String get summaryHardware;

  /// No description provided for @summaryOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get summaryOffice;

  /// No description provided for @summaryWinLicense.
  ///
  /// In en, this message translates to:
  /// **'Win license'**
  String get summaryWinLicense;

  /// No description provided for @summaryOfficeLicense.
  ///
  /// In en, this message translates to:
  /// **'Office license'**
  String get summaryOfficeLicense;

  /// No description provided for @totalPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Total · paid'**
  String get totalPaidLabel;

  /// No description provided for @totalToCharge.
  ///
  /// In en, this message translates to:
  /// **'Total to charge'**
  String get totalToCharge;

  /// No description provided for @noPartsAdded.
  ///
  /// In en, this message translates to:
  /// **'No parts added'**
  String get noPartsAdded;

  /// No description provided for @partsPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Parts paid'**
  String get partsPaidLabel;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @sectionPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get sectionPayment;

  /// No description provided for @sectionAdditional.
  ///
  /// In en, this message translates to:
  /// **'Additional'**
  String get sectionAdditional;

  /// No description provided for @areYouSureDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get areYouSureDelete;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your clients and calls'**
  String get signInSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @cantLogIn.
  ///
  /// In en, this message translates to:
  /// **'Can\'t log in?'**
  String get cantLogIn;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountYet;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get started in a few seconds'**
  String get signUpSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification code to your phone'**
  String get resetPasswordSubtitle;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @rememberIt.
  ///
  /// In en, this message translates to:
  /// **'Remember it?'**
  String get rememberIt;

  /// No description provided for @verifyNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get verifyNumber;

  /// No description provided for @enterCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phone}'**
  String enterCodeSentTo(Object phone);

  /// No description provided for @pleaseEnterAllDigits.
  ///
  /// In en, this message translates to:
  /// **'Please enter all digits'**
  String get pleaseEnterAllDigits;

  /// No description provided for @fillCellsProperly.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all the cells properly'**
  String get fillCellsProperly;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Code resent'**
  String get otpResend;

  /// No description provided for @otpVerified.
  ///
  /// In en, this message translates to:
  /// **'Code verified'**
  String get otpVerified;

  /// No description provided for @wantTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Want to try again?'**
  String get wantTryAgain;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get sendVerificationCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @phoneLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone number'**
  String get phoneLoginSubtitle;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @signUpError.
  ///
  /// In en, this message translates to:
  /// **'Sign-up error'**
  String get signUpError;

  /// No description provided for @signedUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed up successfully'**
  String get signedUpSuccess;

  /// No description provided for @updatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updatedSuccess;

  /// No description provided for @phoneVerifyFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify phone number. Please try again.'**
  String get phoneVerifyFail;

  /// No description provided for @phoneVerifiedAuto.
  ///
  /// In en, this message translates to:
  /// **'Phone number automatically verified.'**
  String get phoneVerifiedAuto;

  /// No description provided for @phoneVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Phone number verified successfully.'**
  String get phoneVerifiedSuccess;

  /// No description provided for @signInFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in. Please try again.'**
  String get signInFail;

  /// No description provided for @couldNotLoadCalls.
  ///
  /// In en, this message translates to:
  /// **'Could not load calls'**
  String get couldNotLoadCalls;

  /// No description provided for @couldNotLoadData.
  ///
  /// In en, this message translates to:
  /// **'Could not load data'**
  String get couldNotLoadData;

  /// No description provided for @firestoreIndexError.
  ///
  /// In en, this message translates to:
  /// **'Firestore returned an error — most often a missing composite index. Open the link printed in the debug console to create it.'**
  String get firestoreIndexError;

  /// No description provided for @noDataAllTime.
  ///
  /// In en, this message translates to:
  /// **'No data at all'**
  String get noDataAllTime;

  /// No description provided for @noDataForMonth.
  ///
  /// In en, this message translates to:
  /// **'No data for {month}'**
  String noDataForMonth(Object month);

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @showMonthlySummary.
  ///
  /// In en, this message translates to:
  /// **'Show monthly summary'**
  String get showMonthlySummary;

  /// No description provided for @showAllTimeSummary.
  ///
  /// In en, this message translates to:
  /// **'Show all-time summary'**
  String get showAllTimeSummary;

  /// No description provided for @allTimeSummary.
  ///
  /// In en, this message translates to:
  /// **'All-time summary'**
  String get allTimeSummary;

  /// No description provided for @totalRow.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalRow;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @openCalls.
  ///
  /// In en, this message translates to:
  /// **'Open calls'**
  String get openCalls;

  /// No description provided for @inProgressCalls.
  ///
  /// In en, this message translates to:
  /// **'In progress calls'**
  String get inProgressCalls;
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
