cat >> app/src/main/assets/arena3d.html << 'EOF'
const units = [], projs = [], fxs = [], crystals = [], meteors = [], zones = [];
const HERO_TEMPLATES = [
  { id:0, name:'Aegis', hp:1650, atk:72, spd:13, rng:6, pri:'#1D4ED8', acc:'#60A5FA', fx:'#38BDF8' },
  { id:1, name:'Kaelen', hp:1250, atk:108, spd:14.7, rng:6.5, pri:'#DC2626', acc:'#FCA5A5', fx:'#F87171' },
  { id:2, name:'Vexia', hp:980, atk:132, spd:16.8, rng:6, pri:'#7E22CE', acc:'#E879F9', fx:'#D946EF' },
  { id:3, name:'Lyra', hp:940, atk:124, spd:13.8, rng:14, pri:'#0284C7', acc:'#A5F3FC', fx:'#22D3EE' },
  { id:4, name:'Orion', hp:920, atk:136, spd:14.2, rng:16, pri:'#16A34A', acc:'#FDE047', fx:'#4ADE80' },
  { id:5, name:'Seraph', hp:1180, atk:82, spd:14, rng:12, pri:'#D97706', acc:'#FEF08A', fx:'#FBBF24' }
];
const lblBox = document.getElementById('labels');
function addUnit(o) {
  o.atkCd=0; o.respawn=0; o.stun=0; o.boost=0; o.shieldT=0; o.kills=0; o.deaths=0; o.assists=0; o.walkT=0; o.swingT=0;
  if (o.kind === 0 || o.kind >= 2) {
    const el = document.createElement('div'); el.className = 'lbl';
    el.innerHTML = `<div style="color:${o.isP?'#fde047':'#fff'}">${o.name}</div><div class="hpbar"><div class="hpfill" style="background:${o.team===0?'#22c55e':o.team===1?'#ef4444':'#facc15'}"></div></div>`;
    lblBox.appendChild(el); o.lbl = el; o.hpEl = el.querySelector('.hpfill');
  }
  units.push(o); return o;
}
const player = addUnit({ name:CFG.heroName, team:0, kind:0, lane:1, isP:true, x:-53, z:53, hp:CFG.maxHp, maxHp:CFG.maxHp, atk:CFG.atk, spd:CFG.speed, rng:CFG.range, rad:1.6, fxCol:CFG.effect, mesh:makeHeroMesh(CFG.heroId, CFG.primary, CFG.accent) });
const aiLanes = [0,0,2,2,0,1,1,2,2];
for (let i=0;i<4;i++) { const t=HERO_TEMPLATES[(CFG.heroId+i+1)%6]; addUnit({name:t.name,team:0,kind:0,lane:aiLanes[i],isP:false,x:-55+i*2.5,z:55-i*2.5,hp:t.hp,maxHp:t.hp,atk:t.atk,spd:t.spd,rng:t.rng,rad:1.6,fxCol:t.fx,mesh:makeHeroMesh(t.id,t.pri,t.acc)}); }
for (let i=0;i<5;i++) { const t=HERO_TEMPLATES[(i+2)%6]; addUnit({name:t.name,team:1,kind:0,lane:aiLanes[i+4],isP:false,x:55-i*2.5,z:-55+i*2.5,hp:t.hp,maxHp:t.hp,atk:t.atk,spd:t.spd,rng:t.rng,rad:1.6,fxCol:t.fx,mesh:makeHeroMesh(t.id,t.pri,t.acc)}); }

function addTower(name, team, kind, x, z, hp, atk, isBase) {
  const tm = makeTowerMesh(x, z, team===0 ? 0x38bdf8 : 0xef4444, isBase); crystals.push(tm.crystal);
  return addUnit({ name, team, kind, lane:1, isP:false, x, z, hp, maxHp:hp, atk, spd:0, rng:14.5, rad:isBase?3.5:2.2, fxCol:team===0?'#38bdf8':'#ef4444', mesh:tm.g });
}
const blueBase = addTower('Blue Base',0,3,-60,60,6000,145,true), redBase = addTower('Red Base',1,3,60,-60,6000,145,true);
[[-60,24],[-60,-18],[-34,34],[-16,16],[-20,60],[22,60]].forEach(p=>addTower('Blue Turret',0,2,p[0],p[1],2400,110,false));
[[-22,-60],[20,-60],[16,-16],[34,-34],[60,18],[60,-24]].forEach(p=>addTower('Red Turret',1,2,p[0],p[1],2400,110,false));
[[-36,20],[-20,38],[36,-20],[20,-38],[-22,-22],[22,22]].forEach((p,idx)=>{
  const b = idx>=4; addUnit({name:b?'Lord Guardian':'Jungle Buff',team:2,kind:4,lane:1,isP:false,x:p[0],z:p[1],hp:b?1800:1000,maxHp:b?1800:1000,atk:b?65:38,spd:5.5,rng:5.5,rad:b?2.1:1.5,fxCol:'#a855f7',mesh:makeMinionMesh(b?0xf59e0b:0xa855f7,b?1.8:1.35)});
});

let matchTime=0, waveTimer=2, blueKills=0, redKills=0, matchOver=false, blueWon=false;
let cd={atk:0,s1:0,s2:0,s3:0,ult:0,regen:0,spell:0}, recallT=-1, regenT=0;
let joyActive=false, joyPid=-1, joyDx=0, joyDz=0;
const jb=document.getElementById('joyBase'), jk=document.getElementById('joyKnob');
jb.addEventListener('touchstart', e=>{const t=e.changedTouches[0];joyPid=t.identifier;joyActive=true;moveJoy(t);},{passive:false});
window.addEventListener('touchmove', e=>{for(const t of e.changedTouches)if(joyActive&&t.identifier===joyPid)moveJoy(t);},{passive:false});
window.addEventListener('touchend', e=>{for(const t of e.changedTouches)if(t.identifier===joyPid){joyActive=false;joyPid=-1;joyDx=0;joyDz=0;jk.style.left='35px';jk.style.top='35px';}});
function moveJoy(t){
  const r=jb.getBoundingClientRect(), cx=r.left+r.width/2, cy=r.top+r.height/2;
  let dx=t.clientX-cx, dy=t.clientY-cy, d=Math.hypot(dx,dy)||1, max=38;
  if(d>max){dx=(dx/d)*max;dy=(dy/d)*max;} jk.style.left=(35+dx)+'px'; jk.style.top=(35+dy)+'px'; joyDx=dx/max; joyDz=dy/max;
}
function spawnFx(x,z,col,maxR){
  const m=new THREE.Mesh(new THREE.RingGeometry(0.4,1.0,28),new THREE.MeshBasicMaterial({color:col,side:THREE.DoubleSide,transparent:true,opacity:0.9}));
  m.rotation.x=-Math.PI/2; m.position.set(x,0.45,z); scene.add(m); fxs.push({m,life:0.5,maxLife:0.5,maxR});
}
function fireProj(src,dst,dmg,stun,pierce,angOff){
  const m=new THREE.Mesh(new THREE.SphereGeometry(src.kind===0?0.48:0.32,8,8),new THREE.MeshBasicMaterial({color:src.fxCol}));
  m.position.set(src.x,1.9,src.z); scene.add(m);
  const baseA = Math.atan2(dst.z-src.z, dst.x-src.x) + (angOff||0);
  projs.push({m,x:src.x,z:src.z,vx:Math.cos(baseA)*36,vz:Math.sin(baseA)*36,dmg,team:src.team,stun:!!stun,pierce:!!pierce,hitSet:new Set(),life:1.3});
}
function dmgUnit(u,amt,attTeam){
  if(u.shieldT>0) amt *= 0.35; u.hp -= amt;
  if(u.hp<=0){
    u.hp=0; u.mesh.visible=false; if(u.lbl)u.lbl.style.display='none';
    if(u.kind===0){ u.deaths++; u.respawn=6; if(attTeam===0){blueKills++;if(Math.hypot(player.x-u.x,player.z-u.z)<28)player.kills++;}else redKills++; }
    else if(u.kind===4){ u.respawn=18; if(attTeam===0){player.hp=Math.min(player.maxHp,player.hp+260);player.atk+=5;} }
    spawnFx(u.x,u.z,'#ffffff',4.5);
  }
}
function nearestEnemy(self,maxD){ let best=null,bd=maxD; for(const u of units)if(u.hp>0&&u.team!==self.team&&!(self.team===2&&u.team===2)){const d=Math.hypot(self.x-u.x,self.z-u.z)-u.rad;if(d<bd){bd=d;best=u;}} return best; }
function aoe(x,z,rad,dmg,stun){ for(const u of units)if(u.hp>0&&u.team!==0&&Math.hypot(x-u.x,z-u.z)<=rad+u.rad){dmgUnit(u,dmg,0);if(stun)u.stun=1.3;} }

function triggerUltimate(tgt) {
  const hid = CFG.heroId;
  const tx = tgt ? tgt.x : player.x + Math.sin(player.mesh.rotation.y)*8, tz = tgt ? tgt.z : player.z + Math.cos(player.mesh.rotation.y)*8;
  if (hid === 0) { // Aegis: Bastion Fortress Dome
    player.shieldT = 4.5; player.hp = Math.min(player.maxHp, player.hp + player.maxHp*0.25);
    const dome = new THREE.Mesh(new THREE.SphereGeometry(5.5, 16, 12), new THREE.MeshBasicMaterial({color:0xfacc15, wireframe:true, transparent:true, opacity:0.6}));
    scene.add(dome); zones.push({m:dome, follow:player, r:9, dmg:85, heal:0, life:4.5}); aoe(player.x, player.z, 9.5, player.atk*2.5, true);
  } else if (hid === 1) { // Kaelen: Dragon Execution 3 Flame Pillars
    for (let i=0;i<3;i++) {
      const px = player.x + Math.sin(player.mesh.rotation.y)*(4+i*3.5), pz = player.z + Math.cos(player.mesh.rotation.y)*(4+i*3.5);
      const pil = new THREE.Mesh(new THREE.ConeGeometry(2.2, 8, 8), new THREE.MeshBasicMaterial({color:0xf97316, transparent:true, opacity:0.85}));
      pil.position.set(px, 4, pz); scene.add(pil); zones.push({m:pil, x:px, z:pz, r:5.5, dmg:140, heal:0, life:0.9});
      aoe(px, pz, 5.5, player.atk*1.8, true);
    }
  } else if (hid === 2) { // Vexia: Phantom Dance Blink + Shadow Slashes
    if (tgt) { player.x = tgt.x - Math.sin(player.mesh.rotation.y)*2; player.z = tgt.z - Math.cos(player.mesh.rotation.y)*2; }
    player.boost = 3.5; for (let i=0;i<4;i++) spawnFx(player.x+(i-1.5)*2, player.z+(i%2?1.5:-1.5), '#d946ef', 5.5);
    aoe(player.x, player.z, 8.5, player.atk*3.4, true);
  } else if (hid === 3) { // Lyra: Meteor Apocalypse (3 Falling 3D Meteors)
    for (let i=0;i<3;i++) {
      const mx = tx + (i-1)*4.5, mz = tz + (i%2?3:-3);
      const met = new THREE.Mesh(new THREE.DodecahedronGeometry(1.9, 1), new THREE.MeshStandardMaterial({color:0xf97316, emissive:0xef4444, emissiveIntensity:0.9}));
      met.position.set(mx, 26 + i*6, mz); scene.add(met); meteors.push({m:met, tx:mx, tz:mz, dmg:player.atk*2.2});
    }
  } else if (hid === 4) { // Orion: Supernova 7-Arrow Piercing Fan
    const aim = tgt || { x: player.x + Math.sin(player.mesh.rotation.y)*10, z: player.z + Math.cos(player.mesh.rotation.y)*10 };
    for (let a=-3;a<=3;a++) fireProj(player, aim, player.atk*1.75, false, true, a*0.14);
  } else { // Seraph: Sanctuary Revival Healing Mandala
    const ring = new THREE.Mesh(new THREE.RingGeometry(2, 12.5, 32), new THREE.MeshBasicMaterial({color:0x4ade80, side:THREE.DoubleSide, transparent:true, opacity:0.55}));
    ring.rotation.x = -Math.PI/2; ring.position.set(player.x, 0.35, player.z); scene.add(ring);
    zones.push({m:ring, follow:player, r:12.5, dmg:95, heal:160, life:4.5});
  }
}

function act(type){
  if(matchOver||player.hp<=0)return;
  if(type==='recall'){recallT=3;return;}
  if(type==='regen'&&cd.regen<=0){cd.regen=18;regenT=4;return;}
  if(type==='spell'&&cd.spell<=0){
    cd.spell=24;
    if(CFG.spell==='Flicker'){const dx=Math.abs(joyDx)>0.1?joyDx:0.7,dz=Math.abs(joyDz)>0.1?joyDz:-0.7;player.x=Math.max(-70,Math.min(70,player.x+dx*12));player.z=Math.max(-70,Math.min(70,player.z+dz*12));spawnFx(player.x,player.z,'#fde047',4);}
    else if(CFG.spell==='Healing'){player.hp=Math.min(player.maxHp,player.hp+player.maxHp*0.32);spawnFx(player.x,player.z,'#22c55e',5.5);}
    else if(CFG.spell==='Inspire'){player.boost=5;spawnFx(player.x,player.z,'#ef4444',5);}
    else{const t=nearestEnemy(player,16);if(t)dmgUnit(t,420,0);spawnFx(player.x,player.z,'#38bdf8',6);}
    return;
  }
  const tgt=nearestEnemy(player,Math.max(player.rng+5,18));
  if(type==='atk'&&cd.atk<=0){cd.atk=0.48;player.swingT=0.25;if(tgt){player.mesh.rotation.y=Math.atan2(tgt.x-player.x,tgt.z-player.z);fireProj(player,tgt,player.atk,false);}else spawnFx(player.x,player.z,CFG.effect,3);}
  else if(type==='s1'&&cd.s1<=0){cd.s1=4;player.swingT=0.3;if(tgt)fireProj(player,tgt,player.atk*1.9,false);spawnFx(player.x,player.z,CFG.effect,5);}
  else if(type==='s2'&&cd.s2<=0){cd.s2=6;const dx=Math.abs(joyDx)>0.1?joyDx:0.7,dz=Math.abs(joyDz)>0.1?joyDz:-0.7;player.x=Math.max(-70,Math.min(70,player.x+dx*8));player.z=Math.max(-70,Math.min(70,player.z+dz*8));aoe(player.x,player.z,9,player.atk*1.5,false);spawnFx(player.x,player.z,CFG.accent,8.5);}
  else if(type==='s3'&&cd.s3<=0){cd.s3=7;aoe(player.x,player.z,10,player.atk*1.6,true);spawnFx(player.x,player.z,CFG.effect,9.5);}
  else if(type==='ult'&&cd.ult<=0){cd.ult=13;triggerUltimate(tgt);}
}

['bAtk','bS1','bS2','bS3','bUlt','bRecall','bRegen','bSpell'].forEach((id,i)=>{
  document.getElementById(id).addEventListener('touchstart',e=>{e.stopPropagation();act(['atk','s1','s2','s3','ult','recall','regen','spell'][i]);},{passive:false});
});
document.getElementById('exitBtn').onclick=()=>{if(typeof AndroidBridge!=='undefined')AndroidBridge.exitMatch();};
document.getElementById('endBtn').onclick=()=>{if(typeof AndroidBridge!=='undefined')AndroidBridge.finishMatch(blueWon,player.kills,player.deaths,player.assists);};

const mmCtx=document.getElementById('mm').getContext('2d'), projV=new THREE.Vector3();
let lastT=performance.now();
function loop(now){
  requestAnimationFrame(loop); const dt=Math.min(0.05,(now-lastT)/1000); lastT=now;
  riverTex.offset.x += dt*0.18; for(const cr of crystals)cr.rotation.y+=dt*1.6;
  if(matchOver){renderer.render(scene,camera);return;}

  matchTime+=dt; for(const k in cd)cd[k]=Math.max(0,cd[k]-dt);
  if(regenT>0&&player.hp>0){regenT-=dt;player.hp=Math.min(player.maxHp,player.hp+player.maxHp*0.09*dt);}
  if(recallT>0){recallT-=dt;spawnFx(player.x,player.z,'#fde047',2.4);if(recallT<=0){player.x=-56;player.z=56;player.hp=player.maxHp;}}

  for(let i=meteors.length-1;i>=0;i--){
    const mt=meteors[i]; mt.m.position.y-=dt*34; mt.m.rotation.x+=dt*5;
    if(mt.m.position.y<=0.8){ aoe(mt.tx,mt.tz,7.5,mt.dmg,true); spawnFx(mt.tx,mt.tz,'#f97316',8.5); scene.remove(mt.m); meteors.splice(i,1); }
  }
  for(let i=zones.length-1;i>=0;i--){
    const z=zones[i]; z.life-=dt; if(z.follow)z.m.position.set(z.follow.x,1.5,z.follow.z); z.m.rotation.y+=dt*2;
    const zx=z.follow?z.follow.x:z.x, zz=z.follow?z.follow.z:z.z;
    for(const u of units)if(u.hp>0&&Math.hypot(u.x-zx,u.z-zz)<=z.r){ if(u.team===0&&z.heal>0)u.hp=Math.min(u.maxHp,u.hp+z.heal*dt); if(u.team!==0&&z.dmg>0)dmgUnit(u,z.dmg*dt,0); }
    if(z.life<=0){scene.remove(z.m);zones.splice(i,1);}
  }

  waveTimer-=dt;
  if(waveTimer<=0){waveTimer=14;for(let l=0;l<3;l++)for(let m=0;m<2;m++){
    addUnit({name:'Minion',team:0,kind:1,lane:l,isP:false,x:-53+m*1.8,z:53-m*1.8,hp:260,maxHp:260,atk:26,spd:8.2,rng:4.5,rad:0.8,fxCol:'#60a5fa',mesh:makeMinionMesh(0x3b82f6,0.85)});
    addUnit({name:'Minion',team:1,kind:1,lane:l,isP:false,x:53-m*1.8,z:-53+m*1.8,hp:260,maxHp:260,atk:26,spd:8.2,rng:4.5,rad:0.8,fxCol:'#f87171',mesh:makeMinionMesh(0xef4444,0.85)});
  }}

  if(player.hp>0&&player.stun<=0&&(Math.abs(joyDx)>0.06||Math.abs(joyDz)>0.06)){
    recallT=-1; const s=player.spd*(player.boost>0?1.4:1);
    player.x=Math.max(-70,Math.min(70,player.x+joyDx*s*dt)); player.z=Math.max(-70,Math.min(70,player.z+joyDz*s*dt));
    player.mesh.rotation.y=Math.atan2(joyDx,joyDz); player.walkT+=dt*12;
  }

  for(let i=units.length-1;i>=0;i--){
    const u=units[i];
    if(u.hp<=0){
      if(u.kind===1){scene.remove(u.mesh);units.splice(i,1);continue;}
      if(u.kind===0||u.kind===4){u.respawn-=dt;if(u.respawn<=0){u.hp=u.maxHp;u.mesh.visible=true;if(u.lbl)u.lbl.style.display='block';if(u.kind===0){u.x=u.team===0?-55:55;u.z=u.team===0?55:-55;}}}
      continue;
    }
    u.atkCd=Math.max(0,u.atkCd-dt);u.stun=Math.max(0,u.stun-dt);u.boost=Math.max(0,u.boost-dt);u.shieldT=Math.max(0,u.shieldT-dt);u.swingT=Math.max(0,u.swingT-dt);
    if(!u.isP&&u.stun<=0){
      const tgt=nearestEnemy(u,u.kind>=2?u.rng:17);
      if(tgt){
        const d=Math.hypot(tgt.x-u.x,tgt.z-u.z);
        if(d<=u.rng){u.mesh.rotation.y=Math.atan2(tgt.x-u.x,tgt.z-u.z);if(u.atkCd<=0){u.atkCd=u.kind===2?1.1:0.75;u.swingT=0.25;fireProj(u,tgt,u.atk,false);}}
        else if(u.kind<=1){u.x+=((tgt.x-u.x)/d)*u.spd*dt;u.z+=((tgt.z-u.z)/d)*u.spd*dt;u.mesh.rotation.y=Math.atan2(tgt.x-u.x,tgt.z-u.z);u.walkT+=dt*10;}
      }else if(u.kind<=1){
        let tx=u.team===0?60:-60,tz=u.team===0?-60:60;
        if(u.lane===0&&(u.team===0?u.z>-48:u.x>-48)){tx=-60;tz=-60;} if(u.lane===2&&(u.team===0?u.x<48:u.z<48)){tx=60;tz=60;}
        const d=Math.hypot(tx-u.x,tz-u.z)||1;u.x+=((tx-u.x)/d)*u.spd*dt;u.z+=((tz-u.z)/d)*u.spd*dt;u.mesh.rotation.y=Math.atan2(tx-u.x,tz-u.z);u.walkT+=dt*10;
      }
    }
    u.mesh.position.set(u.x,0,u.z);
    if(u.kind===0&&u.mesh.userData.legL){
      const sw=Math.sin(u.walkT)*0.45; u.mesh.userData.legL.rotation.x=sw; u.mesh.userData.legR.rotation.x=-sw;
      u.mesh.userData.armR.rotation.x=u.swingT>0?-1.4:-sw*0.4;
      u.mesh.userData.aura.material.opacity=bushes.some(b=>Math.hypot(u.x-b.x,u.z-b.z)<b.r)?0.2:0.68;
    }
    if(u.lbl){
      projV.set(u.x,u.kind>=2?8.5:4.2,u.z).project(camera);
      if(projV.z<1){u.lbl.style.display='block';u.lbl.style.left=((projV.x*0.5+0.5)*window.innerWidth)+'px';u.lbl.style.top=((-projV.y*0.5+0.5)*window.innerHeight)+'px';u.hpEl.style.width=Math.max(0,(u.hp/u.maxHp)*100)+'%';}
      else u.lbl.style.display='none';
    }
  }
  for(let i=projs.length-1;i>=0;i--){
    const pr=projs[i]; pr.x+=pr.vx*dt; pr.z+=pr.vz*dt; pr.life-=dt; pr.m.position.set(pr.x,1.9,pr.z); let hit=false;
    for(const u of units)if(u.hp>0&&u.team!==pr.team&&!pr.hitSet.has(u)&&Math.hypot(pr.x-u.x,pr.z-u.z)<=u.rad+0.6){
      pr.hitSet.add(u); dmgUnit(u,pr.dmg,pr.team); if(pr.stun)u.stun=1.1; if(!pr.pierce){hit=true;break;}
    }
    if(hit||pr.life<=0){scene.remove(pr.m);projs.splice(i,1);}
  }
  for(let i=fxs.length-1;i>=0;i--){
    const f=fxs[i]; f.life-=dt; const s=1+(1-f.life/f.maxLife)*f.maxR; f.m.scale.set(s,s,1); f.m.material.opacity=Math.max(0,f.life/f.maxLife);
    if(f.life<=0){scene.remove(f.m);fxs.splice(i,1);}
  }
  camera.position.set(player.x,26,player.z+25); camera.lookAt(player.x,1.2,player.z);
  document.getElementById('tophud').textContent=`BLUE ${blueKills} | ${String(Math.floor(matchTime/60)).padStart(2,'0')}:${String(Math.floor(matchTime%60)).padStart(2,'0')} | RED ${redKills} | KDA ${player.kills}/${player.deaths}/${player.assists}`;
  document.getElementById('bS1').textContent=cd.s1>0?Math.ceil(cd.s1):'S1'; document.getElementById('bS2').textContent=cd.s2>0?Math.ceil(cd.s2):'S2';
  document.getElementById('bS3').textContent=cd.s3>0?Math.ceil(cd.s3):'S3'; document.getElementById('bUlt').textContent=cd.ult>0?Math.ceil(cd.ult):'ULT';
  document.getElementById('bRegen').textContent=cd.regen>0?Math.ceil(cd.regen):'REGEN'; document.getElementById('bSpell').textContent=cd.spell>0?Math.ceil(cd.spell):CFG.spell.toUpperCase();
  mmCtx.fillStyle='#0f291e'; mmCtx.fillRect(0,0,118,118); mmCtx.strokeStyle='#334155'; mmCtx.lineWidth=5;
  mmCtx.beginPath(); mmCtx.moveTo(10,108);mmCtx.lineTo(10,10);mmCtx.lineTo(108,10);mmCtx.moveTo(10,108);mmCtx.lineTo(108,10);mmCtx.moveTo(10,108);mmCtx.lineTo(108,108);mmCtx.lineTo(108,10);mmCtx.stroke();
  for(const u of units)if(u.hp>0){mmCtx.fillStyle=u.isP?'#fde047':(u.team===0?'#38bdf8':(u.team===1?'#ef4444':'#a855f7'));mmCtx.beginPath();mmCtx.arc(((u.x+75)/150)*118,((u.z+75)/150)*118,u.kind===0||u.kind>=2?3:1.5,0,6.28);mmCtx.fill();}
  if(blueBase.hp<=0||redBase.hp<=0){matchOver=true;blueWon=redBase.hp<=0;document.getElementById('endTitle').textContent=blueWon?'VICTORY!':'DEFEAT';document.getElementById('endTitle').style.color=blueWon?'#facc15':'#ef4444';document.getElementById('endSub').textContent=`KDA: ${player.kills}/${player.deaths}/${player.assists}`;document.getElementById('endModal').style.display='flex';}
  renderer.render(scene,camera);
}
requestAnimationFrame(loop);
</script></body></html>
EOF
echo "PART7_OK"
