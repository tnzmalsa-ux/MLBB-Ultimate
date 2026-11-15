python3 - << 'PYEOF'
import os

with open("app/src/main/java/com/mlbbultimate/moba/HeroRegistry.java", "r") as f:
    s = f.read()

levi_blk = """Hero h6 = new Hero(6,"Levi","Crimson Phoenix","Assassin",1060,138,310,130,"Phoenix Slash","Flame Dash","Golden Tempest","Solar Inferno");
        h6.skins.add(new Skin("Basic","Crimson Phoenix",Color.parseColor("#B91C1C"),Color.parseColor("#F59E0B"),Color.parseColor("#FDE047")));
        h6.skins.add(new Skin("Elite","Azure Flame",Color.parseColor("#1D4ED8"),Color.parseColor("#38BDF8"),Color.parseColor("#7DD3FC")));
        h6.skins.add(new Skin("Special","Jade Tempest",Color.parseColor("#047857"),Color.parseColor("#34D399"),Color.parseColor("#FDE047")));
        h6.skins.add(new Skin("Epic","Shadow Ember",Color.parseColor("#581C87"),Color.parseColor("#F97316"),Color.parseColor("#FB923C")));
        h6.skins.add(new Skin("Legendary","Celestial Sun",Color.parseColor("#D97706"),Color.parseColor("#FEF08A"),Color.parseColor("#FACC15")));
        HEROES.add(h6);"""

cult_blk = """
        Hero h7 = new Hero(7,"Yan Lin","Flame Ruler","Fighter",1340,126,275,130,"Flame Wave","Sky Ruler Dash","Lotus Seal","Angry Flame Lotus");
        h7.skins.add(new Skin("Basic","Azure Ember",Color.parseColor("#0F766E"),Color.parseColor("#2DD4BF"),Color.parseColor("#5EEAD4")));
        h7.skins.add(new Skin("Elite","Bone Frost Flame",Color.parseColor("#475569"),Color.parseColor("#E2E8F0"),Color.parseColor("#38BDF8")));
        h7.skins.add(new Skin("Special","Fallen Heart",Color.parseColor("#991B1B"),Color.parseColor("#F97316"),Color.parseColor("#FDBA74")));
        h7.skins.add(new Skin("Epic","Three-Thousand Star",Color.parseColor("#312E81"),Color.parseColor("#C084FC"),Color.parseColor("#E879F9")));
        h7.skins.add(new Skin("Legendary","Emperor Flame",Color.parseColor("#B45309"),Color.parseColor("#FDE047"),Color.parseColor("#FACC15")));

        Hero h8 = new Hero(8,"Xue Ning","Frost Empress","Mage",960,132,255,300,"Ice Shard","Glacial Glide","Absolute Zero","Frost Phoenix Domain");
        h8.skins.add(new Skin("Basic","Snow Maiden",Color.parseColor("#0284C7"),Color.parseColor("#BAE6FD"),Color.parseColor("#38BDF8")));
        h8.skins.add(new Skin("Elite","Crystal Lotus",Color.parseColor("#0891B2"),Color.parseColor("#A5F3FC"),Color.parseColor("#67E8F9")));
        h8.skins.add(new Skin("Special","Azure Glacier",Color.parseColor("#1D4ED8"),Color.parseColor("#93C5FD"),Color.parseColor("#60A5FA")));
        h8.skins.add(new Skin("Epic","Moonlight Frost",Color.parseColor("#4338CA"),Color.parseColor("#E0E7FF"),Color.parseColor("#A5B4FC")));
        h8.skins.add(new Skin("Legendary","Eternal Ice Empress",Color.parseColor("#0369A1"),Color.parseColor("#FDE047"),Color.parseColor("#BAE6FD")));

        Hero h9 = new Hero(9,"Su Mei","Serpent Spirit","Assassin",1010,135,305,135,"Venom Fang","Serpent Coil","Shadow Veil","Nine-Color Strike");
        h9.skins.add(new Skin("Basic","Jade Viper",Color.parseColor("#15803D"),Color.parseColor("#86EFAC"),Color.parseColor("#4ADE80")));
        h9.skins.add(new Skin("Elite","Amethyst Queen",Color.parseColor("#7E22CE"),Color.parseColor("#E879F9"),Color.parseColor("#C084FC")));
        h9.skins.add(new Skin("Special","Crimson Desert",Color.parseColor("#BE123C"),Color.parseColor("#FDBA74"),Color.parseColor("#FB7185")));
        h9.skins.add(new Skin("Epic","Seven-Color Python",Color.parseColor("#6B21A8"),Color.parseColor("#22D3EE"),Color.parseColor("#F472B6")));
        h9.skins.add(new Skin("Legendary","Celestial Empress",Color.parseColor("#9D174D"),Color.parseColor("#FDE047"),Color.parseColor("#E879F9")));

        Hero h10 = new Hero(10,"Master Dan","Lotus Alchemist","Support",1220,90,260,260,"Pill Spark","Elixir Shield","Cauldron Blast","Flame Sanctuary");
        h10.skins.add(new Skin("Basic","Herb Initiate",Color.parseColor("#0D9488"),Color.parseColor("#99F6E4"),Color.parseColor("#2DD4BF")));
        h10.skins.add(new Skin("Elite","Pill Elder",Color.parseColor("#1E40AF"),Color.parseColor("#93C5FD"),Color.parseColor("#60A5FA")));
        h10.skins.add(new Skin("Special","Jade Cauldron",Color.parseColor("#047857"),Color.parseColor("#FDE047"),Color.parseColor("#34D399")));
        h10.skins.add(new Skin("Epic","Golden Elixir",Color.parseColor("#B45309"),Color.parseColor("#FEF08A"),Color.parseColor("#F59E0B")));
        h10.skins.add(new Skin("Legendary","Pill Sovereign",Color.parseColor("#7C2D12"),Color.parseColor("#FDE047"),Color.parseColor("#FB923C")));

        Hero h11 = new Hero(11,"Lei Feng","Thunder Spear","Marksman",950,138,270,335,"Lightning Bolt","Thunder Step","Shock Ring","Nine-Heavens Bolt");
        h11.skins.add(new Skin("Basic","Storm Scout",Color.parseColor("#4F46E5"),Color.parseColor("#A5B4FC"),Color.parseColor("#818CF8")));
        h11.skins.add(new Skin("Elite","Silver Bolt",Color.parseColor("#334155"),Color.parseColor("#38BDF8"),Color.parseColor("#7DD3FC")));
        h11.skins.add(new Skin("Special","Violet Flash",Color.parseColor("#6D28D9"),Color.parseColor("#DDD6FE"),Color.parseColor("#A78BFA")));
        h11.skins.add(new Skin("Epic","Tempest General",Color.parseColor("#0369A1"),Color.parseColor("#22D3EE"),Color.parseColor("#FDE047")));
        h11.skins.add(new Skin("Legendary","Thunder Emperor",Color.parseColor("#5B21B6"),Color.parseColor("#FDE047"),Color.parseColor("#38BDF8")));

        HEROES.add(h7); HEROES.add(h8); HEROES.add(h9); HEROES.add(h10); HEROES.add(h11);"""

target = "HEROES.add(h6);" if "HEROES.add(h6);" in s else "HEROES.add(h5);"
add_txt = target + ("\n        " + levi_blk if "Hero h6" not in s else "") + cult_blk
s = s.replace(target, add_txt)
with open("app/src/main/java/com/mlbbultimate/moba/HeroRegistry.java", "w") as f:
    f.write(s)

with open("app/src/main/assets/arena3d.html", "r") as f:
    h = f.read()

props_3d = """if (heroId === 7) {
    const ruler = new THREE.Mesh(new THREE.BoxGeometry(0.42, 2.7, 0.16), new THREE.MeshPhongMaterial({ color:0x111827, shininess:90 }));
    ruler.rotation.x = Math.PI / 3; ruler.position.set(0.15, -0.5, 0.9); armR.add(ruler);
  } else if (heroId === 8) {
    const wMat = new THREE.MeshPhongMaterial({ color:0x7dd3fc, emissive:0x38bdf8, emissiveIntensity:0.35, transparent:true, opacity:0.75 });
    const wL = new THREE.Mesh(new THREE.ConeGeometry(0.95, 2.5, 3), wMat); wL.position.set(-0.9, 2.2, -0.55); wL.rotation.set(-0.3, 0, 0.8);
    const wR = new THREE.Mesh(new THREE.ConeGeometry(0.95, 2.5, 3), wMat); wR.position.set(0.9, 2.2, -0.55); wR.rotation.set(-0.3, 0, -0.8);
    g.add(wL, wR);
  } else if (heroId === 9) {
    const hL = new THREE.Mesh(new THREE.ConeGeometry(0.16, 0.7, 5), matA); hL.position.set(-0.35, 3.55, 0); hL.rotation.z = 0.35;
    const hR = new THREE.Mesh(new THREE.ConeGeometry(0.16, 0.7, 5), matA); hR.position.set(0.35, 3.55, 0); hR.rotation.z = -0.35;
    g.add(hL, hR);
  } else if (heroId === 10) {
    const orb = new THREE.Mesh(new THREE.SphereGeometry(0.45, 10, 10), new THREE.MeshPhongMaterial({ color:0xf59e0b, emissive:0xfde047, emissiveIntensity:0.5 }));
    orb.position.set(1.25, 2.5, 0.6); g.add(orb);
  } else if (heroId === 11) {
    const spear = new THREE.Mesh(new THREE.CylinderGeometry(0.06, 0.08, 3.2, 6), new THREE.MeshPhongMaterial({ color:0x38bdf8, emissive:0x818cf8, emissiveIntensity:0.6 }));
    spear.rotation.x = Math.PI / 3; spear.position.set(0.1, -0.4, 1.0); armR.add(spear);
  }
  g.add(legL, legR, torso, chest, cape, head, helm, shL, shR, armL, armR);"""

h = h.replace("g.add(legL, legR, torso, chest, cape, head, helm, shL, shR, armL, armR);", props_3d)

extra_tpl = """HERO_TEMPLATES.push(
  { id:7, name:'Yan Lin', hp:1340, atk:126, spd:15.2, rng:7.2, pri:'#0F766E', acc:'#2DD4BF', fx:'#5EEAD4' },
  { id:8, name:'Xue Ning', hp:960, atk:132, spd:14.1, rng:15, pri:'#0284C7', acc:'#BAE6FD', fx:'#38BDF8' },
  { id:9, name:'Su Mei', hp:1010, atk:135, spd:16.8, rng:7.5, pri:'#7E22CE', acc:'#E879F9', fx:'#C084FC' },
  { id:10, name:'Master Dan', hp:1220, atk:90, spd:14.4, rng:13.5, pri:'#B45309', acc:'#FEF08A', fx:'#F59E0B' },
  { id:11, name:'Lei Feng', hp:950, atk:138, spd:15.0, rng:16.5, pri:'#4F46E5', acc:'#FDE047', fx:'#38BDF8' }
);
const lblBox = document.getElementById('labels');"""
h = h.replace("const lblBox = document.getElementById('labels');", extra_tpl)
h = h.replace("% 6]", "% HERO_TEMPLATES.length]").replace("% 7]", "% HERO_TEMPLATES.length]")

with open("app/src/main/assets/arena3d.html", "w") as f:
    f.write(h)

if os.path.exists("app/src/main/assets/hero_preview.html"):
    with open("app/src/main/assets/hero_preview.html", "r") as f:
        p = f.read()
    p_props = """if (P.heroId===7) { const r=new THREE.Mesh(new THREE.BoxGeometry(0.42,2.7,0.16),new THREE.MeshPhongMaterial({color:0x111827})); r.rotation.x=Math.PI/3; r.position.set(1.0,1.7,0.9); g.add(r); }
if (P.heroId===8) { const wm=new THREE.MeshPhongMaterial({color:0x7dd3fc,transparent:true,opacity:0.75}); const wl=new THREE.Mesh(new THREE.ConeGeometry(0.95,2.5,3),wm); wl.position.set(-0.9,2.3,-0.55); wl.rotation.set(-0.3,0,0.8); const wr=wl.clone(); wr.position.x=0.9; wr.rotation.z=-0.8; g.add(wl,wr); }
if (P.heroId===10) { const orb=new THREE.Mesh(new THREE.SphereGeometry(0.45,10,10),new THREE.MeshPhongMaterial({color:0xf59e0b,emissive:0xfde047,emissiveIntensity:0.5})); orb.position.set(1.25,2.5,0.6); g.add(orb); }
scene.add(g);"""
    p = p.replace("scene.add(g);", p_props)
    with open("app/src/main/assets/hero_preview.html", "w") as f:
        f.write(p)

print("PART12_OK")
PYEOF
