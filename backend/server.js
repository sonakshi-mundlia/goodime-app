const express = require("express");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
require("dotenv").config();

const connectDB = require("./config/db");
const User = require("./models/User");
const History = require("./models/History");
const auth = require("./middleware/authMiddleware");

const { summarizePaper } = require("./services/gemini");

const app = express();

/*
========================================
DB CONNECT
========================================
*/
connectDB();

/*
========================================
MIDDLEWARE
========================================
*/
app.use(cors());
app.use(express.json());

/*
========================================
AUTH - REGISTER
========================================
*/
app.post("/auth/register", async (req, res) => {
  try {
    const { name, email, password } = req.body;

    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(400).json({ error: "User already exists" });
    }

    const hashed = await bcrypt.hash(password, 10);

    const user = await User.create({
      name,
      email,
      password: hashed,
    });

    const token = jwt.sign(
      { id: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.status(201).json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/*
========================================
AUTH - LOGIN
========================================
*/
app.post("/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ error: "User not found" });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(400).json({ error: "Wrong password" });

    const token = jwt.sign(
      { id: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/*
========================================
PROFILE UPDATE (PROTECTED)
========================================
*/
app.put("/auth/profile", auth, async (req, res) => {
  try {
    const userId = req.user.id;
    const { name, email } = req.body;

    const update = {};
    if (name) update.name = name;
    if (email) update.email = email;

    const user = await User.findByIdAndUpdate(
      userId,
      update,
      { new: true }
    );

    res.json({
      message: "Profile updated",
      user,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/*
========================================
SUMMARY (PUBLIC + OPTIONAL AUTH)
========================================
*/
app.post("/summary", async (req, res) => {
  try {

    let userId = null;

    const authHeader = req.headers.authorization;

    if (authHeader) {
      try {
        const token = authHeader.split(" ")[1];

        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        userId = decoded.id;

      } catch (e) {
      }
    } else {
      console.log("NO AUTH HEADER FOUND");
    }

    const { text, language } = req.body;


    if (!text) {
      return res.status(400).json({ error: "Text is required" });
    }
    const summaryText = await summarizePaper(text, language || "English");

    let savedHistory = null;

    if (userId) {

      savedHistory = await History.create({
        userId,
        fileName: "AI Summary",
        summary: summaryText,
      });
    } else {
      console.log("SKIPPING SAVE (NO USER ID)");
    }

    console.log("============== SUMMARY API END ==============\n");

    return res.json({
      success: true,
      summary: summaryText,
      isSaved: !!userId,
      history: savedHistory,
    });

  } catch (err) {
    console.error("SUMMARY API ERROR:", err);

    return res.status(500).json({
      error: err.message,
    });
  }
});
/*
========================================
SAVE HISTORY (ONLY LOGGED USERS)
========================================
*/
app.post("/history", auth, async (req, res) => {
  try {
    const { fileName, summary } = req.body;

    if (!fileName || !summary) {
      return res.status(400).json({
        error: "fileName and summary required",
      });
    }

    const history = await History.create({
      userId: req.user.id,
      fileName,
      summary,
    });

    res.json({
      success: true,
      history,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/*
========================================
GET HISTORY
========================================
*/
app.get("/history", auth, async (req, res) => {
  try {
    const history = await History.find({
      userId: req.user.id,
    }).sort({ createdAt: -1 });

    res.json(history);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/*
========================================
DELETE HISTORY ITEM
========================================
*/
app.delete("/history/:id", auth, async (req, res) => {
  try {
    await History.findOneAndDelete({
      _id: req.params.id,
      userId: req.user.id,
    });

    res.json({
      success: true,
      message: "History deleted",
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/*
========================================
SEARCH (PLACEHOLDER)
========================================
*/
app.get("/search", async (req, res) => {
  res.json({ message: "Search API ready" });
});

/*
========================================
HEALTH CHECK
========================================
*/
app.get("/", (req, res) => {
  res.send("Backend running successfully");
});

/*
========================================
START SERVER
========================================
*/
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
