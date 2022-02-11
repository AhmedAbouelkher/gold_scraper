import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as scraper from "./scraper_utils";
import {savePriceUpdate, fetchLatestPrice} from "./storage";
import {sendNotification} from "./notification";

admin.initializeApp();


// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

export const scrapeForGold = functions.https.onRequest(async (req, res) => {
  // Fetch latest gold price
  const price = await scraper.scrapeMock();
  // Update storage
  await savePriceUpdate(price);
  res.send({price});
});

export const fetchLatestGoldPrice = functions
    .https
    .onRequest(async (req, res) => {
      const price = await fetchLatestPrice() ?? -1;
      res.send({
        price,
      });
    });

export const sendNotificationToToken = functions
    .https
    .onRequest(async (req, res) => {
      const price = await fetchLatestPrice();
      if (!price) {
        res.status(400).send({
          message: "No price data found",
        });
        return;
      }
      await sendNotification({
        price,
        token: req.headers["token"] as string,
      });
      res.send({message: "Sent"});
    });

export const alwaysScrapeForGold = functions
    .runWith({
      memory: "4GB",
    }).pubsub.schedule("*/5 * * * *")
    .timeZone("Egypt/Cairo")
    .onRun(async (context) => {
      // Fetch latest gold price
      const price = await scraper.scrapeMock();
      // Update storage
      await savePriceUpdate(price);

      // Send notification on price threshold
      return null;
    });
