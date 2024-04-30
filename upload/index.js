const process = require('node:process');
const dotenv = require('dotenv');
const fs = require('node:fs');
const nbx = require('noblox.js');

dotenv.config();

const usr = await nbx.setCookie(process.env.ROBLOXCOOKIE);
console.log(`Logged in as ${usr.UserName} [${usr.UserID}]`);

const res = await nbx.uploadModel(
	fs.readFileSync(`./${process.env.TARGETFILE}`),
	{
		name: 'VSDS-V3-DEV',
		description:
			'The Virtua Source Deployment System development module, this is where our experimental code goes before going to the main VSDS loader.',
		copyLocked: false,
		allowComments: false,
		groupId: 33845647,
	},
	process.env.TARGETASSET
);

console.log(res);
