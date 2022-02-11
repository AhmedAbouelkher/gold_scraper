import {messaging} from "firebase-admin";

interface NotificationData {
  price:number
  tokens: string[] | string
}
export const sendNotification =
  async (data: NotificationData): Promise<void> => {
    await messaging().sendToDevice(data.tokens, {
      notification: {
        title: `🏆 Gold is now ${data.price}`,
        body: "Checkout the new gold price",
      },
    });
  };
