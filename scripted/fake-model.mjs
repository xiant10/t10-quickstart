// A scripted OpenAI-compatible model. /seen lists the identity headers it has
// received, so the smoke test can prove none reach a provider. When work_create
// is offered it calls it, then quotes the new ID, which completes one agent loop.
import { createServer } from "node:http";

const seen = [];
createServer(async (req, res) => {
	if (req.url === "/seen") return res.end(JSON.stringify(seen));
	let raw = "";
	for await (const part of req) raw += part;
	const { messages, tools = [] } = JSON.parse(raw);
	const last = messages.at(-1);
	seen.push(...Object.keys(req.headers).filter((name) => ["x-user-id", "x-tenant-id", "x-session-id", "x-turn-id"].includes(name)));
	res.writeHead(200, { "content-type": "text/event-stream" });
	const chunk = (delta, finish_reason = null) => `data: ${JSON.stringify({ id: "c", object: "chat.completion.chunk", choices: [{ index: 0, delta, finish_reason }] })}\n\n`;
	if (last.role === "user" && tools.some((tool) => tool.function.name === "work_create")) {
		const call = { index: 0, id: "call_1", type: "function", function: { name: "work_create", arguments: JSON.stringify({ title: "Light profile task" }) } };
		return res.end(`${chunk({ role: "assistant", tool_calls: [call] })}${chunk({}, "tool_calls")}data: [DONE]\n\n`);
	}
	const created = last.role === "tool" ? JSON.stringify(last.content).match(/wi_[0-9a-f]+/)?.[0] : undefined;
	const reply = created === undefined ? "light profile reply" : `created ${created}`;
	res.end(`${chunk({ role: "assistant", content: reply })}${chunk({}, "stop")}data: [DONE]\n\n`);
}).listen(8080);
