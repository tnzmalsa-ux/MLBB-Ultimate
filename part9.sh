python3 - << 'PYEOF'
with open("app/src/main/assets/arena3d.html", "r") as f:
    h = f.read()

css_add = """#ann{position:fixed;top:46px;left:50%;transform:translateX(-50%);font-size:21px;font-weight:900;color:#fde047;text-shadow:0 2px 8px #000;pointer-events:none;opacity:0;transition:opacity .25s;z-index:50}
#shopBar{position:fixed;top:50px;right:12px;display:flex;flex-direction:column;gap:5px;z-index:40}
.ibtn{background:rgba(15,23,42,.88);border:1px solid #f59e0b;color:#fde047;border-radius:8px;padding:5px 9px;font-size:10px;font-weight:800}
</style>"""
h = h.replace("</style>", css_add)

hud_add = """<div id="exitBtn">EXIT</div>
<div id="ann"></div>
<div id="shopBar">
  <div class="ibtn" id="buy0">+35 ATK Blade (300g)</div>
  <div class="ibtn" id="buy1">+350 HP Armor (300g)</div>
</div>"""
h = h.replace('<div id="exitBtn">EXIT</div>', hud_add)

player_add = """const player = addUnit({
  name: CFG.heroName, team: 0, kind: 0, lane: 1, isP: true, x: -53, z: 53,
  hp: CFG.maxHp, maxHp: CFG.maxHp, atk: CFG.atk, spd: CFG.speed, rng: CFG.range, rad: 1.6,
  fxCol: CFG.effect, mesh: makeHeroMesh(CFG.heroId, CFG.primary, CFG.accent)
});
player.gold = 350; player.xp = 0; player.lvl = 1; player.lifesteal = 0;
let streak = 0, streakT = 0, firstBlood = false, annT = 0;
function announce(txt, col = '#fde047') {
  const el = document.getElementById('ann');
  el.textContent = txt; el.style.color = col; el.style.opacity = '1'; annT = 2.4;
}
function gainReward(g, x) {
  player.gold += g; player.xp += x;
  while (player.lvl < 15 && player.xp >= player.lvl * 100) {
    player.xp -= player.lvl * 100; player.lvl++;
    player.maxHp += 95; player.hp = Math.min(player.maxHp, player.hp + 120); player.atk += 11;
    announce('LEVEL UP! Lv.' + player.lvl, '#38bdf8');
  }
}
const ITEMS = [
  { name:'Blade of Valor (+35 ATK)', cost:300, apply:()=>{ player.atk += 35; } },
  { name:'Titan Plate (+350 HP)', cost:300, apply:()=>{ player.maxHp += 350; player.hp += 350; } },
  { name:'Wind Boots (+2.5 SPD)', cost:250, apply:()=>{ player.spd += 2.5; } },
  { name:'Blood Scythe (+15% Lifesteal)', cost:400, apply:()=>{ player.lifesteal += 0.15; } }
];
let itemIdx = 0;
function refreshShop() {
  const i0 = ITEMS[itemIdx % 4], i1 = ITEMS[(itemIdx + 1) % 4];
  document.getElementById('buy0').textContent = i0.name + ' - ' + i0.cost + 'g';
  document.getElementById('buy1').textContent = i1.name + ' - ' + i1.cost + 'g';
}
document.getElementById('buy0').addEventListener('touchstart', e => { e.stopPropagation(); buyIdx(itemIdx % 4); }, { passive:false });
document.getElementById('buy1').addEventListener('touchstart', e => { e.stopPropagation(); buyIdx((itemIdx + 1) % 4); }, { passive:false });
function buyIdx(idx) {
  const it = ITEMS[idx];
  if (player.gold < it.cost) { announce('NEED ' + it.cost + ' GOLD!', '#ef4444'); return; }
  player.gold -= it.cost; it.apply(); itemIdx++; refreshShop();
  announce('BOUGHT: ' + it.name, '#4ade80');
}
refreshShop();"""

old_player = """const player = addUnit({
  name: CFG.heroName, team: 0, kind: 0, lane: 1, isP: true, x: -53, z: 53,
  hp: CFG.maxHp, maxHp: CFG.maxHp, atk: CFG.atk, spd: CFG.speed, rng: CFG.range, rad: 1.6,
  fxCol: CFG.effect, mesh: makeHeroMesh(CFG.heroId, CFG.primary, CFG.accent)
});"""
h = h.replace(old_player, player_add)

old_dmg = """function dmgUnit(u, amt, attTeam) {
  u.hp -= amt;
  if (u.hp <= 0) {
    u.hp = 0; u.mesh.visible = false; if (u.lbl) u.lbl.style.display = 'none';
    if (u.kind === 0) {
      u.deaths++; u.respawn = 6;
      if (attTeam === 0) { blueKills++; if (Math.hypot(player.x - u.x, player.z - u.z) < 28) player.kills++; } else redKills++;
    } else if (u.kind === 4) { u.respawn = 18; if (attTeam === 0) { player.hp = Math.min(player.maxHp, player.hp + 260); player.atk += 5; } }
    spawnFx(u.x, u.z, '#ffffff', 4.5);
  }
}"""
new_dmg = """function dmgUnit(u, amt, attTeam) {
  if (u.kind === 2 && matchTime < 120) amt *= 0.7;
  u.hp -= amt;
  if (attTeam === 0 && player.lifesteal > 0 && Math.hypot(player.x - u.x, player.z - u.z) < player.rng + 5) {
    player.hp = Math.min(player.maxHp, player.hp + amt * player.lifesteal);
  }
  if (typeof showDmg === 'function') showDmg(u, Math.round(amt), attTeam === 0);
  if (u.hp <= 0) {
    u.hp = 0; u.mesh.visible = false; if (u.lbl) u.lbl.style.display = 'none';
    if (u.kind === 1 && attTeam === 0 && Math.hypot(player.x - u.x, player.z - u.z) < 28) gainReward(45, 35);
    else if (u.kind === 0) {
      u.deaths++; u.respawn = 6;
      if (attTeam === 0) {
        blueKills++;
        if (Math.hypot(player.x - u.x, player.z - u.z) < 30) {
          player.kills++; gainReward(220, 140); streak = streakT > 0 ? Math.min(5, streak + 1) : 1; streakT = 10;
          if (!firstBlood) { firstBlood = true; announce('FIRST BLOOD!', '#ef4444'); }
          else if (streak >= 2) announce(['','','DOUBLE KILL!','TRIPLE KILL!','MANIAC!','SAVAGE!'][streak], '#facc15');
        }
      } else redKills++;
    } else if (u.kind === 4) {
      u.respawn = 18;
      if (attTeam === 0) {
        gainReward(u.maxHp > 1200 ? 300 : 120, 120);
        player.hp = Math.min(player.maxHp, player.hp + 280); player.atk += 8;
        if (typeof giveBuffHalo === 'function') giveBuffHalo();
        announce(u.maxHp > 1200 ? 'LORD SLAIN! (+300g)' : 'JUNGLE BUFF! (+120g)', '#a855f7');
      }
    }
    spawnFx(u.x, u.z, '#ffffff', 4.5);
  }
}"""
h = h.replace(old_dmg, new_dmg)

old_top = "document.getElementById('tophud').textContent = `BLUE ${blueKills} | ${String(Math.floor(matchTime/60)).padStart(2,'0')}:${String(Math.floor(matchTime%60)).padStart(2,'0')} | RED ${redKills} | KDA ${player.kills}/${player.deaths}/${player.assists}`;"
new_top = """if (annT > 0) { annT -= dt; if (annT <= 0) document.getElementById('ann').style.opacity = '0'; }
  if (streakT > 0) streakT -= dt;
  player.gold += dt * 4;
  document.getElementById('tophud').textContent = `Lv.${player.lvl} | ${Math.floor(player.gold)}g | BLUE ${blueKills} - ${redKills} RED | ${String(Math.floor(matchTime/60)).padStart(2,'0')}:${String(Math.floor(matchTime%60)).padStart(2,'0')} | ${player.kills}/${player.deaths}/${player.assists}`;"""
h = h.replace(old_top, new_top)

with open("app/src/main/assets/arena3d.html", "w") as f:
    f.write(h)
print("PART9_OK")
PYEOF
