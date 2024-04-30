import { env as Environment } from 'node:process';
import dotenv from 'dotenv';
import fs from 'node:fs';
import nbx from 'noblox.js';

dotenv.config();

const usr = await nbx.setCookie(Environment.ROBLOXCOOKIE);
console.log(`Logged in as ${usr.UserName} [${usr.UserID}]`);

const res = await nbx.uploadModel(
	fs.readFileSync(`./${Environment.TARGETFILE}`),
	{
		name: 'VSDS-V3-DEV',
		description:
			'The Virtua Source Deployment System development module, this is where our experimental code goes before going to the main VSDS loader.',
		copyLocked: false,
		allowComments: false,
		groupId: 33845647,
	},
	Environment.TARGETASSET
);

console.log(res);
