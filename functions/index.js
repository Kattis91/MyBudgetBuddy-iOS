/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize without any custom config - it will use the default database
admin.initializeApp();

exports.sendBudgetNotification = functions.https.onRequest(async (req, res) => {
  try {
    console.log("Starting notifications check");
    const currentDate = new Date();
    console.log("Current date:", currentDate.toISOString());

    const notificationsToSend = [];

    // Get all user tokens once for both checks
    const userTokensSnapshot = await admin.database()
        .ref("userTokens")
        .once("value");

    const userTokens = userTokensSnapshot.val();
    if (!userTokens) {
      console.log("No user tokens found");
      res.status(200).send("No user tokens found");
      return;
    }

    // Check budget periods
    const budgetPeriodsSnapshot = await admin.database()
        .ref("budgetPeriods")
        .once("value");

    const budgetPeriods = budgetPeriodsSnapshot.val();
    if (budgetPeriods) {
      Object.entries(budgetPeriods).forEach(([userId, periods]) => {
        const userToken = userTokens[userId] && userTokens[userId].token;
        if (!userToken) {
          console.log(`No token found for user ${userId}`);
          return;
        }

        Object.entries(periods).forEach(([periodId, periodData]) => {
          const budgetEndDate = new Date(periodData.endDate * 1000);

          const year = currentDate.getFullYear();
          const month = currentDate.getMonth();
          const day = currentDate.getDate();
          const currentDateWithoutTime = new Date(year, month, day);
          const endYear = budgetEndDate.getFullYear();
          const endMonth = budgetEndDate.getMonth();
          const endDay = budgetEndDate.getDate();
          const endDateWithoutTime = new Date(endYear, endMonth, endDay);

          const timeDifference = endDateWithoutTime - currentDateWithoutTime;
          const daysRemaining = Math.floor(
              timeDifference / (1000 * 60 * 60 * 24),
          );

          console.log(`User ${userId}, Period ${periodId}:`);
          console.log(`  End date: ${budgetEndDate.toISOString()}`);
          console.log(`  Days remaining: ${daysRemaining}`);

          if (daysRemaining === 3) {
            notificationsToSend.push({
              token: userToken,
              notification: {
                title: "Budget Period Ending Soon",
                body: "Your current budget period will expire in 3 days.",
              },
              apns: {
                payload: {
                  aps: {
                    sound: "default",
                    badge: 1,
                  },
                },
              },
              data: {
                userId: userId,
                periodId: periodId,
                click_action: "FLUTTER_NOTIFICATION_CLICK",
              },
            });
          }
        });
      });
    }

    // Check invoices
    const invoicesSnapshot = await admin.database()
        .ref("invoices")
        .once("value");

    const invoices = invoicesSnapshot.val();
    if (invoices) {
      Object.entries(invoices).forEach(([userId, userInvoices]) => {
        console.log(`Processing user: ${userId}`);

        const userToken = userTokens[userId] && userTokens[userId].token;
        if (!userToken) {
          console.log(`No token found for user ${userId}`);
          return;
        }

        Object.entries(userInvoices).forEach(([invoiceId, invoiceData]) => {
          console.log(`Raw invoice data for ${invoiceId}:`, invoiceData);

          if (invoiceData.processed) {
            console.log(`Invoice ${invoiceId} is already processed, skipping.`);
            return;
          }

          const expiryTimestamp = Number(invoiceData.expiryDate);
          console.log(`Expiry timestamp: ${expiryTimestamp}`);

          if (isNaN(expiryTimestamp)) {
            console.log(`Invalid expiry date for invoice ${invoiceId}`);
            return;
          }

          const expiryDate = new Date(expiryTimestamp * 1000);

          const currentDateWithoutTime = new Date(
              currentDate.getFullYear(),
              currentDate.getMonth(),
              currentDate.getDate(),
          );

          const expiryDateWithoutTime = new Date(
              expiryDate.getFullYear(),
              expiryDate.getMonth(),
              expiryDate.getDate(),
          );

          const timeDifference = expiryDateWithoutTime - currentDateWithoutTime;
          const daysRemaining = Math.floor(
              timeDifference / (1000 * 60 * 60 * 24),
          );

          console.log(`Invoice ${invoiceId} processing:`);
          console.log(`  Title: ${invoiceData.title}`);
          console.log(`  Expiry date: ${expiryDate.toISOString()}`);
          console.log(`  Days remaining: ${daysRemaining}`);

          if ([7, 3, 1].includes(daysRemaining)) {
            console.log(`Adding notification for invoice ${invoiceId} ` +
                `with title "${invoiceData.title}"`);
            notificationsToSend.push({
              token: userToken,
              notification: {
                title: "Invoice Due Soon",
                body: `Invoice "${invoiceData.title}" is due ` +
                    `in ${daysRemaining} ` +
                    `${daysRemaining === 1 ? "day" : "days"}.`,
              },
              apns: {
                payload: {
                  aps: {
                    sound: "default",
                    badge: 1,
                  },
                },
              },
              data: {
                userId: userId,
                invoiceId: invoiceId,
                click_action: "FLUTTER_NOTIFICATION_CLICK",
              },
            });
          }
        });
      });
    }

    console.log(`Total notifications to send: ${notificationsToSend.length}`);

    if (notificationsToSend.length === 0) {
      console.log("No notifications needed");
      res.status(200).send("No notifications needed");
      return;
    }

    // Send all notifications
    const results = await Promise.all(
        notificationsToSend.map((msg) =>
          admin.messaging().send(msg)
              .catch((error) => {
                console.error(`Error sending to token: ${msg.token}`, error);
                return null;
              }),
        ),
    );

    const successCount = results.filter((result) => result !== null).length;
    console.log(`Successfully sent ${successCount} notifications`);
    res.status(200).send(`Successfully sent ${successCount} notifications`);
  } catch (error) {
    console.error("Error in sendNotifications:", error);
    res.status(500).send(`Error: ${error.message}`);
  }
});
