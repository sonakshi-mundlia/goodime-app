const History = require("../models/History");

/*
========================================
SAVE HISTORY
========================================
*/
async function saveHistory(req, res) {
  try {
    const { fileName, summary } = req.body;

    if (!fileName || !summary) {
      return res.status(400).json({
        error: "fileName and summary are required",
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
    res.status(500).json({
      error: err.message,
    });
  }
}

/*
========================================
GET HISTORY (USER WISE)
========================================
*/
async function getHistory(req, res) {
  try {
    const history = await History.find({
      userId: req.user.id,
    }).sort({ createdAt: -1 });

    res.json(history);
  } catch (err) {
    res.status(500).json({
      error: err.message,
    });
  }
}

/*
========================================
DELETE HISTORY ITEM
========================================
*/
async function deleteHistory(req, res) {
  try {
    const { id } = req.params;

    await History.findOneAndDelete({
      _id: id,
      userId: req.user.id,
    });

    res.json({
      success: true,
      message: "History deleted",
    });
  } catch (err) {
    res.status(500).json({
      error: err.message,
    });
  }
}

module.exports = {
  saveHistory,
  getHistory,
  deleteHistory,
};