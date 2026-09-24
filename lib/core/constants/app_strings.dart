class AppStrings {
  AppStrings._();

  static const String appName = 'Bizz Cab';
  static const String splashTagline = 'RIDE YOUR WAY';

  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String loginTitle = 'Login to your Account!';
  static const String loginSubtitle =
      'Enter your mobile number to get verified';
  static const String registerTitle = 'Get Yourself Register!';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String mobileNumber = 'Mobile Number';
  static const String enterMobileNumber = 'Enter mobile number';
  static const String countryCode = '+91';
  static const String getOtp = 'Get OTP';
  static const String dontHaveAccount = "Don't have an account?";
  static const String agreeToThe = 'I agree to the ';
  static const String termsOfService = 'Terms of Service';
  static const String andSeparator = ' and ';
  static const String acceptTerms = 'Please accept the Terms of Service';
  static const String otpSent = 'OTP sent successfully';
  static const String verificationTitle = 'Verification';
  static const String continueText = 'Continue';
  static const String resendOtp = 'Resend OTP';
  static const String otpHintDash = '-';
  static String otpDisplay(String otp) => 'OTP: $otp';
  static const String invalidOtp = 'Enter the 4-digit OTP';
  static const String otpVerified = 'Verified successfully';
  static const String loginSuccessful = 'Login successful';
  static const String signupTitle = 'Create Your Account!';
  static const String signupSubtitle =
      'Lets get started! Please fill your details.';
  static const String emailOptional = 'Email Address (Optional)';
  static const String referralCodeOptional = 'Referral Code (Optional)';
  static const String fieldPlaceholder = '--';
  static const String getStarted = 'Get Started';
  static const String accountCreated = 'Account created';
  static const String loggedOut = 'Logged out';
  static const String mobileVerified = 'Mobile number verified';
  static const String noAccountFound =
      'No account found for this number. Please sign up';
  static const String accountAlreadyExists =
      'Already have an account. Please login';
  static const String signupSessionExpired =
      'Signup session expired. Please verify your number again';
  static const String invalidReferralCode = 'Invalid referral code';
  static const String referAndEarn = 'Refer & Earn';
  static const String referAndEarnHint =
      'Invite friends and earn wallet rewards';
  static const String yourReferralCode = 'Your referral code';
  static const String copyCode = 'Copy Code';
  static const String shareInvite = 'Share Invite';
  static const String codeCopied = 'Referral code copied';
  static const String referralReward = 'Referral Reward';
  static const String referralRewardHint =
      'Credit after your friend’s first completed ride';
  static const String friendsInvited = 'Friends invited';
  static const String totalEarned = 'Total earned';
  static const String pendingRewards = 'Pending';
  static const String referralList = 'Referral list';
  static const String noPendingReferrals = 'No pending referrals';
  static const String noRewardedReferrals = 'No rewarded referrals yet';
  static const String statusRewarded = 'Rewarded';
  static const String statusPending = 'Pending';
  static const String howItWorks = 'How it works';
  static const String referStepOne = 'Share your referral code';
  static const String referStepTwo = 'Friend signs up with your code';
  static const String referStepThree =
      'You earn after their first completed ride';
  static String referEarnBody(String amount) =>
      'Invite a friend with your code. You get $amount after their first completed ride.';
  static String referEarnSplash(String amount) =>
      'Invite friends. Earn $amount after their first ride.';
  static String referShareMessage({
    required String code,
    required String amount,
    String url = '',
  }) {
    final link = url.trim().isEmpty ? '' : ' $url';
    return 'Use my Bizz Cab code $code to sign up. I earn $amount after your first completed ride.$link';
  }
  static const String updateProfile = 'Update Profile';
  static const String profileUpdated = 'Profile updated successfully';
  static const String profileFetched = 'Profile fetched';
  static const String phoneUpdated = 'Phone number updated';
  static const String profileEditPhone = '9512345780';
  static const String choosePhoto = 'Choose photo';
  static const String camera = 'Camera';
  static const String gallery = 'Gallery';
  static const String photoUpdated = 'Profile photo updated';
  static const String photoPickFailed = 'Could not pick photo';

  static String otpSubtitle(String maskedPhone) =>
      'Enter your 4 digit OTP sent on $maskedPhone';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Name';
  static const String phone = 'Phone';
  static const String submit = 'Submit';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String ok = 'OK';
  static const String retry = 'Retry';
  static const String loading = 'Loading...';

  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Enter a valid email address';
  static const String invalidPassword =
      'Password must be at least 8 characters and include a letter and a number';
  static const String invalidPhone = 'Enter a valid phone number';
  static const String passwordMismatch = 'Passwords do not match';

  static const String somethingWentWrong = 'Something went wrong';
  static const String noInternet = 'No internet connection';
  static const String requestTimedOut = 'Request timed out. Please try again';
  static const String unauthorized = 'Session expired. Please login again';
  static const String forbidden = 'You are not allowed to perform this action';
  static const String notFound = 'Requested resource was not found';
  static const String tooManyRequests = 'Too many attempts. Please wait';
  static const String serverError = 'Server error. Please try again later';
  static const String success = 'Success';
  static const String error = 'Error';
  static const String info = 'Info';

  static const String homeTitle = 'Home';
  static const String ridesTitle = 'Rides';
  static const String profileTitle = 'Profile';
  static const String pickupLocation = 'Pickup Location';
  static const String dropLocation = 'Drop Location';
  static const String searchRide = 'Search Ride';
  static const String reviewBooking = 'Review Booking';
  static const String bookingOverview = 'Booking Overview';
  static const String selectedVehicle = 'Selected Vehicle';
  static const String applyCouponCode = 'Apply Coupon Code';
  static const String couponBannerHint =
      'Have a coupon code? Get exclusive discounts on your ride.';
  static const String fareDetails = 'Fare Details';
  static const String baseFare = 'Base Fare';
  static const String distanceFare = 'Distance Fare';
  static const String waitingCharge = 'Waiting Charge';
  static const String tax = 'Tax';
  static const String gst = 'GST';
  static const String cgst = 'CGST';
  static const String sgst = 'SGST';
  static const String igst = 'IGST';
  static const String totalAmount = 'Total Amount';
  static const String confirmBooking = 'Confirm Booking';
  static const String enterCouponCode = 'ENTER COUPON CODE';
  static const String apply = 'Apply';
  static const String availableCoupons = 'Available Coupons';
  static const String applied = 'Applied';
  static const String searchingDriver = 'Searching for Driver';
  static const String searchingForDriver = 'Searching for driver';
  static const String driverOnTheWayLabel = 'Driver on the way';
  static const String driverHasArrived = 'Driver has arrived';
  static const String tripInProgress = 'Trip in progress';
  static const String rideStatusCompleted = 'Completed';
  static const String rideStatusCancelled = 'Cancelled';
  static const String findingDriver = 'Finding a driver nearby';
  static const String findingDriverHint = 'This may take a few seconds...';
  static const String sos = 'SOS';
  static const String sosConfirmMessage =
      'Are you sure? This alerts BizzCab support and your emergency contacts.';
  static const String sosConfirmTitle = 'Raise SOS';
  static const String sosActiveTitle = 'Active SOS';
  static const String sosActiveBanner = 'SOS active — tap for help';
  static const String sosOpen = 'Open';
  static const String addEmergencyContact = 'Add emergency contact';
  static const String emergencyContactsTitle = 'Emergency Contacts';
  static const String emergencyContactsHint =
      'Add at least one contact before raising SOS.';
  static const String contactName = 'Contact name';
  static const String saveContact = 'Save contact';
  static const String deleteContact = 'Remove';
  static const String maxEmergencyContacts = 'You can add up to 3 contacts';
  static const String needEmergencyContact =
      'Add at least 1 emergency contact to raise SOS.';
  static const String locationRequired = 'Location is required to raise SOS.';
  static const String locationDeniedForever =
      'Location permission is off. Enable it in Settings.';
  static const String openSettings = 'Open Settings';
  static const String unableToReachServer = 'Unable to reach server';
  static const String falseAlarm = 'False alarm / Cancel SOS';
  static const String falseAlarmReason = 'False alarm';
  static const String cancelSosConfirm =
      'Cancel this SOS as a false alarm? Support will be notified.';
  static const String sosCancelled = 'SOS cancelled';
  static const String noActiveSos = 'No active SOS';
  static const String sosHistory = 'SOS History';
  static const String sosHistoryHint = 'Past SOS alerts';
  static const String noSosHistory = 'No SOS alerts yet';
  static const String smsContact = 'Text contact';
  static const String searchingForRides = 'Searching for rides...';
  static const String twoWheeler = '2-Wheeler';
  static const String threeWheeler = '3-Wheeler';
  static const String fourWheeler = '4-Wheeler';
  static const String quickAffordable = 'Quick & Affordable';
  static const String comfortableRides = 'Comfortable Rides';
  static const String spaciousLuxury = 'Spacious & Luxury';
  static const String currentLocation = 'Location';
  static const String currentLocationTitle = 'Current Location';
  static const String myBookings = 'My Bookings';
  static const String ongoing = 'Ongoing';
  static const String completed = 'Completed';
  static const String cancelledTab = 'Cancelled';
  static const String bookingIdPrefix = 'Booking ID: ';
  static const String noRidesYet = 'No rides yet';
  static const String noRidesHint =
      'Your upcoming and past rides will appear here.';
  static const String profileHint = 'Manage your profile and saved places.';
  static const String profileUserName = 'Rahul Sharma';
  static const String profileUserPhone = '+91 98765 43210';
  static const String profileUserEmail = 'rahul.s@example.com';
  static const String personalInformation = 'Personal information';
  static const String personalInformationHint = 'Manage your personal details';
  static const String savedAddresses = 'Saved addresses';
  static const String savedAddressesHint = 'Manage and update your addresses';
  static const String addAddress = 'Add Address';
  static const String editAddress = 'Edit Address';
  static const String saveAddress = 'Save Address';
  static const String noAddresses = 'No saved addresses yet';
  static const String addressName = 'Name';
  static const String addressLabel = 'Label';
  static const String addressLine = 'Address';
  static const String confirmLocation = 'Confirm Location';
  static const String searchAddressHint = 'Search on map';
  static const String pickOnMap = 'Pick location on map';
  static const String locatingAddress = 'Getting address...';
  static const String enterAddress = 'Please enter address';
  static const String enterAddressName = 'Please enter a name';
  static const String addressSaved = 'Address saved';
  static const String addressUpdated = 'Address updated';
  static const String addressDeleted = 'Address deleted';
  static const String deleteAddress = 'Delete address';
  static const String deleteAddressConfirm =
      'Remove this address from your saved list?';
  static const String labelHome = 'Home';
  static const String labelWork = 'Work';
  static const String labelOther = 'Other';
  static const String sampleHomeAddress =
      '1234, ABC Colony, Near Lal Bagh, Indore';
  static const String wallet = 'Wallet';
  static const String walletHint = 'Balance, payments & wallet transactions';
  static const String currentBalance = 'CURRENT BALANCE';
  static const String walletBalanceValue = '₹1,250';
  static const String addAmount = 'Add Amount';
  static const String enterAmount = 'Enter amount';
  static const String invalidAmount = 'Enter a valid amount';
  static const String moneyAdded = 'Money added';
  static const String paymentCancelled = 'Payment cancelled';
  static const String paymentFailed = 'Payment failed';
  static const String unableToStartPayment = 'Unable to start payment';
  static const String walletHistory = 'Wallet History';
  static const String filter = 'Filter';
  static const String all = 'All';
  static const String credit = 'Credit';
  static const String debit = 'Debit';
  static const String addedMoney = 'Added Money';
  static const String walletRecharge = 'Wallet Recharge';
  static const String walletPayment = 'Wallet Payment';
  static const String tripIdValue = 'Trip ID: YTR12345';
  static const String walletCreditDate = '21 May 2024, 10:30 AM';
  static const String walletDebitDate = '21 May 2024, 09:15 AM';
  static const String walletCreditAmount = '+ ₹500.00';
  static const String walletDebitAmount = '- ₹120.00';
  static const String walletCreditBalance = 'Balance: ₹2,750.00';
  static const String walletDebitBalance = 'Balance: ₹2,250.00';
  static const String bankDetail = 'Bank Detail';
  static const String bankDetails = 'Bank Details';
  static const String accountHolderName = 'Account Holder Name';
  static const String accountNumber = 'Account Number';
  static const String ifscCode = 'IFSC Code';
  static const String bankName = 'Bank Name';
  static const String accountType = 'Account Type';
  static const String savings = 'Savings';
  static const String currentAccount = 'Current';
  static const String updateBankDetails = 'Update Bank Details';
  static const String bankDetailsUpdated = 'Bank details updated successfully';
  static const String bankDetailHint =
      'balance, payments & wallet transactions';
  static const String rideHistory = 'Ride history';
  static const String findAnswersHint = 'Find answers to common questions';
  static const String helpAndSupport = 'Help & Support';
  static const String ticketIdPrefix = 'Ticket ID: ';
  static const String ticketIdValue = 'SUP-2026-874521';
  static const String ticketDate = '21 June 2026 | 07:45 PM';
  static const String pending = 'Pending';
  static const String lostAndFoundRequest = 'Lost & Found Request';
  static const String ticketDescription =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do tempor incididunt ut labore et dolore magna aliqua.';
  static const String chat = 'Chat';
  static const String addSupportTicket = 'Add Support Ticket';
  static const String issueCategory = 'Issue Category';
  static const String subject = 'Subject';
  static const String description = 'Description';
  static const String imageUpload = 'Image Upload';
  static const String raiseSupportTicket = 'Raise Support Ticket';
  static const String ticketRaised = 'Support ticket raised';
  static const String ticketCreated = 'Ticket created';
  static const String sosRaised = 'SOS raised';
  static const String noNotifications = 'No notifications yet';
  static const String noTickets = 'No support tickets yet';
  static const String selectCategory = 'Please select a category';
  static const String enterSubject = 'Please enter a subject';
  static const String enterMessage = 'Please describe the issue';
  static const String lostAndFound = 'Lost & Found';
  static const String paymentIssue = 'Payment Issue';
  static const String rideIssue = 'Ride Issue';
  static const String privacyPolicy = 'Privacy Policy';
  static const String privacyPolicyHint = 'Learn how we protect your data';
  static const String termsAndConditions = 'Terms & Conditions';
  static const String termsAndConditionsHint = 'Read our terms and conditions';
  static const String faqs = 'FAQs';
  static const String updatedOn = 'Updated On: Apr 2026';
  static const String legalIntro =
      'Learn how we collect, use, and protect your personal information.';
  static const String dataCollection = '1. Data Collection';
  static const String dataUsage = '2. Data Usage';
  static const String dataSecurity = '3. Data Security';
  static const String thirdPartyServices = '4. Third Party Services';
  static const String userRights = '5. User Rights';
  static const String contactInformation = '6. Contact Information';
  static const String legalSectionBody =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nunc vel tincidunt luctus, nunc nisl aliquam nunc, eget aliquam nisl nunc vel nisl. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Integer at nisl vitae arcu facilisis tristique.';
  static const String faqItemTitle = 'Title';
  static const String faqItemAnswer =
      'Answer the frequently asked question in a simple sentence, a longish paragraph, or even in a list.';
  static const String logout = 'Logout';
  static const String logoutHint = 'Log out from your account';
  static const String logoutConfirm = 'Are you sure you want to log out?';
  static const String deleteAccount = 'Delete Account';
  static const String deletePermanently = 'Delete Permanently';
  static const String deleteAccountConfirm =
      'This will permanently remove your account. Continue?';
  static const String accountDeleted = 'Account deleted';
  static const String couponApplied = 'Coupon applied';
  static const String couponInvalid = 'Enter a valid coupon code';
  static const String selectDropLocation = 'Please select drop location';
  static const String pickupDefaultTitle = 'Vijay Nagar';
  static const String pickupDefaultSubtitle = 'Indore, India';
  static const String dropDefaultTitle = 'Dewas';
  static const String dropDefaultSubtitle = 'Madhya Pradesh';
  static const String vehicleToto = 'Toto';
  static const String vehicleAuto = 'Auto';
  static const String vehicleBike = 'Bike';
  static const String vehicleMini = 'Mini';
  static const String comfortableRide = 'Comfortable Ride';
  static const String everydayAffordableRide = 'Everyday Affordable Ride';
  static const String sharePrivateRide = 'Share & Private Ride';
  static const String dropTimeBadge = 'Drop 4:38 pm';
  static const String etaSample = '5 min';
  static const String distanceSample = '03 km';
  static const String couponFirst50 = 'FIRST50';
  static const String couponSave50 = 'SAVE50';
  static const String couponWelcome50 = 'WELCOME50';
  static const String couponRide50 = 'RIDE50';
  static const String couponFirst50Hint = 'Get ₹50 OFF on your first ride';
  static const String validOnAllRides = 'Valid on all rides';
  static const String enterName = 'Enter your name';
  static const String enterEmail = 'Enter email';
  static const String selectCountry = 'Select country';
  static const String country = 'Country';
  static const String showSuccess = 'Show success';
  static const String showError = 'Show error';
  static const String showInfo = 'Show info';
  static const String showDialog = 'Show dialog';
  static const String showLoader = 'Show loader';
  static const String dialogTitle = 'Confirm action';
  static const String dialogMessage =
      'This is a reusable confirmation dialog. Continue?';
  static const String dialogConfirmed = 'Action confirmed';
  static const String formSubmitted = 'Form submitted successfully';
  static const String pleaseFixErrors = 'Please fix the highlighted fields';
  static const String demoSectionForm = 'Form controls';
  static const String demoSectionActions = 'Feedback';
  static const String themeToggle = 'Toggle theme';
  static const String bookingDetail = 'Booking Detail';
  static const String driverOnTheWay =
      'Driver is on the way, will reach you in 2 mins';
  static String driverOnTheWayEta(int minutes) =>
      'Driver is on the way, will reach you in $minutes mins!';
  static const String shareOtpLabel = 'Share OTP : ';
  static const String shareOtpValue = '0204';
  static const String bookingIdLabel = 'Booking ID : ';
  static const String bookingIdValue = '2405201030';
  static const String onTheWay = 'On the way';
  static const String vehicleDetails = 'Vehicle Details';
  static const String driverDetails = 'Driver Details';
  static const String pickupTimeValue = '4.00 pm';
  static const String vehicleNumber = 'UP 32 AB 1234';
  static const String driverName = 'Ramesh Yadav';
  static const String driverRating = '4.8';
  static const String driverPhone = '9876543210';
  static const String couponAppliedLabel = 'Coupon Applied';
  static const String cancelRide = 'Cancel Ride';
  static const String driverTakingTooLong = 'Driver is taking too long';
  static const String changeInMyPlans = 'Change in my plans';
  static const String fareTooHigh = 'Fare is too high';
  static const String rideCancelled = 'Ride cancelled';
  static const String rideCompleted = 'Ride Completed';
  static const String rideCompletedTitle = 'Your Ride is Completed!';
  static const String rideCompletedHint =
      'Thanks for travelling with us. We hope you had a great experience!';
  static const String choosePaymentMethod = 'Choose Payment Method';
  static const String cash = 'Cash';
  static const String upi = 'UPI';
  static const String payNow = 'Pay Now';
  static const String paid = 'Paid';
  static const String payCashToDriver = 'Pay cash to the driver';
  static const String waitingDriverCash =
      'Waiting for the driver to confirm cash collection.';
  static const String walletShortfall = 'Add money to pay with wallet';
  static const String alreadyPaid = 'This ride is already paid';
  static const String rateAndReview = 'Rate & Review';
  static const String starLabel = 'Star';
  static const String shareReviewOptional = 'Share your review (optional)';
  static const String reviewHint =
      'Great food, excellent service and amazing ambiance. Will visit again.';
  static const String reviewSubmitted = 'Thanks for your review';
  static const String callingDriver = 'Calling driver';
  static const String typeHere = 'Type here...';
  static const String newMessage = 'New message';
  static const String newMessageFromDriver = 'New message from your driver';
  static const String chatPhoto = 'Sent a photo';
  static const String chatDate = 'Today, Nov 13';
  static const String chatTime = '11:42 AM';
  static const String chatIncomingOne =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do';
  static const String chatOutgoingOne = 'Lorem ipsum dolor sit amet';
  static const String chatIncomingTwo =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do';
  static const String notificationsTitle = 'Notifications';
  static const String twoMinsAgo = '2 mins ago';
  static const String rideConfirmed = 'Ride Confirmed';
  static const String rideConfirmedBody =
      'Your ride is confirmed! Booking ID: YRSV24052 is scheduled for today at 10:30 AM.';
  static const String driverAssigned = 'Driver Assigned';
  static const String driverAssignedBody =
      'Ramesh Yadav is on his way in a White Maruti Dzire (MP09AB1234).';
  static const String paymentSuccessful = 'Payment Successful';
  static const String paymentSuccessfulBody =
      '₹3500 has been received for your trip to Ujjain.';
  static const String yourSafetyMatters = 'Your safety matters';
  static const String sosSubtitle =
      'Get help, share your ride details or report an issue — quickly and easily.';
  static const String emergencyContact = 'Emergency contact';
  static const String emergencyContactHint =
      'Call your emergency contact instantly.';
  static const String shareLiveRide = 'Share live ride details';
  static const String shareLiveRideHint =
      'Let your loved ones track your ride in real time.';
  static const String reportSafetyIssue = 'Report safety issue';
  static const String reportSafetyIssueHint =
      'Alert us about any unsafe situation or concern.';
  static const String callingEmergency = 'Calling emergency contact';
  static const String rideShared = 'Live ride details shared';
  static const String reportSubmitted = 'Safety report submitted';
  static const String harassment = 'Harassment';
  static const String suspiciousActivity = 'Suspicious Activity';
  static const String unsafeDriving = 'Unsafe Driving';
  static const String safetyConcerns = 'Safety concerns';
  static const String otherReason = 'Other reason';

  // Ride flow
  static const String selectPickupLocation = 'Please select pickup location';
  static const String waitingForPickupLocation =
      'Fetching your current location. Please wait or pick a pickup point.';
  static const String cancelSearch = 'Cancel search';
  static const String cancelSearchTitle = 'Cancel ride search?';
  static const String cancelSearchBody =
      'We are still looking for a driver. Do you want to cancel this booking?';
  static const String keepSearching = 'Keep searching';
  static const String yesCancel = 'Yes, cancel';
  static const String searchCancelledReason = 'Cancelled while searching';
  static const String noDriversAvailableTitle = 'No drivers available';
  static const String noDriversAvailableBody =
      'All drivers nearby are busy right now. Please try again in a moment.';
  static const String tryAgain = 'Try again';
  static const String backToHome = 'Back to home';
  static const String vehiclesLoadFailed =
      'Could not load vehicles for this route.';
  static const String resumingActiveRide =
      'You already have an active ride. Resuming it.';
  static const String loadingRide = 'Loading ride...';
  static String searchingProgress({
    double? radiusKm,
    int? driversNotified,
  }) {
    final km = radiusKm == null
        ? ''
        : (radiusKm % 1 == 0
            ? radiusKm.toStringAsFixed(0)
            : radiusKm.toStringAsFixed(1));
    final base = km.isEmpty
        ? 'Looking for drivers nearby…'
        : 'Looking for drivers within $km km…';
    if (driversNotified == null || driversNotified <= 0) return base;
    final label = driversNotified == 1 ? 'driver' : 'drivers';
    return '$base $driversNotified $label notified';
  }

  // Live ride: track / call
  static const String track = 'Track';
  static const String driverLocationUnavailable =
      'Driver location not available yet, showing pickup';
  static const String unableToOpenMaps = 'Could not open Google Maps';
  static const String yourDriver = 'Your driver';
  static const String driverPhoneUnavailable = 'Driver phone not available';
  static const String unableToStartCall = 'Could not start the call';

  // Location picker
  static const String selectLocationFromList = 'Select a location from the list';
  static const String currentLocationUnavailable =
      'Could not get your current location';
  static const String placeDetailsFailed =
      'Could not load this place. Please try another one.';

  // Rating
  static const String alreadyRated = 'You have already rated this ride';

  // Notifications
  static const String markAllRead = 'Mark all read';

  // Referral
  static const String joinedLabel = 'Joined';
  static const String rewardedLabel = 'Rewarded';
  static const String earnLabel = 'Earn';

  // Field hints
  static const String hintFullName = 'Enter your full name';
  static const String hintEmail = 'Enter your email address';
  static const String hintPhone = 'Enter 10-digit mobile number';
  static const String hintReferralCode = 'Enter referral code (optional)';
  static const String hintAccountHolder = 'Enter account holder name';
  static const String hintAccountNumber = 'Enter account number';
  static const String hintIfsc = 'Enter IFSC code';
  static const String hintBankName = 'Enter bank name';
  static const String hintAccountType = 'Select account type';
  static const String hintContactName = 'Enter contact name';
  static const String hintIssueCategory = 'Select issue category';
  static const String hintSubject = 'Enter subject';
  static const String hintDescription = 'Describe your issue';
  static const String hintImageUpload = 'Tap to attach an image';
  static const String hintAddressLabel = 'Select label';
  static const String hintAddressName = 'e.g. Home, Office';

  // Name validation
  static const String nameLength = 'Name must be 3–30 characters';
  static const String nameCharacters =
      "Name can contain letters, spaces, and . ' - only";

  // Profile
  static const String addEmail = 'Add email';
}
