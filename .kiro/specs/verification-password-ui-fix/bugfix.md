# Bugfix Requirements Document

## Introduction

The Verification Code and Create New Password screens currently have UI styling inconsistencies that don't match the exact design specifications. These screens are part of the password reset flow and need visual refinement to match the provided design mockups. The issues include incorrect icons, missing text punctuation, inconsistent input field styling, and improper button text. This bugfix ensures both screens precisely match the intended design with consistent rounded corners, proper color usage, and correct text content.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN the Verification Code screen is displayed THEN the system shows a plain mail icon (Iconsax.sms) instead of a mail/envelope with checkmark inside

1.2 WHEN the Verification Code screen displays the subtitle THEN the system shows "Enter the 6-digit code sent to your email" without a period at the end

1.3 WHEN the OTP input boxes are rendered on the Verification Code screen THEN the system uses surfaceMuted background color and ann/primaryNavy border colors instead of the specified light gray background with dark navy borders (#2A2B4D)

1.4 WHEN the Create New Password screen displays the subtitle THEN the system shows "Set a new password for your account" without a period at the end

1.5 WHEN the Create New Password screen displays input fields THEN the system uses default AppInputField styling which may not match the rounded rectangles with dark borders and light gray fill specified in the design

1.6 WHEN the Create New Password screen displays the action button THEN the system shows "Reset Password" text which matches the design (this is actually correct)

### Expected Behavior (Correct)

2.1 WHEN the Verification Code screen is displayed THEN the system SHALL show a mail/envelope icon with a checkmark inside it (using a more appropriate icon or custom implementation)

2.2 WHEN the Verification Code screen displays the subtitle THEN the system SHALL show "Enter the 6-digit code sent to your email." with a period at the end

2.3 WHEN the OTP input boxes are rendered on the Verification Code screen THEN the system SHALL use rounded rectangles with dark navy borders (#2A2B4D or AppColors.chucky), light gray background (#F2F2F5 or AppColors.surfaceMuted), and consistent rounded corners matching AppRadii.radiusMd

2.4 WHEN the Create New Password screen displays the subtitle THEN the system SHALL show "Set a new password for your account." with a period at the end

2.5 WHEN the Create New Password screen displays input fields THEN the system SHALL use rounded rectangles with dark navy borders, light gray fill matching the OTP box styling, and consistent border radius

2.6 WHEN the Create New Password screen displays the action button THEN the system SHALL show "Reset Password" as the button text (already correct, no change needed)

### Unchanged Behavior (Regression Prevention)

3.1 WHEN the user enters a 6-digit code in the OTP field THEN the system SHALL CONTINUE TO automatically focus the next input box and verify when complete

3.2 WHEN the user clicks "Resend Code" link THEN the system SHALL CONTINUE TO show a snackbar message confirming the code was resent

3.3 WHEN the OTP code is incomplete (less than 6 digits) THEN the system SHALL CONTINUE TO keep the Verify button disabled

3.4 WHEN the user completes password creation THEN the system SHALL CONTINUE TO navigate to the password updated confirmation screen

3.5 WHEN the user taps the back arrow on either screen THEN the system SHALL CONTINUE TO navigate back to the previous screen

3.6 WHEN either screen is displayed THEN the system SHALL CONTINUE TO show the orange circular icon container at the top with proper sizing (76x76)

3.7 WHEN input fields receive focus on either screen THEN the system SHALL CONTINUE TO show visual focus indicators

3.8 WHEN the Verify or Reset Password button is loading THEN the system SHALL CONTINUE TO show loading state and disable user interaction
