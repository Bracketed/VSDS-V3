const axios = require('axios');
const process = require('node:process');
const dotenv = require('dotenv');
const fs = require('node:fs');
const nbx = require('noblox.js');

dotenv.config();

nbx.setCookie(process.env.ROBLOXCOOKIE);
nbx.uploadModel(fs.readFileSync(`./${process.env.TARGETFILE}`), { name: 'VSDS-V3-DEV' }, process.env.TARGETASSET);
