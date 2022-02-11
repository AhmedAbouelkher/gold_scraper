import * as puppeteer from "puppeteer";


export const scrape = async (): Promise<number | null> => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  await page.goto("https://goldprice.org/gold-price-egypt.html", {
    waitUntil: "networkidle2",
  });

  await page.select("#gpxtickerLeft_wgt-au", "g");

  await page.waitForTimeout(1500);

  const data = await page.evaluate(async () => {
    const elem = document.getElementById("gpxtickerLeft_price");
    return elem?.textContent;
  });

  await browser.close();

  if (!data) return null;
  return parseFloat(data.replace(/,/g, ""));
};

export const scrapeMock = async (): Promise<number> => {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  return new Promise<number>((resolve, _) => {
    setTimeout(function() {
      return resolve(Math.round(Math.random() * 900));
    }, 0);
  });
};
