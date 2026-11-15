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
scene.background = new THREE.Color(0x081526);
scene.fog = new THREE.Fog(0x081526, 60, 145);

const camera = new THREE.PerspectiveCamera(44, window.innerWidth / window.innerHeight, 0.5, 240);
window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});

scene.add(new THREE.HemisphereLight(0x93c5fd, 0x0f291e, 0.95));
const sun = new THREE.DirectionalLight(0xfffbeb, 1.15);
sun.position.set(30, 65, 40);
if (CFG.gfx >= 2) {
  sun.castShadow = true;
  sun.shadow.mapSize.set(1024, 1024);
  sun.shadow.camera.left = -85; sun.shadow.camera.right = 85;
  sun.shadow.camera.top = 85; sun.shadow.camera.bottom = -85;
}
scene.add(sun);

// 3D Map Floor, River, and 3 Elevated Lanes
const floor = new THREE.Mesh(new THREE.PlaneGeometry(170, 170), new THREE.MeshLambertMaterial({ color: 0x133825 }));
floor.rotation.x = -Math.PI / 2; floor.receiveShadow = true; scene.add(floor);

const river = new THREE.Mesh(new THREE.BoxGeometry(210, 0.14, 11.5), new THREE.MeshPhongMaterial({ color: 0x0284c7, shininess: 90, transparent: true, opacity: 0.88 }));
river.position.set(0, 0.04, 0); river.rotation.y = -Math.PI / 4; scene.add(river);

function addLane(x, z, w, l, rotY) {
  const m = new THREE.Mesh(new THREE.BoxGeometry(w, 0.24, l), new THREE.MeshLambertMaterial({ color: 0x334155 }));
  m.position.set(x, 0.12, z); m.rotation.y = rotY; m.receiveShadow = true; scene.add(m);
  const trim = new THREE.Mesh(new THREE.BoxGeometry(w + 0.8, 0.14, l + 0.8), new THREE.MeshLambertMaterial({ color: 0x475569 }));
  trim.position.set(x, 0.07, z); trim.rotation.y = rotY; scene.add(trim);
}
addLane(-60, 0, 9.5, 130, 0); addLane(0, -60, 130, 9.5, 0); // Top lane
addLane(0, 60, 130, 9.5, 0); addLane(60, 0, 9.5, 130, 0);   // Bot lane
addLane(0, 0, 178, 9.5, Math.PI / 4);                        // Mid lane

// 3D Jungle Bushes
const bushes = [];
const bushMat1 = new THREE.MeshLambertMaterial({ color: 0x15803d });
const bushMat2 = new THREE.MeshLambertMaterial({ color: 0x22c55e });
const bushCoords = [[-52,18],[-52,-18],[-18,-52],[18,-52],[52,-18],[52,18],[-18,52],[18,52],[-14,-6],[14,6],[-26,18],[26,-18]];
for (const [bx, bz] of bushCoords) {
  const g = new THREE.Group();
  for (let i = 0; i < 5; i++) {
    const s = new THREE.Mesh(new THREE.DodecahedronGeometry(1.4 + (i % 2) * 0.5, 0), i % 2 ? bushMat1 : bushMat2);
    s.position.set((i - 2) * 0.9, 0.9, ((i * 7) % 3 - 1) * 0.8); s.castShadow = true; g.add(s);
  }
  g.position.set(bx, 0, bz); scene.add(g);
  bushes.push({ x: bx, z: bz, r: 3.6 });
}

function makeHeroMesh(heroId, primaryHex, accentHex) {
  const g = new THREE.Group();
  const matP = new THREE.MeshPhongMaterial({ color: primaryHex, shininess: 55 });
  const matA = new THREE.MeshPhongMaterial({ color: accentHex, shininess: 80, emissive: accentHex, emissiveIntensity: 0.22 });
  const skinMat = new THREE.MeshLambertMaterial({ color: 0xfde68a });

  const aura = new THREE.Mesh(new THREE.RingGeometry(1.15, 1.45, 24), new THREE.MeshBasicMaterial({ color: accentHex, side: THREE.DoubleSide, transparent: true, opacity: 0.65 }));
  aura.rotation.x = -Math.PI / 2; aura.position.y = 0.26; g.add(aura);

  const legL = new THREE.Mesh(new THREE.BoxGeometry(0.45, 1.1, 0.45), matP); legL.position.set(-0.32, 0.55, 0); legL.castShadow = true;
  const legR = new THREE.Mesh(new THREE.BoxGeometry(0.45, 1.1, 0.45), matP); legR.position.set(0.32, 0.55, 0); legR.castShadow = true;
  const torso = new THREE.Mesh(new THREE.BoxGeometry(1.25, 1.35, 0.72), matP); torso.position.y = 1.75; torso.castShadow = true;
  const chest = new THREE.Mesh(new THREE.BoxGeometry(1.32, 0.45, 0.8), matA); chest.position.y = 2.05;
  const cape = new THREE.Mesh(new THREE.BoxGeometry(1.05, 1.45, 0.12), matA); cape.position.set(0, 1.65, -0.45); cape.rotation.x = 0.22;
  const head = new THREE.Mesh(new THREE.SphereGeometry(0.48, 12, 10), skinMat); head.position.y = 2.85; head.castShadow = true;
  const helm = new THREE.Mesh(new THREE.ConeGeometry(0.55, 0.65, 6), matA); helm.position.y = 3.25;
  const shL = new THREE.Mesh(new THREE.SphereGeometry(0.36, 8, 8), matA); shL.position.set(-0.82, 2.35, 0);
  const shR = new THREE.Mesh(new THREE.SphereGeometry(0.36, 8, 8), matA); shR.position.set(0.82, 2.35, 0);
  const armL = new THREE.Mesh(new THREE.BoxGeometry(0.34, 1.0, 0.34), matP); armL.position.set(-0.82, 1.75, 0);
  const armR = new THREE.Group(); armR.position.set(0.82, 2.2, 0);
  const armMesh = new THREE.Mesh(new THREE.BoxGeometry(0.34, 1.0, 0.34), matP); armMesh.position.y = -0.45; armR.add(armMesh);

  // Role-Specific 3D Weapon
  let weapon;
  if (heroId === 0) { // Tank Shield + Hammer
    weapon = new THREE.Mesh(new THREE.BoxGeometry(0.25, 1.5, 1.1), matA); weapon.position.set(0.1, -0.7, 0.6);
    const sh = new THREE.Mesh(new THREE.BoxGeometry(1.1, 1.6, 0.22), matA); sh.position.set(-0.95, 1.85, 0.55); g.add(sh);
  } else if (heroId === 3 || heroId === 5) { // Mage/Support Staff
    weapon = new THREE.Group();
    const rod = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.08, 2.5, 6), matP); rod.rotation.x = Math.PI / 5;
    const orb = new THREE.Mesh(new THREE.OctahedronGeometry(0.32, 0), matA); orb.position.set(0, 1.15, 0.65);
    weapon.add(rod, orb); weapon.position.set(0.15, -0.5, 0.45);
  } else if (heroId === 4) { // Marksman Bow
    weapon = new THREE.Mesh(new THREE.TorusGeometry(0.75, 0.09, 6, 12, Math.PI), matA);
    weapon.rotation.z = -Math.PI / 2; weapon.position.set(0.1, -0.5, 0.65);
  } else { // Fighter/Assassin Blade
    weapon = new THREE.Mesh(new THREE.BoxGeometry(0.14, 2.1, 0.26), matA);
    weapon.rotation.x = Math.PI / 3; weapon.position.set(0.1, -0.6, 0.85);
  }
  armR.add(weapon);
  g.add(legL, legR, torso, chest, cape, head, helm, shL, shR, armL, armR);
  g.userData = { legL, legR, armR, aura };
  scene.add(g);
  return g;
}

function makeTowerMesh(x, z, colHex, isBase) {
  const g = new THREE.Group();
  const s = isBase ? 1.85 : 1.0;
  const mat = new THREE.MeshPhongMaterial({ color: 0x334155, shininess: 30 });
  const glow = new THREE.MeshPhongMaterial({ color: colHex, emissive: colHex, emissiveIntensity: 0.7 });
  const base = new THREE.Mesh(new THREE.CylinderGeometry(1.9 * s, 2.4 * s, 1.2 * s, 8), mat); base.position.y = 0.6 * s; base.receiveShadow = true;
  const pillar = new THREE.Mesh(new THREE.CylinderGeometry(0.9 * s, 1.45 * s, 4.2 * s, 8), mat); pillar.position.y = 3.0 * s; pillar.castShadow = true;
  const crystal = new THREE.Mesh(new THREE.OctahedronGeometry(1.15 * s, 0), glow); crystal.position.y = 6.2 * s;
  const ring = new THREE.Mesh(new THREE.RingGeometry(13.5, 14.0, 36), new THREE.MeshBasicMaterial({ color: colHex, side: THREE.DoubleSide, transparent: true, opacity: 0.22 }));
  ring.rotation.x = -Math.PI / 2; ring.position.y = 0.28;
  g.add(base, pillar, crystal, ring); g.position.set(x, 0, z); scene.add(g);
  return { g, crystal };
}

function makeMinionMesh(colHex, scale) {
  const g = new THREE.Group();
  const m = new THREE.MeshLambertMaterial({ color: colHex });
  const body = new THREE.Mesh(new THREE.BoxGeometry(0.9 * scale, 1.2 * scale, 0.9 * scale), m); body.position.y = 0.8 * scale; body.castShadow = true;
  const head = new THREE.Mesh(new THREE.SphereGeometry(0.42 * scale, 8, 6), new THREE.MeshLambertMaterial({ color: 0xfef08a })); head.position.y = 1.75 * scale;
  g.add(body, head); scene.add(g); return g;
}
EOF
echo "PART6_OK"
