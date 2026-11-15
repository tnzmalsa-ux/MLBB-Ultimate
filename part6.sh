cat >> app/src/main/assets/arena3d.html << 'EOF'
const CFG = (typeof AndroidBridge !== 'undefined') ? JSON.parse(AndroidBridge.getConfigJson()) : {
  heroId:1, heroName:'Kaelen', role:'Fighter', maxHp:1300, atk:116, speed:14.7, range:7,
  primary:'#D97706', accent:'#FDE047', effect:'#FACC15', spell:'Execute', gfx:2, s1:'S1', s2:'S2', s3:'S3', ult:'ULT'
};
document.getElementById('bSpell').textContent = CFG.spell.toUpperCase();

const canvas = document.getElementById('gl');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: CFG.gfx >= 1, powerPreference: 'high-performance' });
renderer.setPixelRatio(CFG.gfx === 2 ? Math.min(window.devicePixelRatio || 1, 1.5) : 1);
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.shadowMap.enabled = CFG.gfx >= 2;

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x0a192f);
scene.fog = new THREE.Fog(0x0a192f, 65, 155);
const camera = new THREE.PerspectiveCamera(42, window.innerWidth / window.innerHeight, 0.5, 250);
window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight; camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});

scene.add(new THREE.HemisphereLight(0xdbeafe, 0x143322, 1.15));
const sun = new THREE.DirectionalLight(0xfff7ed, 1.35);
sun.position.set(35, 70, 45);
if (CFG.gfx >= 2) {
  sun.castShadow = true; sun.shadow.mapSize.set(1024, 1024);
  sun.shadow.camera.left = -85; sun.shadow.camera.right = 85; sun.shadow.camera.top = 85; sun.shadow.camera.bottom = -85;
}
scene.add(sun);

function makeTex(sz, fn, rep) {
  const cv = document.createElement('canvas'); cv.width = cv.height = sz; fn(cv.getContext('2d'), sz);
  const tx = new THREE.CanvasTexture(cv); tx.wrapS = tx.wrapT = THREE.RepeatWrapping; tx.repeat.set(rep, rep); return tx;
}
const grassTex = makeTex(128, (ctx, s) => {
  ctx.fillStyle = '#153e29'; ctx.fillRect(0, 0, s, s);
  for (let i = 0; i < 450; i++) {
    ctx.fillStyle = i % 3 === 0 ? '#1e5638' : (i % 3 === 1 ? '#0f2d1e' : '#266b45');
    ctx.fillRect((i * 37) % s, (i * 73) % s, 3, 3);
  }
}, 24);
const stoneTex = makeTex(128, (ctx, s) => {
  ctx.fillStyle = '#475569'; ctx.fillRect(0, 0, s, s);
  ctx.strokeStyle = '#1e293b'; ctx.lineWidth = 3;
  for (let y = 0; y < s; y += 32) for (let x = 0; x < s; x += 32) {
    ctx.strokeRect(x + ((y / 32) % 2 ? 16 : 0), y, 32, 32);
  }
  ctx.fillStyle = 'rgba(245,158,11,0.22)'; ctx.fillRect(0, 0, s, 6); ctx.fillRect(0, s - 6, s, 6);
}, 14);
const riverTex = makeTex(128, (ctx, s) => {
  ctx.fillStyle = '#0369a1'; ctx.fillRect(0, 0, s, s);
  ctx.fillStyle = 'rgba(125,211,252,0.28)';
  for (let i = 0; i < 18; i++) ctx.fillRect((i * 19) % s, (i * 29) % s, 28, 4);
}, 10);

const floor = new THREE.Mesh(new THREE.PlaneGeometry(176, 176), new THREE.MeshStandardMaterial({ map: grassTex, roughness: 0.95 }));
floor.rotation.x = -Math.PI / 2; floor.receiveShadow = true; scene.add(floor);
const river = new THREE.Mesh(new THREE.BoxGeometry(215, 0.16, 12), new THREE.MeshStandardMaterial({ map: riverTex, roughness: 0.2, metalness: 0.35, transparent: true, opacity: 0.9 }));
river.position.set(0, 0.05, 0); river.rotation.y = -Math.PI / 4; scene.add(river);

function addLane(x, z, w, l, rotY) {
  const m = new THREE.Mesh(new THREE.BoxGeometry(w, 0.26, l), new THREE.MeshStandardMaterial({ map: stoneTex, roughness: 0.78 }));
  m.position.set(x, 0.13, z); m.rotation.y = rotY; m.receiveShadow = true; scene.add(m);
}
addLane(-60, 0, 10, 130, 0); addLane(0, -60, 130, 10, 0);
addLane(0, 60, 130, 10, 0); addLane(60, 0, 10, 130, 0);
addLane(0, 0, 180, 10, Math.PI / 4);

// Jungle Cliffs & Trees
const rockMat = new THREE.MeshStandardMaterial({ color: 0x334155, roughness: 0.9 });
const trunkMat = new THREE.MeshStandardMaterial({ color: 0x5c3a21, roughness: 0.9 });
const leafMat = new THREE.MeshStandardMaterial({ color: 0x166534, roughness: 0.85 });
[[-36,-10],[-36,6],[-10,-36],[6,-36],[36,10],[36,-6],[10,36],[-6,36],[-42,30],[42,-30]].forEach(([rx, rz]) => {
  const rk = new THREE.Mesh(new THREE.DodecahedronGeometry(3.2, 1), rockMat);
  rk.scale.set(1.5, 0.8, 1.1); rk.position.set(rx, 1.2, rz); rk.castShadow = true; rk.receiveShadow = true; scene.add(rk);
});
[[-72,-72],[-72,0],[0,-72],[72,72],[72,0],[0,72],[-45,10],[45,-10],[-12,45],[12,-45],[-28,-46],[28,46]].forEach(([tx, tz]) => {
  const tr = new THREE.Group();
  const trunk = new THREE.Mesh(new THREE.CylinderGeometry(0.35, 0.55, 2.8, 7), trunkMat); trunk.position.y = 1.4;
  const c1 = new THREE.Mesh(new THREE.ConeGeometry(2.2, 3.2, 7), leafMat); c1.position.y = 3.5; c1.castShadow = true;
  const c2 = new THREE.Mesh(new THREE.ConeGeometry(1.6, 2.5, 7), leafMat); c2.position.y = 5.0; c2.castShadow = true;
  tr.add(trunk, c1, c2); tr.position.set(tx, 0, tz); scene.add(tr);
});

const bushes = [];
const bMat = new THREE.MeshStandardMaterial({ color: 0x16a34a, roughness: 0.8 });
for (const [bx, bz] of [[-52,18],[-52,-18],[-18,-52],[18,-52],[52,-18],[52,18],[-18,52],[18,52],[-14,-6],[14,6],[-26,18],[26,-18]]) {
  const g = new THREE.Group();
  for (let i = 0; i < 6; i++) {
    const bl = new THREE.Mesh(new THREE.ConeGeometry(0.95, 1.9, 5), bMat);
    bl.position.set((i - 2.5) * 0.7, 0.9, ((i * 5) % 3 - 1) * 0.75); bl.castShadow = true; g.add(bl);
  }
  g.position.set(bx, 0, bz); scene.add(g); bushes.push({ x: bx, z: bz, r: 3.6 });
}

function makeHeroMesh(heroId, priHex, accHex) {
  const g = new THREE.Group();
  const matP = new THREE.MeshStandardMaterial({ color: priHex, roughness: 0.35, metalness: 0.45 });
  const matA = new THREE.MeshStandardMaterial({ color: accHex, roughness: 0.25, metalness: 0.7, emissive: accHex, emissiveIntensity: 0.25 });
  const skin = new THREE.MeshStandardMaterial({ color: 0xfde68a, roughness: 0.7 });
  const dark = new THREE.MeshStandardMaterial({ color: 0x1e293b, roughness: 0.5, metalness: 0.5 });

  const aura = new THREE.Mesh(new THREE.RingGeometry(1.18, 1.48, 28), new THREE.MeshBasicMaterial({ color: accHex, side: THREE.DoubleSide, transparent: true, opacity: 0.68 }));
  aura.rotation.x = -Math.PI / 2; aura.position.y = 0.27; g.add(aura);

  const legL = new THREE.Mesh(new THREE.CylinderGeometry(0.22, 0.18, 1.15, 8), dark); legL.position.set(-0.28, 0.58, 0); legL.castShadow = true;
  const legR = new THREE.Mesh(new THREE.CylinderGeometry(0.22, 0.18, 1.15, 8), dark); legR.position.set(0.28, 0.58, 0); legR.castShadow = true;
  const torso = new THREE.Mesh(new THREE.CylinderGeometry(0.56, 0.38, 1.32, 10), matP); torso.position.y = 1.75; torso.castShadow = true;
  const belt = new THREE.Mesh(new THREE.CylinderGeometry(0.42, 0.42, 0.22, 10), matA); belt.position.y = 1.22;
  const cape = new THREE.Mesh(new THREE.ConeGeometry(0.8, 1.6, 4), matP); cape.position.set(0, 1.6, -0.45); cape.rotation.x = 0.25;
  const head = new THREE.Mesh(new THREE.SphereGeometry(0.38, 14, 12), skin); head.position.y = 2.78; head.castShadow = true;
  const visor = new THREE.Mesh(new THREE.BoxGeometry(0.5, 0.14, 0.25), new THREE.MeshBasicMaterial({ color: accHex })); visor.position.set(0, 2.8, 0.28);
  const helm = new THREE.Mesh(new THREE.ConeGeometry(0.46, 0.65, 8), matA); helm.position.y = 3.16;
  const shL = new THREE.Mesh(new THREE.SphereGeometry(0.32, 10, 8), matA); shL.position.set(-0.68, 2.25, 0);
  const shR = new THREE.Mesh(new THREE.SphereGeometry(0.32, 10, 8), matA); shR.position.set(0.68, 2.25, 0);
  const armL = new THREE.Mesh(new THREE.CylinderGeometry(0.16, 0.14, 0.95, 8), matP); armL.position.set(-0.68, 1.72, 0);
  const armR = new THREE.Group(); armR.position.set(0.68, 2.15, 0);
  const aM = new THREE.Mesh(new THREE.CylinderGeometry(0.16, 0.14, 0.95, 8), matP); aM.position.y = -0.42; armR.add(aM);

  if (heroId === 0) {
    const sh = new THREE.Mesh(new THREE.BoxGeometry(1.05, 1.55, 0.18), matA); sh.position.set(-0.85, 1.8, 0.55); g.add(sh);
    const hm = new THREE.Mesh(new THREE.CylinderGeometry(0.28, 0.28, 0.9, 8), matA); hm.rotation.z = Math.PI / 2; hm.position.set(0, -0.8, 0.7); armR.add(hm);
  } else if (heroId === 3 || heroId === 5) {
    const rod = new THREE.Mesh(new THREE.CylinderGeometry(0.06, 0.06, 2.5, 8), dark); rod.rotation.x = Math.PI / 5;
    const orb = new THREE.Mesh(new THREE.OctahedronGeometry(0.28, 1), matA); orb.position.set(0, 1.1, 0.7);
    armR.add(rod, orb); rod.position.set(0, -0.4, 0.45);
    if (heroId === 5) {
      const wL = new THREE.Mesh(new THREE.ConeGeometry(0.45, 1.8, 4), matA); wL.position.set(-0.8, 2.2, -0.5); wL.rotation.z = 0.8;
      const wR = new THREE.Mesh(new THREE.ConeGeometry(0.45, 1.8, 4), matA); wR.position.set(0.8, 2.2, -0.5); wR.rotation.z = -0.8;
      g.add(wL, wR);
    }
  } else if (heroId === 4) {
    const bow = new THREE.Mesh(new THREE.TorusGeometry(0.75, 0.08, 8, 16, Math.PI), matA); bow.rotation.z = -Math.PI / 2; bow.position.set(0, -0.45, 0.65); armR.add(bow);
  } else {
    const blade = new THREE.Mesh(new THREE.ConeGeometry(0.16, 2.1, 4), matA); blade.rotation.x = Math.PI / 2.6; blade.position.set(0, -0.55, 0.9); armR.add(blade);
    if (heroId === 2) { const d2 = blade.clone(); d2.position.set(-0.68, 1.65, 0.75); g.add(d2); }
  }
  g.add(legL, legR, torso, belt, cape, head, visor, helm, shL, shR, armL, armR);
  g.userData = { legL, legR, armR, aura }; scene.add(g); return g;
}

function makeTowerMesh(x, z, colHex, isBase) {
  const g = new THREE.Group(); const s = isBase ? 1.9 : 1.0;
  const st = new THREE.MeshStandardMaterial({ color: 0x334155, roughness: 0.7, metalness: 0.3 });
  const gl = new THREE.MeshStandardMaterial({ color: colHex, emissive: colHex, emissiveIntensity: 0.85, roughness: 0.2 });
  const b1 = new THREE.Mesh(new THREE.CylinderGeometry(2.0 * s, 2.6 * s, 1.1 * s, 8), st); b1.position.y = 0.55 * s; b1.receiveShadow = true;
  const p1 = new THREE.Mesh(new THREE.CylinderGeometry(0.85 * s, 1.45 * s, 4.4 * s, 8), st); p1.position.y = 3.1 * s; p1.castShadow = true;
  const cr = new THREE.Mesh(new THREE.OctahedronGeometry(1.1 * s, 1), gl); cr.position.y = 6.3 * s;
  const rg = new THREE.Mesh(new THREE.RingGeometry(13.6, 14.0, 40), new THREE.MeshBasicMaterial({ color: colHex, side: THREE.DoubleSide, transparent: true, opacity: 0.2 }));
  rg.rotation.x = -Math.PI / 2; rg.position.y = 0.29;
  g.add(b1, p1, cr, rg); g.position.set(x, 0, z); scene.add(g); return { g, crystal: cr };
}

function makeMinionMesh(colHex, scale) {
  const g = new THREE.Group();
  const m = new THREE.MeshStandardMaterial({ color: colHex, roughness: 0.5, metalness: 0.3 });
  const b = new THREE.Mesh(new THREE.CylinderGeometry(0.4 * scale, 0.48 * scale, 1.1 * scale, 8), m); b.position.y = 0.7 * scale; b.castShadow = true;
  const h = new THREE.Mesh(new THREE.SphereGeometry(0.36 * scale, 10, 8), new THREE.MeshStandardMaterial({ color: 0xfef08a })); h.position.y = 1.55 * scale;
  g.add(b, h); scene.add(g); return g;
}
EOF
echo "PART6_OK"
