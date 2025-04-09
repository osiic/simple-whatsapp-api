const express = require("express");
const bodyParser = require("body-parser");
const { Client, LocalAuth } = require("whatsapp-web.js");
const qrcode = require("qrcode-terminal");
const path = require("path");

const app = express();
app.use(bodyParser.json());

// Konfigurasi Client WhatsApp
const client = new Client({
  authStrategy: new LocalAuth({
    dataPath: path.join(__dirname, "wwebjs_auth"),
  }),
  puppeteer: {
    headless: true,
    args: ["--no-sandbox", "--disable-setuid-sandbox"],
  },
});

let isClientReady = false;

// Event Handlers
client.on("qr", (qr) => {
  qrcode.generate(qr, { small: true });
  console.log("Scan QR ini untuk login WhatsApp (hanya sekali)");
});

client.on("authenticated", () => {
  console.log("Login berhasil! Session tersimpan.");
});

client.on("ready", () => {
  console.log("WhatsApp Client siap!");
  isClientReady = true;
});

client.on("disconnected", (reason) => {
  console.log("Client terputus:", reason);
  isClientReady = false;
  setTimeout(() => client.initialize(), 5000);
});

client.initialize();

// API Endpoint untuk PHP
app.post("/send", async (req, res) => {
  if (!isClientReady) {
    return res.status(425).json({ error: "WhatsApp client belum siap" });
  }

  try {
    const { data } = req.body;
    const messages = typeof data === "string" ? JSON.parse(data) : data;

    if (!Array.isArray(messages)) {
      return res.status(400).json({ error: "Data harus berupa array" });
    }

    const results = [];
    for (const msg of messages) {
      try {
        await sendMessage(msg.target, msg.message);
        results.push({ status: "success", target: msg.target });

        // Tambahkan delay jika ada
        if (msg.delay) {
          const delayMs = parseDelay(msg.delay);
          await new Promise((resolve) => setTimeout(resolve, delayMs));
        }
      } catch (error) {
        results.push({
          status: "failed",
          target: msg.target,
          error: error.message,
        });
      }
    }

    res.json({ success: true, results });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Fungsi bantu
async function sendMessage(target, message) {
  const chatId =
    target.endsWith("@g.us") || target.includes("@c.us")
      ? target
      : `${target}@c.us`;

  await client.sendMessage(chatId, message);
}

function parseDelay(delay) {
  if (typeof delay === "number") return delay * 1000;
  if (delay.includes("-")) {
    const [min, max] = delay.split("-").map(Number);
    return (Math.random() * (max - min) + min) * 1000;
  }
  return Number(delay) * 1000;
}

// Jalankan server
const PORT = 9000;
app.listen(PORT, () => {
  console.log(`\n\nWhatsApp API lokal berjalan di http://localhost:${PORT}`);
});
