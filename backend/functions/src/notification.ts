import {messaging} from "firebase-admin";

interface NotificationData {
  price:number, token: string
}

export const sendNotification =
  async (data: NotificationData): Promise<void> => {
    await messaging().sendToDevice(data.token, {
      notification: {
        title: "⭐️ New Gold Update ⭐️",
        body: `Gold is now ${data.price} 🎉`,
      },
    });
  };

