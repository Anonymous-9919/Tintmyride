import { GoogleGenAI } from "@google/genai";

// Initialize the Google Gen AI client.
// By default, it automatically uses the GEMINI_API_KEY environment variable.
const ai = new GoogleGenAI({});

async function run() {
  const prompt = "Explain what a neural network is in one simple sentence.";
  console.log(`Prompt: "${prompt}"\n`);
  
  try {
    // Call the models.generateContent API
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: prompt,
    });

    console.log("Response:");
    console.log(response.text);
  } catch (error) {
    console.error("Error communicating with Gemini:", error);
    if (!process.env.GEMINI_API_KEY) {
      console.error("\n[Tip] It looks like the GEMINI_API_KEY environment variable is not set. Please set it before running the script.");
    }
  }
}

run();
