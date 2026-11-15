python3 - << 'PYEOF'
with open("app/src/main/assets/arena3d.html", "r") as f:
    h = f.read()

h = h.replace("</style>", ".dmg{position:absolute;font-size:12px;font-weight:900;text-shadow:0 1px 4px #000;pointer-events:none;transform:translate(-50%,-100%)}\n</style>")

old_base = "const blueBase = addTower('Blue Base', 0, 3, -60, 60, 6000, 145, true);"
new_base = """// Base High-Ground Walls & Turret Shield Plates
function addWall(x, z, w, d, col) {
  const m = new THREE.Mesh(new THREE.BoxGeometry(w, 2.8, d), new THREE.MeshPhongMaterial({ color: col }));
  m.position.set(x, 1.4, z); scene.add(m);
}
addWall(-52, 68, 18, 1.6, 0x1e3a8a); addWall(-68, 52, 1.6, 18, 0x1e3a8a);
addWall(52, -68, 18, 1.6, 0x7f1d1d); addWall(68, -52, 1.6, 18, 0x7f1d1d);

const aimRing = new THREE.Mesh(new THREE.RingGeometry(0.92, 1.0, 32), new THREE.MeshBasicMaterial({ color: 0x38bdf8, side: THREE.DoubleSide, transparent: true, opacity: 0.75 }));
aimRing.rotation.x = -Math.PI / 2; aimRing.visible = false; scene.add(aimRing);

let buffHalo = null;
function giveBuffHalo() {
  if (buffHalo) return;
  buffHalo = new THREE.Mesh(new THREE.TorusGeometry(1.7, 0.08, 6, 28), new THREE.MeshBasicMaterial({ color: 0xfacc15 }));
  buffHalo.rotation.x = Math.PI / 2; buffHalo.position.y = 0.6; player.mesh.add(buffHalo);
}

const dmgPopups = [];
function showDmg(u, amt, isBlue) {
  if (CFG.gfx === 0 || dmgPopups.length > 14) return;
  const el = document.createElement('div'); el.className = 'dmg';
  el.style.color = isBlue ? '#fde047' : '#fb7185';
  el.textContent = '-' + amt;
  lblBox.appendChild(el);
  dmgPopups.push({ el, x: u.x + (Math.random()-0.5)*1.5, y: 3.6, z: u.z, life: 0.65 });
}
const blueBase = addTower('Blue Base', 0, 3, -60, 60, 6000, 145, true);"""
h = h.replace(old_base, new_base)

old_bind = """['bAtk','bS1','bS2','bS3','bUlt','bRecall','bRegen','bSpell'].forEach((id, i) => {
  const acts = ['atk','s1','s2','s3','ult','recall','regen','spell'];
  document.getElementById(id).addEventListener('touchstart', e => { e.stopPropagation(); act(acts[i]); }, { passive: false });
});"""
new_bind = """const skillRadii = { s1:5, s2:8.5, s3:10, ult:12.5 };
['bAtk','bS1','bS2','bS3','bUlt','bRecall','bRegen','bSpell'].forEach((id, i) => {
  const acts = ['atk','s1','s2','s3','ult','recall','regen','spell'];
  const el = document.getElementById(id), a = acts[i];
  el.addEventListener('touchstart', e => {
    e.stopPropagation();
    if (skillRadii[a]) {
      aimRing.scale.set(skillRadii[a], skillRadii[a], 1);
      aimRing.position.set(player.x, 0.35, player.z);
      aimRing.visible = true;
    } else act(a);
  }, { passive: false });
  el.addEventListener('touchend', e => {
    e.stopPropagation();
    if (skillRadii[a]) { aimRing.visible = false; act(a); }
  }, { passive: false });
});"""
h = h.replace(old_bind, new_bind)

old_render = "  renderer.render(scene, camera);"
new_render = """  if (aimRing.visible) aimRing.position.set(player.x, 0.35, player.z);
  if (buffHalo) buffHalo.rotation.z += dt * 2.5;
  for (let i = dmgPopups.length - 1; i >= 0; i--) {
    const dp = dmgPopups[i]; dp.life -= dt; dp.y += dt * 2.2;
    projV.set(dp.x, dp.y, dp.z).project(camera);
    dp.el.style.left = ((projV.x * 0.5 + 0.5) * window.innerWidth) + 'px';
    dp.el.style.top = ((-projV.y * 0.5 + 0.5) * window.innerHeight) + 'px';
    dp.el.style.opacity = Math.max(0, dp.life / 0.65);
    if (dp.life <= 0) { dp.el.remove(); dmgPopups.splice(i, 1); }
  }
  renderer.render(scene, camera);"""
h = h.replace(old_render, new_render)

with open("app/src/main/assets/arena3d.html", "w") as f:
    f.write(h)
print("PART10_OK")
PYEOF
