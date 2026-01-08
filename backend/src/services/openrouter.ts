/**
 * OpenRouter API client
 */

export interface OpenRouterMessage {
  role: string;
  content: string | Array<{ type: string; [key: string]: any }>;
}

/**
 * Call OpenRouter API for chat completions.
 */
export async function callOpenRouter(
  apiKey: string,
  model: string,
  messages: Array<OpenRouterMessage>,
  jsonMode: boolean = true
): Promise<any> {
  const response = await fetch(
    "https://openrouter.ai/api/v1/chat/completions",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "https://tritalk.app",
        "X-Title": "TriTalk",
      },
      body: JSON.stringify({
        model,
        messages,
        ...(jsonMode && { response_format: { type: "json_object" } }),
      }),
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    console.error("OpenRouter API Response:", errorText);
    throw new Error(
      `OpenRouter API error: ${response.status} ${response.statusText} - ${errorText}`
    );
  }

  const data = (await response.json()) as any;
  return data.choices[0].message.content;
}

/**
 * Call OpenRouter API with streaming enabled.
 * Returns the raw Response object for stream processing.
 */
export async function callOpenRouterStreaming(
  apiKey: string,
  model: string,
  messages: Array<OpenRouterMessage>
): Promise<Response> {
  const response = await fetch(
    "https://openrouter.ai/api/v1/chat/completions",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "https://tritalk.app",
        "X-Title": "TriTalk",
      },
      body: JSON.stringify({
        model,
        messages,
        stream: true,
      }),
    }
  );

  if (!response.ok) {
    throw new Error(`OpenRouter API error: ${response.status}`);
  }

  return response;
}

/**
 * Call OpenRouter API with multimodal content (e.g., audio + text).
 */
export async function callOpenRouterMultimodal(
  apiKey: string,
  model: string,
  systemPrompt: string,
  userContent: Array<{ type: string; [key: string]: any }>
): Promise<any> {
  const response = await fetch(
    "https://openrouter.ai/api/v1/chat/completions",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "https://tritalk.app",
        "X-Title": "TriTalk",
      },
      body: JSON.stringify({
        model,
        messages: [
          {
            role: "system",
            content: systemPrompt,
          },
          {
            role: "user",
            content: userContent,
          },
        ],
        response_format: { type: "json_object" },
      }),
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    console.error("OpenRouter API error:", errorText);
    throw new Error(`OpenRouter API error: ${response.status} - ${errorText}`);
  }

  const data = (await response.json()) as any;
  return data.choices[0].message.content;
}
