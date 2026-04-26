const { GoogleGenerativeAI } = require("@google/generative-ai");

const geminiKey = process.env.GEMINI_API_KEY;

if (!geminiKey) {
  throw new Error("GEMINI_API_KEY is missing in .env file");
}

const genAI = new GoogleGenerativeAI(geminiKey);

async function summarizePaper(text, language = "English") {
  try {
    // ================= VALIDATION =================
    if (!text || text.trim().length < 50) {
      throw new Error("Text is too short or empty for summarization");
    }

    // ================= MODEL =================
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash",
    });

    // ================= PROMPT =================
    const prompt = `
You are an expert AI research assistant and academic writer.

IMPORTANT RULES:
- You MUST respond ONLY in ${language}
- Do NOT mix languages
- Keep technical accuracy high
- Use simple, structured formatting

STRICT OUTPUT FORMAT:

Title:
Summary:
Problem Statement:
Key Findings:
Use Cases:
Solution Idea:
Future Scope:

INPUT PAPER:
${text}
`;

    // ================= GENERATE =================
    const result = await model.generateContent(prompt);
    const response = await result.response;
    const output = response.text();

    // ================= SAFETY CHECK =================
    if (!output || output.trim().length < 10) {
      throw new Error("Empty or invalid response from Gemini");
    }

    return output;

  } catch (error) {
    console.error(" Gemini Error:", error.message);

    return `AI Error: ${error.message}`;
  }
}

module.exports = { summarizePaper };
