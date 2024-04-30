import { env } from 'node:process';
import { config } from 'dotenv';
import { readFileSync } from 'node:fs';
import { setCookie, uploadModel } from 'noblox.js';

config();

const usr = await setCookie(env.ROBLOXCOOKIE);
console.log(`Logged in as ${usr.UserName} [${usr.UserID}]`);

const res = await uploadModel(
	readFileSync(`./${env.TARGETFILE}`),
	{
		name: 'VSDS-V3-DEV',
		description:
			'The Virtua Source Deployment System development module, this is where our experimental code goes before going to the main VSDS loader.',
		copyLocked: false,
		allowComments: false,
		groupId: 33845647,
	},
	env.TARGETASSET
);

console.log(res);
