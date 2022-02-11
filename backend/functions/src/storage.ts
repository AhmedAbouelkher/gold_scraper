import {Timestamp} from "@google-cloud/firestore";
import {firestore} from "firebase-admin";

export const savePriceUpdate = async (price:number): Promise<void> => {
  const createdAt = Timestamp.now();
  const collection = firestore().collection("@prices");
  const doc = collection.doc(`${createdAt.toMillis()}`);

  await doc.create({
    updated_at: createdAt,
    price,
  });

  return Promise.resolve();
};


export const fetchLatestPrice = async (): Promise<number | undefined> => {
  const result = await firestore()
      .collection("@prices")
      .orderBy("updated_at", "desc")
      .limit(1)
      .get();

  if (result.size === 0) return undefined;


  const data = result.docs[0].data();

  return Promise.resolve(data.price);
};

type DocumentReference = firestore.DocumentReference<firestore.DocumentData>

export const registerNewUserWithFCMToken =
    async (token: string): Promise<DocumentReference> => {
      const collection = firestore().collection("@users");
      const doc = collection.doc(token);

      await doc.set({
        token,
      });

      return Promise.resolve(doc);
    };

export const setPriceThresholdForUserById =
    async (userId: string, price: number): Promise<void> => {
      const collection = firestore().collection("@users");
      const doc = collection.doc(userId);

      await doc.update({
        threshold_price: price,
      });

      return Promise.resolve();
    };

export const getSettingsData =
    async (): Promise<firestore.DocumentData> => {
      const doc = await firestore()
          .collection("@settings")
          .doc("settings")
          .get();

      if (doc == undefined|| !doc.exists) throw new Error("NOT SETTINGS");

      return Promise.resolve(doc.data() ?? {});
    };
