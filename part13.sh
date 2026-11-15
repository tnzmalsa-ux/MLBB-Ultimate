python3 - << 'PYEOF'
import os

with open("app/src/main/assets/arena3d.html", "r") as f:
    h = f.read()

old_ren = "renderer.shadowMap.enabled = CFG.gfx >= 2;"
new_ren = """renderer.shadowMap.enabled = CFG.gfx >= 2;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.18;

function makeTex(kind, repX, repY) {
  const cv = document.createElement('canvas'); cv.width = 256; cv.height = 256;
  const cx = cv.getContext('2d');
  if (kind === 'grass') {
    cx.fillStyle = '#143d26'; cx.fillRect(0,0,256,256);
    for (let i=0; i<900; i++) {
      cx.fillStyle = i%3===0 ? '#1b4f32' : (i%3===1 ? '#0f2f1d' : '#245e3c');
      cx.fillRect((i*73)%256, (i*137)%256, 4, 7);
    }
  } else if (kind === 'stone') {
    cx.fillStyle = '#334155'; cx.fillRect(0,0,256,256);
    cx.strokeStyle = '#1e293b'; cx.lineWidth = 3;
    for (let y=0; y<256; y+=32) for (let x=0; x<256; x+=64) {
      const ox = (y/32)%2 ? 32 : 0;
      cx.fillStyle = ((x+y)%96===0) ? '#3b4a60' : '#2c394b';
      cx.fillRect((x+ox)%256, y, 60, 29); cx.strokeRect((x+ox)%256, y, 60, 29);
    }
  } else {
    const grd = cx.createLinearGradient(0,0,256,256);
    grd.addColorStop(0,'#0369a1'); grd.addColorStop(0.5,'#0ea5e9'); grd.addColorStop(1,'#0284c7');
    cx.fillStyle = grd; cx.fillRect(0,0,256,256);
    cx.fillStyle = 'rgba(224,242,254,0.22)';
    for (let i=0; i<60; i++) cx.fillRect((i*47)%256, (i*89)%256, 38, 4);
  }
  const t = new THREE.CanvasTexture(cv);
  t.wrapS = t.wrapT = THREE.RepeatWrapping; t.repeat.set(repX, repY); return t;
}
const grassTex = makeTex('grass', 22, 22), stoneTex = makeTex('stone', 2, 16), waterTex = makeTex('water', 16, 2);"""
h = h.replace(old_ren, new_ren)

h = h.replace("new THREE.MeshLambertMaterial({ color: 0x133825 })",
              "new THREE.MeshStandardMaterial({ map: grassTex, roughness: 0.92, metalness: 0.05 })")
h = h.replace("new THREE.MeshPhongMaterial({ color: 0x0284c7, shininess: 90, transparent: true, opacity: 0.88 })",
              "new THREE.MeshStandardMaterial({ map: waterTex, roughness: 0.12, metalness: 0.45, transparent: true, opacity: 0.88 })")
h = h.replace("new THREE.MeshLambertMaterial({ color: 0x334155 })",
              "new THREE.MeshStandardMaterial({ map: stoneTex, roughness: 0.78, metalness: 0.12 })")

env_add = """addLane(0, 0, 178, 9.5, Math.PI / 4);
const rockMat = new THREE.MeshStandardMaterial({ color: 0x475569, roughness: 0.85, metalness: 0.1 });
const trunkMat = new THREE.MeshStandardMaterial({ color: 0x5c3a21, roughness: 0.9 });
const leafMat = new THREE.MeshStandardMaterial({ color: 0x166534, roughness: 0.8 });
[[-42,38],[-38,44],[42,-38],[38,-44],[-40,-10],[40,10],[-10,-40],[10,40],[-28,2],[-2,28],[28,-2],[2,-28]].forEach(([rx,rz],idx)=>{
  const rk = new THREE.Mesh(new THREE.DodecahedronGeometry(2.2 + (idx%3)*0.7, 1), rockMat);
  rk.position.set(rx, 0.9, rz); rk.scale.set(1.2, 0.75, 1.1); rk.castShadow = true; rk.receiveShadow = true; scene.add(rk);
  const tr = new THREE.Group();
  const tk = new THREE.Mesh(new THREE.CylinderGeometry(0.32, 0.48, 2.2, 7), trunkMat); tk.position.y = 1.1; tk.castShadow = true;
  const lf1 = new THREE.Mesh(new THREE.ConeGeometry(1.9, 2.6, 7), leafMat); lf1.position.y = 3.0; lf1.castShadow = true;
  const lf2 = new THREE.Mesh(new THREE.ConeGeometry(1.4, 2.2, 7), leafMat); lf2.position.y = 4.2; lf2.castShadow = true;
  tr.add(tk, lf1, lf2); tr.position.set(rx + 3.4, 0, rz - 2.6); scene.add(tr);
});"""
h = h.replace("addLane(0, 0, 178, 9.5, Math.PI / 4);                        // Mid lane", env_add)

h = h.replace("const matP = new THREE.MeshPhongMaterial({ color: primaryHex, shininess: 55 });",
              "const matP = new THREE.MeshStandardMaterial({ color: primaryHex, roughness: 0.36, metalness: 0.42 });")
h = h.replace("const matA = new THREE.MeshPhongMaterial({ color: accentHex, shininess: 80, emissive: accentHex, emissiveIntensity: 0.22 });",
              "const matA = new THREE.MeshStandardMaterial({ color: accentHex, roughness: 0.22, metalness: 0.78, emissive: accentHex, emissiveIntensity: 0.25 });")
h = h.replace("new THREE.BoxGeometry(0.45, 1.1, 0.45)", "new THREE.CylinderGeometry(0.22, 0.17, 1.1, 10)")
h = h.replace("new THREE.BoxGeometry(1.25, 1.35, 0.72)", "new THREE.CylinderGeometry(0.62, 0.46, 1.38, 12)")
h = h.replace("new THREE.BoxGeometry(0.34, 1.0, 0.34)", "new THREE.CylinderGeometry(0.17, 0.13, 1.0, 10)")

old_fx = "fxs.push({ m, life: 0.45, maxLife: 0.45, maxR });"
new_fx = """fxs.push({ m, life: 0.45, maxLife: 0.45, maxR });
  if (CFG.gfx >= 1) {
    for (let s=0; s<6; s++) {
      const sp = new THREE.Mesh(new THREE.SphereGeometry(0.22, 6, 6), new THREE.MeshBasicMaterial({ color: col, transparent:true, opacity:0.95 }));
      const a = (s/6)*Math.PI*2; sp.position.set(x, 1.2, z); scene.add(sp);
      fxs.push({ m:sp, isSpark:true, vx:Math.cos(a)*maxR*2.1, vy:4.5, vz:Math.sin(a)*maxR*2.1, life:0.4, maxLife:0.4, maxR:1 });
    }
  }"""
h = h.replace(old_fx, new_fx)

old_fx_upd = """  for (let i = fxs.length - 1; i >= 0; i--) {
    const f = fxs[i]; f.life -= dt; const s = 1 + (1 - f.life / f.maxLife) * f.maxR;
    f.m.scale.set(s, s, 1); f.m.material.opacity = Math.max(0, f.life / f.maxLife);
    if (f.life <= 0) { scene.remove(f.m); fxs.splice(i, 1); }
  }"""
new_fx_upd = """  waterTex.offset.x += dt * 0.18;
  for (let i = fxs.length - 1; i >= 0; i--) {
    const f = fxs[i]; f.life -= dt;
    if (f.isSpark) { f.m.position.x += f.vx*dt; f.m.position.y += f.vy*dt; f.m.position.z += f.vz*dt; f.vy -= 14*dt; }
    else { const s = 1 + (1 - f.life / f.maxLife) * f.maxR; f.m.scale.set(s, s, 1); }
    f.m.material.opacity = Math.max(0, f.life / f.maxLife);
    if (f.life <= 0) { scene.remove(f.m); fxs.splice(i, 1); }
  }"""
h = h.replace(old_fx_upd, new_fx_upd)

with open("app/src/main/assets/arena3d.html", "w") as f:
    f.write(h)

if os.path.exists("app/src/main/assets/hero_preview.html"):
    with open("app/src/main/assets/hero_preview.html", "r") as f:
        p = f.read()
    p = p.replace("renderer.setSize(window.innerWidth, window.innerHeight);",
                  "renderer.setSize(window.innerWidth, window.innerHeight); renderer.toneMapping=THREE.ACESFilmicToneMapping; renderer.toneMappingExposure=1.2;")
    p = p.replace("new THREE.MeshPhongMaterial({ color:P.primary, shininess:60 })",
                  "new THREE.MeshStandardMaterial({ color:P.primary, roughness:0.35, metalness:0.45 })")
    p = p.replace("new THREE.MeshPhongMaterial({ color:P.accent, shininess:90, emissive:P.accent, emissiveIntensity:0.25 })",
                  "new THREE.MeshStandardMaterial({ color:P.accent, roughness:0.2, metalness:0.8, emissive:P.accent, emissiveIntensity:0.25 })")
    p = p.replace("new THREE.BoxGeometry(0.45,1.1,0.45)", "new THREE.CylinderGeometry(0.22,0.17,1.1,10)")
    p = p.replace("new THREE.BoxGeometry(1.25,1.35,0.72)", "new THREE.CylinderGeometry(0.62,0.46,1.38,12)")
    p = p.replace("new THREE.BoxGeometry(0.34,1.0,0.34)", "new THREE.CylinderGeometry(0.17,0.13,1.0,10)")
    with open("app/src/main/assets/hero_preview.html", "w") as f:
        f.write(p)

print("PART13_OK")
PYEOF
