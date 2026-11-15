cat > app/src/main/assets/hero_preview.html << 'EOF'
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><style>html,body,#c{margin:0;width:100%;height:100%;overflow:hidden;background:transparent;touch-action:none}</style></head>
<body><canvas id="c"></canvas><script src="three.min.js"></script><script>
const P = (typeof AndroidBridge !== 'undefined') ? JSON.parse(AndroidBridge.getPreviewConfig()) : { heroId:1, primary:'#D97706', accent:'#FDE047' };
const canvas = document.getElementById('c');
const renderer = new THREE.WebGLRenderer({ canvas, alpha:true, antialias:true });
renderer.setSize(window.innerWidth, window.innerHeight);
const scene = new THREE.Scene(), camera = new THREE.PerspectiveCamera(40, window.innerWidth/window.innerHeight, 0.5, 50);
camera.position.set(0, 2.7, 6.2); camera.lookAt(0, 1.7, 0);
scene.add(new THREE.HemisphereLight(0x93c5fd, 0x0f172a, 1.2));
const dl = new THREE.DirectionalLight(0xfffbeb, 1.3); dl.position.set(4, 7, 5); scene.add(dl);

const ped = new THREE.Mesh(new THREE.CylinderGeometry(1.75, 2.0, 0.32, 24), new THREE.MeshPhongMaterial({ color:0x1e293b, shininess:60 }));
const pedRing = new THREE.Mesh(new THREE.RingGeometry(1.55, 1.72, 32), new THREE.MeshBasicMaterial({ color:P.accent, side:THREE.DoubleSide }));
pedRing.rotation.x = -Math.PI/2; pedRing.position.y = 0.18;
scene.add(ped, pedRing);

const g = new THREE.Group();
const matP = new THREE.MeshPhongMaterial({ color:P.primary, shininess:60 });
const matA = new THREE.MeshPhongMaterial({ color:P.accent, shininess:90, emissive:P.accent, emissiveIntensity:0.25 });
const legCol = P.heroId === 6 ? new THREE.MeshLambertMaterial({ color:0x1e293b }) : matP;
const legL = new THREE.Mesh(new THREE.BoxGeometry(0.45,1.1,0.45), legCol); legL.position.set(-0.32,0.7,0);
const legR = new THREE.Mesh(new THREE.BoxGeometry(0.45,1.1,0.45), legCol); legR.position.set(0.32,0.7,0);
const torso = new THREE.Mesh(new THREE.BoxGeometry(1.25,1.35,0.72), matP); torso.position.y = 1.9;
const chest = new THREE.Mesh(new THREE.BoxGeometry(1.32,0.45,0.8), matA); chest.position.y = 2.2;
const cape = new THREE.Mesh(new THREE.BoxGeometry(1.15,1.65,0.12), matA); cape.position.set(0,1.75,-0.48); cape.rotation.x = 0.28;
const head = new THREE.Mesh(new THREE.SphereGeometry(0.48,14,12), new THREE.MeshLambertMaterial({ color:0xfde68a })); head.position.y = 3.0;
const shL = new THREE.Mesh(new THREE.SphereGeometry(0.36,8,8), matA); shL.position.set(-0.82,2.5,0);
const shR = new THREE.Mesh(new THREE.SphereGeometry(0.36,8,8), matA); shR.position.set(0.82,2.5,0);
const armL = new THREE.Mesh(new THREE.BoxGeometry(0.34,1.0,0.34), matP); armL.position.set(-0.82,1.9,0);
const armR = new THREE.Mesh(new THREE.BoxGeometry(0.34,1.0,0.34), matP); armR.position.set(0.82,1.9,0);
g.add(legL,legR,torso,chest,cape,head,shL,shR,armL,armR);

if (P.heroId === 6) {
  const hm = new THREE.MeshLambertMaterial({ color:0xfde047 });
  const hTop = new THREE.Mesh(new THREE.BoxGeometry(0.92,0.4,0.92), hm); hTop.position.y = 3.38;
  const blade = new THREE.Mesh(new THREE.BoxGeometry(0.12,2.5,0.22), new THREE.MeshPhongMaterial({ color:0xfacc15, emissive:0xf59e0b, emissiveIntensity:0.45 }));
  blade.rotation.x = Math.PI/3; blade.position.set(0.9, 1.7, 0.9);
  g.add(hTop, blade);
} else {
  const helm = new THREE.Mesh(new THREE.ConeGeometry(0.55,0.65,6), matA); helm.position.y = 3.4;
  const wpn = new THREE.Mesh(P.heroId===0 ? new THREE.BoxGeometry(0.3,1.5,1.1) : P.heroId===4 ? new THREE.TorusGeometry(0.75,0.09,6,12,Math.PI) : new THREE.BoxGeometry(0.14,2.1,0.26), matA);
  wpn.position.set(0.95, 1.8, 0.7); wpn.rotation.x = Math.PI/3;
  g.add(helm, wpn);
}
scene.add(g);

let drag = false, lastX = 0, rotY = 0.3;
canvas.addEventListener('touchstart', e => { drag = true; lastX = e.touches[0].clientX; });
canvas.addEventListener('touchmove', e => { if (drag) { rotY += (e.touches[0].clientX - lastX) * 0.015; lastX = e.touches[0].clientX; } });
canvas.addEventListener('touchend', () => drag = false);
function anim() { requestAnimationFrame(anim); if (!drag) rotY += 0.012; g.rotation.y = rotY; pedRing.rotation.z -= 0.01; renderer.render(scene, camera); }
anim();
</script></body></html>
EOF

python3 - << 'PYEOF'
with open("app/src/main/java/com/mlbbultimate/moba/MainLobbyActivity.java", "r") as f:
    s = f.read()

s = s.replace("import java.util.List;",
    "import java.util.List;\nimport android.view.View;\nimport android.webkit.JavascriptInterface;\nimport android.webkit.WebSettings;\nimport android.webkit.WebView;\nimport org.json.JSONObject;")
s = s.replace('private String activeTab = "LOBBY";', 'private String activeTab = "LOBBY", roleFilter = "ALL";')

old_lobby = """        if (tab.equals("LOBBY")) {
            LinearLayout banner = new LinearLayout(this); banner.setOrientation(LinearLayout.VERTICAL);
            banner.setBackground(cardBg(Color.parseColor("#132043"), Color.parseColor("#F59E0B"))); banner.setPadding(28, 24, 28, 24);
            TextView hTitle = new TextView(this);
            hTitle.setText("ACTIVE HERO: " + curHero.name.toUpperCase() + " (" + curHero.role + ") - Lv." + eco.getHeroLevel(curHero.id));
            hTitle.setTextColor(Color.parseColor("#FDE047")); hTitle.setTextSize(20); hTitle.setTypeface(Typeface.DEFAULT_BOLD);
            TextView sTitle = new TextView(this);
            sTitle.setText("Equipped Skin: [" + curSkin.tier + "] " + curSkin.name + " | Spell: " + eco.getSelectedSpell() + " | Recall: " + eco.getRecallEffect());
            sTitle.setTextColor(Color.parseColor("#38BDF8")); sTitle.setTextSize(14); sTitle.setPadding(0, 8, 0, 16);
            TextView skills = new TextView(this);
            skills.setText("Skills: " + curHero.s1 + " | " + curHero.s2 + " | " + curHero.s3 + " | ULT: " + curHero.ult);
            skills.setTextColor(Color.parseColor("#CBD5E1")); skills.setPadding(0, 0, 0, 20);
            Button battleBtn = makeBtn("ENTER 5v5 BATTLE ARENA", Color.parseColor("#D97706"), Color.parseColor("#FDE047"), Color.BLACK);
            battleBtn.setTextSize(18);
            battleBtn.setOnClickListener(v -> startActivity(new Intent(this, HeroSelectActivity.class)));
            banner.addView(hTitle); banner.addView(sTitle); banner.addView(skills); banner.addView(battleBtn);
            contentPanel.addView(banner);
            TextView info = new TextView(this);
            info.setText("\\nOffline Mode Active: All 6 Heroes & 30 Skins Unlocked.\\nRecord: " + eco.getWins() + " Wins / " + eco.getTotalMatches() + " Matches.");
            info.setTextColor(Color.parseColor("#94A3B8")); contentPanel.addView(info);
        } else if (tab.equals("HEROES")) {
            for (HeroRegistry.Hero h : HeroRegistry.getHeroes()) {"""

new_lobby = """        if (tab.equals("LOBBY")) {
            LinearLayout split = new LinearLayout(this); split.setOrientation(LinearLayout.HORIZONTAL);
            int hPx = Math.max(360, getResources().getDisplayMetrics().heightPixels - 170);
            WebView wv = new WebView(this); wv.setBackgroundColor(Color.TRANSPARENT); wv.setLayerType(View.LAYER_TYPE_HARDWARE, null);
            WebSettings ws = wv.getSettings(); ws.setJavaScriptEnabled(true); ws.setAllowFileAccess(true); ws.setAllowFileAccessFromFileURLs(true);
            wv.addJavascriptInterface(new PreviewBridge(), "AndroidBridge");
            wv.setLayoutParams(new LinearLayout.LayoutParams(0, hPx, 1f));
            wv.loadUrl("file:///android_asset/hero_preview.html");

            LinearLayout banner = new LinearLayout(this); banner.setOrientation(LinearLayout.VERTICAL);
            banner.setBackground(cardBg(Color.parseColor("#132043"), Color.parseColor("#F59E0B"))); banner.setPadding(24, 20, 24, 20);
            banner.setLayoutParams(new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1.25f));
            TextView hTitle = new TextView(this);
            hTitle.setText(curHero.name.toUpperCase() + " [" + curHero.role + "] - Lv." + eco.getHeroLevel(curHero.id));
            hTitle.setTextColor(Color.parseColor("#FDE047")); hTitle.setTextSize(20); hTitle.setTypeface(Typeface.DEFAULT_BOLD);
            TextView sTitle = new TextView(this);
            sTitle.setText("Skin: [" + curSkin.tier + "] " + curSkin.name + "\\nSpell: " + eco.getSelectedSpell() + " | Recall: " + eco.getRecallEffect());
            sTitle.setTextColor(Color.parseColor("#38BDF8")); sTitle.setTextSize(13); sTitle.setPadding(0, 8, 0, 12);
            TextView skills = new TextView(this);
            skills.setText("Skills: " + curHero.s1 + " | " + curHero.s2 + " | " + curHero.s3 + " | ULT: " + curHero.ult
                + "\\nRecord: " + eco.getWins() + " Wins / " + eco.getTotalMatches() + " Matches");
            skills.setTextColor(Color.parseColor("#CBD5E1")); skills.setPadding(0, 0, 0, 16);
            Button battleBtn = makeBtn("ENTER 5v5 BATTLE ARENA", Color.parseColor("#D97706"), Color.parseColor("#FDE047"), Color.BLACK);
            battleBtn.setTextSize(17);
            battleBtn.setOnClickListener(v -> startActivity(new Intent(this, HeroSelectActivity.class)));
            banner.addView(hTitle); banner.addView(sTitle); banner.addView(skills); banner.addView(battleBtn);
            split.addView(wv); split.addView(banner);
            contentPanel.addView(split);
        } else if (tab.equals("HEROES")) {
            LinearLayout fRow = new LinearLayout(this); fRow.setOrientation(LinearLayout.HORIZONTAL); fRow.setPadding(0,0,0,12);
            for (String r : new String[]{"ALL","Tank","Fighter","Assassin","Mage","Marksman","Support"}) {
                Button fb = makeBtn(r, roleFilter.equals(r) ? Color.parseColor("#F59E0B") : Color.parseColor("#1E293B"),
                    Color.parseColor("#38BDF8"), roleFilter.equals(r) ? Color.BLACK : Color.WHITE);
                fb.setTextSize(11); fb.setPadding(12, 6, 12, 6);
                LinearLayout.LayoutParams flp = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f);
                flp.rightMargin = 6; fb.setLayoutParams(flp);
                fb.setOnClickListener(v -> { roleFilter = r; renderTab("HEROES"); });
                fRow.addView(fb);
            }
            contentPanel.addView(fRow);
            for (HeroRegistry.Hero h : HeroRegistry.getHeroes()) {
                if (!roleFilter.equals("ALL") && !h.role.equals(roleFilter)) continue;"""

s = s.replace(old_lobby, new_lobby)
bridge_cls = """
    public class PreviewBridge {
        @JavascriptInterface public String getPreviewConfig() {
            try {
                HeroRegistry.Hero h = HeroRegistry.getHero(eco.getSelectedHeroId());
                HeroRegistry.Skin sk = h.skins.get(eco.getEquippedSkinTier(h.id));
                JSONObject o = new JSONObject(); o.put("heroId", h.id);
                o.put("primary", String.format("#%06X", 0xFFFFFF & sk.primaryColor));
                o.put("accent", String.format("#%06X", 0xFFFFFF & sk.accentColor));
                return o.toString();
            } catch (Exception e) { return "{\\"heroId\\":1,\\"primary\\":\\"#D97706\\",\\"accent\\":\\"#FDE047\\"}"; }
        }
    }
}"""
s = s.rstrip()[:-1] + bridge_cls
with open("app/src/main/java/com/mlbbultimate/moba/MainLobbyActivity.java", "w") as f:
    f.write(s)
print("PART11_OK")
PYEOF
