import 'dart:convert';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:crypto/crypto.dart';

class EmailService {
  // TODO: Replace with your actual email credentials
  // For Gmail, you'll need to use an "App Password" instead of your regular password
  static const String _senderEmail = 'media@webners.com';
  static const String _senderPassword = 'fwjt aqvb ssqq naqa'; // Use App Password for Gmail
  static const String _senderName = 'Next Step App';

  // Gmail SMTP server configuration
  static final SmtpServer _smtpServer = gmail(_senderEmail, _senderPassword);


  /// Generates a 6-digit numeric temporary code for first-time users
  static String generateTemporaryPassword() {
    final random = Random.secure();
    int code = random.nextInt(900000) + 100000; // 100000-999999
    return code.toString();
  }


  /// Sends temporary password to user's email
  static Future<bool> sendTemporaryPassword(String userEmail, String temporaryPassword) async {
    try {
      final message = Message()
        ..from = Address(_senderEmail, _senderName)
        ..recipients.add(userEmail)
        ..subject = 'Your Next Step verification code'
        ..html = _buildTemporaryPasswordEmailHtml(temporaryPassword)
        ..text = 'Your Next Step verification code is: $temporaryPassword\n\nEnter this 6-digit code in the app to continue.';

      final sendReport = await send(message, _smtpServer);
      print('Temporary password email sent successfully: ${sendReport.toString()}');
      return true;
    } on MailerException catch (e) {
      print('Failed to send temporary password email: ${e.toString()}');
      return false;
    } catch (e) {
      print('Unexpected error sending email: ${e.toString()}');
      return false;
    }
  }


  /// Builds HTML content for temporary password email
  static String _buildTemporaryPasswordEmailHtml(String temporaryPassword) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Welcome to Next Step App</title>
    </head>
    <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #1976FF; margin-bottom: 10px;">Welcome to Next Step App!</h1>
            <p style="color: #666; font-size: 16px;">Your account has been created successfully</p>
        </div>
        
        <div style="background-color: #f8f9fa; padding: 30px; border-radius: 10px; margin: 20px 0;">
            <h2 style="color: #333; margin-bottom: 20px;">Your Verification Code</h2>
            <div style="background-color: #1976FF; color: white; font-size: 28px; font-weight: bold; padding: 15px; border-radius: 8px; margin: 20px 0; letter-spacing: 4px; text-align: center;">
                $temporaryPassword
            </div>
            <p style="color: #666; font-size: 14px;">Enter this 6-digit code in the app to continue. For your security, this code will expire soon.</p>
        </div>
        
        <div style="background-color: #d4edda; padding: 20px; border-radius: 8px; border-left: 4px solid #28a745; margin: 20px 0;">
            <h3 style="color: #155724; margin-top: 0;">Next Steps:</h3>
            <ol style="color: #155724; margin: 0;">
                <li>Open the app and enter the 6-digit code above</li>
                <li>Set your own password</li>
                <li>Complete your profile information</li>
                <li>Start exploring the app!</li>
            </ol>
        </div>
        
        <div style="text-align: center; margin-top: 30px; color: #666; font-size: 12px;">
            <p>If you didn't create this account, please contact support immediately.</p>
        </div>
    </body>
    </html>
    ''';
  }

  /// Validates email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
