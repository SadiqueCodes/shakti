const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendEmergencyAlert = functions.database
    .ref('/users/{userId}/emergencyContacts')
    .onUpdate(async (change, context) => {
      const contacts = change.after.val();
      const message = context.params.alertMessage;

      const tokens = Object.values(contacts).map(contact => contact.fcmToken);

      const payload = {
        notification: {
          title: 'Emergency Alert!',
          body: message,
        },
        tokens: tokens,
      };

      try {
        await admin.messaging().sendMulticast(payload);
        console.log('Notifications sent successfully!');
      } catch (error) {
        console.error('Error sending notifications:', error);
      }
    });
