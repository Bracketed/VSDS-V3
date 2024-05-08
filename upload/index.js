import dotenv from 'dotenv';
import fs from 'node:fs';
import nbx from 'noblox.js';

dotenv.config();

await nbx.setCookie(process.env.ROBLOXCOOKIE);
const usr = await nbx.getCurrentUser();
console.log(`Logged in as ${usr.UserName} [${usr.UserID}]`);

const res = await nbx.uploadModel(
	fs.readFileSync(`./vsds-${process.env.GITHUB_REF_NAME}.rbxm`),
	process.env.TARGETASSET
);

console.log(res);
