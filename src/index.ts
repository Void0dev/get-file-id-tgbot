import { bot } from "./bot.ts";
import { config } from "./config.ts";
import { app } from "./webhook.ts";
const signals = ["SIGINT", "SIGTERM"];

for (const signal of signals) {
  process.on(signal, async () => {
    console.log(`Received ${signal}. Initiating graceful shutdown...`);
    await app.stop();
    await bot.stop();
    process.exit(0);
  });
}

process.on("uncaughtException", (error) => {
  console.error(error);
});

process.on("unhandledRejection", (error) => {
  console.error(error);
});

app.listen(config.PORT, () => console.log(`Listening on port ${config.PORT}`));
if (config.NODE_ENV === "production") {
  await bot.start();
} else await bot.start();
