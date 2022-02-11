import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

import {scrape} from "./scraper_utils";
import {savePriceUpdate, fetchLatestPrice, getAllUserTokens} from "./storage";
import {sendNotification} from "./notification";

admin.initializeApp();

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

export const scrapeForGold =
  functions
      .https
      .onRequest(async (req, res) => {
        // Fetch latest gold price
        const price = await scrape();
        if (price) {
          // Update storage
          await savePriceUpdate(price);
        }
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
        tokens: req.headers["token"] as string,
      });
      res.send({message: "Sent"});
    });

export const fetchTokens = functions
    .https
    .onRequest(async (req, res) => {
      const tokens = await getAllUserTokens();
      res.send({tokens});
    });

export const alwaysScrapeForGold = functions
    .runWith({
      memory: "4GB",
    })
    .pubsub.schedule("every 10 mins")
    .timeZone("Africa/Cairo")
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    .onRun(async (_) => {
      // Fetch latest gold price
      const price = await scrape();

      if (!price) {
        functions.logger.error("FAILED TO FETCH NEW GOLD PRICE");
        return null;
      }

      // Update storage
      await savePriceUpdate(price);

      return null;
    });

export const scheduleNotifications = functions
    .pubsub.schedule("every 15 mins")
    .timeZone("Africa/Cairo")
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    .onRun(async (_) => {
      // Fetch latest price update
      const latestPrice = await fetchLatestPrice();
      if (!latestPrice) return null;

      // Send notification on price threshold
      const tokens = await getAllUserTokens();
      if (tokens.length !== 0) {
        await sendNotification({
          price: latestPrice,
          tokens: tokens,
        });
      }
      return null;
    });
