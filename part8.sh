python3 - << 'PYEOF'
with open("app/src/main/java/com/mlbbultimate/moba/HeroRegistry.java", "r") as f:
    s = f.read()

levi_java = """Hero h6 = new Hero(6,"Levi","Crimson Phoenix","Assassin",1060,138,310,130,"Phoenix Slash","Flame Dash","Golden Tempest","Solar Inferno");
        h6.skins.add(new Skin("Basic","Crimson Phoenix",Color.parseColor("#B91C1C"),Color.parseColor("#F59E0B"),Color.parseColor("#FDE047")));
        h6.skins.add(new Skin("Elite","Azure Flame",Color.parseColor("#1D4ED8"),Color.parseColor("#38BDF8"),Color.parseColor("#7DD3FC")));
        h6.skins.add(new Skin("Special","Jade Tempest",Color.parseColor("#047857"),Color.parseColor("#34D399"),Color.parseColor("#FDE047")));
        h6.skins.add(new Skin("Epic","Shadow Ember",Color.parseColor("#581C87"),Color.parseColor("#F97316"),Color.parseColor("#FB923C")));
        h6.skins.add(new Skin("Legendary","Celestial Sun",Color.parseColor("#D97706"),Color.parseColor("#FEF08A"),Color.parseColor("#FACC15")));
        HEROES.add(h0); HEROES.add(h1); HEROES.add(h2); HEROES.add(h3); HEROES.add(h4); HEROES.add(h5); HEROES.add(h6);"""

s = s.replace("HEROES.add(h0); HEROES.add(h1); HEROES.add(h2); HEROES.add(h3); HEROES.add(h4); HEROES.add(h5);", levi_java)
with open("app/src/main/java/com/mlbbultimate/moba/HeroRegistry.java", "w") as f:
    f.write(s)

with open("app/src/main/assets/arena3d.html", "r") as f:
    h = f.read()

old_head = "const helm = new THREE.Mesh(new THREE.ConeGeometry(0.55, 0.65, 6), matA); helm.position.y = 3.25;"
new_head = """let helm;
  if (heroId === 6) {
    helm = new THREE.Group();
    const hairMat = new THREE.MeshLambertMaterial({ color: 0xfde047 });
    const topHair = new THREE.Mesh(new THREE.BoxGeometry(0.92, 0.42, 0.92), hairMat); topHair.position.y = 3.24;
    const bangL = new THREE.Mesh(new THREE.BoxGeometry(0.22, 0.55, 0.28), hairMat); bangL.position.set(-0.34, 2.9, 0.36);
    const bangR = new THREE.Mesh(new THREE.BoxGeometry(0.22, 0.55, 0.28), hairMat); bangR.position.set(0.34, 2.9, 0.36);
    const collarL = new THREE.Mesh(new THREE.ConeGeometry(0.28, 0.85, 4), matA); collarL.position.set(-0.62, 2.65, -0.1); collarL.rotation.z = 0.45;
    const collarR = new THREE.Mesh(new THREE.ConeGeometry(0.28, 0.95, 4), matA); collarR.position.set(0.62, 2.7, -0.1); collarR.rotation.z = -0.45;
    legL.material = new THREE.MeshLambertMaterial({ color: 0x1e293b });
    legR.material = new THREE.MeshLambertMaterial({ color: 0x1e293b });
    cape.scale.set(1.25, 1.35, 1); cape.rotation.x = 0.38;
    helm.add(topHair, bangL, bangR, collarL, collarR);
  } else {
    helm = new THREE.Mesh(new THREE.ConeGeometry(0.55, 0.65, 6), matA); helm.position.y = 3.25;
  }"""
h = h.replace(old_head, new_head)

old_wpn = """} else { // Fighter/Assassin Blade
    weapon = new THREE.Mesh(new THREE.BoxGeometry(0.14, 2.1, 0.26), matA);
    weapon.rotation.x = Math.PI / 3; weapon.position.set(0.1, -0.6, 0.85);
  }"""
new_wpn = """} else if (heroId === 6) {
    weapon = new THREE.Group();
    const blade = new THREE.Mesh(new THREE.BoxGeometry(0.12, 2.65, 0.22), new THREE.MeshPhongMaterial({ color: 0xfacc15, emissive: 0xf59e0b, emissiveIntensity: 0.45, shininess: 100 }));
    const hilt = new THREE.Mesh(new THREE.BoxGeometry(0.52, 0.24, 0.34), new THREE.MeshPhongMaterial({ color: 0xdc2626 }));
    hilt.position.y = -1.1; blade.position.y = 0.2;
    weapon.add(blade, hilt); weapon.rotation.x = Math.PI / 3; weapon.position.set(0.1, -0.55, 0.95);
  } else { // Fighter/Assassin Blade
    weapon = new THREE.Mesh(new THREE.BoxGeometry(0.14, 2.1, 0.26), matA);
    weapon.rotation.x = Math.PI / 3; weapon.position.set(0.1, -0.6, 0.85);
  }"""
h = h.replace(old_wpn, new_wpn)

old_tpl = "{ id:5, name:'Seraph', hp:1180, atk:82, spd:14, rng:12, pri:'#D97706', acc:'#FEF08A', fx:'#FBBF24' }"
new_tpl = old_tpl + ",\n  { id:6, name:'Levi', hp:1060, atk:138, spd:17.2, rng:7.2, pri:'#B91C1C', acc:'#F59E0B', fx:'#FDE047' }"
h = h.replace(old_tpl, new_tpl)
h = h.replace("% 6]", "% 7]")

with open("app/src/main/assets/arena3d.html", "w") as f:
    f.write(h)
print("PART8_OK")
PYEOF
