const { summarizePaper } = require("../services/gemini");

/*
====================================================
Handle Summary (Express Version)
====================================================
*/

async function handleSummary(req, res) {
  try {
    const text = req.body.text || "";
    const language = req.body.language || "English";
    const paperId = req.body.paperId || Date.now().toString();

    if (!text) {
      return res.status(400).json({
        error: "Text is required",
      });
    }

    const summary = await summarizePaper(text, language);

    return res.json({
      paperId,
      language,
      summary,
    });
  } catch (error) {
    return res.status(500).json({
      error: error.message,
    });
  }
}

module.exports = { handleSummary };