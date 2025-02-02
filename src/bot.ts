import { Bot } from "gramio";
import { config } from "./config.ts";

export const bot = new Bot(config.BOT_TOKEN)
  .command("start", (context) => context.send("Hi!"))
  .on('message', (context) => { 
    context.reply(JSON.stringify(context.update, null, 2));
  })
  .onStart(({ info }) => console.log(`✨ Bot ${info.username} was started!`));
