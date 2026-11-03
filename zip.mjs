import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';

const [srcDir, outFile] = process.argv.slice(2);

function walk(dir, base = '') {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap(d => {
    const full = path.join(dir, d.name);
    const rel = base ? base + '/' + d.name : d.name;
    return d.isDirectory() ? walk(full, rel) : [{ full, rel }];
  });
}

const crcTable = (() => {
  const t = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    t[n] = c >>> 0;
  }
  return t;
})();
const crc32 = buf => {
  let c = 0xffffffff;
  for (const b of buf) c = crcTable[(c ^ b) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
};

const files = walk(srcDir);
const locals = [];
const centrals = [];
let offset = 0;

for (const f of files) {
  const data = fs.readFileSync(f.full);
  const deflated = zlib.deflateRawSync(data, { level: 9 });
  const name = Buffer.from(f.rel, 'utf8');
  const crc = crc32(data);
  const mode = (fs.statSync(f.full).mode & 0o777) << 16;

  const local = Buffer.alloc(30);
  local.writeUInt32LE(0x04034b50, 0);
  local.writeUInt16LE(20, 4);
  local.writeUInt16LE(0x0800, 6);
  local.writeUInt16LE(8, 8);
  local.writeUInt16LE(0, 10);
  local.writeUInt16LE(0x21, 12);
  local.writeUInt32LE(crc, 14);
  local.writeUInt32LE(deflated.length, 18);
  local.writeUInt32LE(data.length, 22);
  local.writeUInt16LE(name.length, 26);
  local.writeUInt16LE(0, 28);
  locals.push(local, name, deflated);

  const central = Buffer.alloc(46);
  central.writeUInt32LE(0x02014b50, 0);
  central.writeUInt16LE(0x031e, 4);
  central.writeUInt16LE(20, 6);
  central.writeUInt16LE(0x0800, 8);
  central.writeUInt16LE(8, 10);
  central.writeUInt16LE(0, 12);
  central.writeUInt16LE(0x21, 14);
  central.writeUInt32LE(crc, 16);
  central.writeUInt32LE(deflated.length, 20);
  central.writeUInt32LE(data.length, 24);
  central.writeUInt16LE(name.length, 28);
  central.writeUInt16LE(0, 30);
  central.writeUInt16LE(0, 32);
  central.writeUInt16LE(0, 34);
  central.writeUInt16LE(0, 36);
  central.writeUInt32LE(mode, 38);
  central.writeUInt32LE(offset, 42);
  centrals.push(central, name);

  offset += 30 + name.length + deflated.length;
}

const cd = Buffer.concat(centrals);
const end = Buffer.alloc(22);
end.writeUInt32LE(0x06054b50, 0);
end.writeUInt16LE(files.length, 8);
end.writeUInt16LE(files.length, 10);
end.writeUInt32LE(cd.length, 12);
end.writeUInt32LE(offset, 16);

fs.writeFileSync(outFile, Buffer.concat([...locals, cd, end]));
console.log(`✓ ${outFile} — ${files.length} files, ${fs.statSync(outFile).size} bytes`);
