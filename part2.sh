cat > app/src/main/java/com/mlbbultimate/moba/HeroRegistry.java << 'EOF'
package com.mlbbultimate.moba;
import android.graphics.Color;
import java.util.ArrayList;
import java.util.List;

public class HeroRegistry {
    public static class Skin {
        public final String tier, name;
        public final int primaryColor, accentColor, effectColor;
        public Skin(String t, String n, int p, int a, int e) { tier=t; name=n; primaryColor=p; accentColor=a; effectColor=e; }
    }
    public static class Hero {
        public final int id;
        public final String name, title, role, s1, s2, s3, ult;
        public final float maxHp, atk, speed, range;
        public final List<Skin> skins = new ArrayList<>();
        public Hero(int id, String n, String t, String r, float hp, float a, float sp, float rg, String s1, String s2, String s3, String u) {
            this.id=id; name=n; title=t; role=r; maxHp=hp; atk=a; speed=sp; range=rg; this.s1=s1; this.s2=s2; this.s3=s3; ult=u;
        }
    }
    private static final List<Hero> HEROES = new ArrayList<>();
    static {
        Hero h0 = new Hero(0,"Aegis","Iron Bastion","Tank",1650,72,235,115,"Shield Slam","Titan Dash","Seismic Stun","Bastion Fortress");
        h0.skins.add(new Skin("Basic","Steel Guard",Color.parseColor("#64748B"),Color.parseColor("#CBD5E1"),Color.parseColor("#94A3B8")));
        h0.skins.add(new Skin("Elite","Cobalt Warden",Color.parseColor("#1D4ED8"),Color.parseColor("#60A5FA"),Color.parseColor("#38BDF8")));
        h0.skins.add(new Skin("Special","Magma Colossus",Color.parseColor("#B91C1C"),Color.parseColor("#FB923C"),Color.parseColor("#F97316")));
        h0.skins.add(new Skin("Epic","Cyber Mecha",Color.parseColor("#0F766E"),Color.parseColor("#2DD4BF"),Color.parseColor("#5EEAD4")));
        h0.skins.add(new Skin("Legendary","Celestial Emperor",Color.parseColor("#B45309"),Color.parseColor("#FDE047"),Color.parseColor("#FEF08A")));

        Hero h1 = new Hero(1,"Kaelen","Crimson Blade","Fighter",1250,108,265,125,"Blade Arc","Phantom Step","Whirlwind Cut","Dragon Execution");
        h1.skins.add(new Skin("Basic","Ronin Initiate",Color.parseColor("#DC2626"),Color.parseColor("#FCA5A5"),Color.parseColor("#F87171")));
        h1.skins.add(new Skin("Elite","Azure Duelist",Color.parseColor("#0284C7"),Color.parseColor("#7DD3FC"),Color.parseColor("#38BDF8")));
        h1.skins.add(new Skin("Special","Venom Striker",Color.parseColor("#15803D"),Color.parseColor("#86EFAC"),Color.parseColor("#4ADE80")));
        h1.skins.add(new Skin("Epic","Abyssal Warlord",Color.parseColor("#7E22CE"),Color.parseColor("#E879F9"),Color.parseColor("#C084FC")));
        h1.skins.add(new Skin("Legendary","Solar Sovereign",Color.parseColor("#D97706"),Color.parseColor("#FDE047"),Color.parseColor("#FACC15")));

        Hero h2 = new Hero(2,"Vexia","Shadow Fang","Assassin",980,132,305,120,"Shadow Kunai","Blink Strike","Nightmare Mark","Phantom Dance");
        h2.skins.add(new Skin("Basic","Night Stalker",Color.parseColor("#4338CA"),Color.parseColor("#A5B4FC"),Color.parseColor("#818CF8")));
        h2.skins.add(new Skin("Elite","Blood Lotus",Color.parseColor("#BE123C"),Color.parseColor("#FDA4AF"),Color.parseColor("#FB7185")));
        h2.skins.add(new Skin("Special","Neon Viper",Color.parseColor("#059669"),Color.parseColor("#34D399"),Color.parseColor("#6EE7B7")));
        h2.skins.add(new Skin("Epic","Void Reaper",Color.parseColor("#6B21A8"),Color.parseColor("#F0ABFC"),Color.parseColor("#D946EF")));
        h2.skins.add(new Skin("Legendary","Quantum Nova",Color.parseColor("#0369A1"),Color.parseColor("#22D3EE"),Color.parseColor("#FDE047")));

        Hero h3 = new Hero(3,"Lyra","Astral Weaver","Mage",940,124,250,290,"Star Bolt","Astral Shift","Gravity Nova","Meteor Apocalypse");
        h3.skins.add(new Skin("Basic","Arcane Apprentice",Color.parseColor("#2563EB"),Color.parseColor("#93C5FD"),Color.parseColor("#60A5FA")));
        h3.skins.add(new Skin("Elite","Frost Enchantress",Color.parseColor("#0891B2"),Color.parseColor("#A5F3FC"),Color.parseColor("#22D3EE")));
        h3.skins.add(new Skin("Special","Sakura Mystic",Color.parseColor("#DB2777"),Color.parseColor("#FBCFE8"),Color.parseColor("#F472B6")));
        h3.skins.add(new Skin("Epic","Cosmic Empress",Color.parseColor("#581C87"),Color.parseColor("#C084FC"),Color.parseColor("#A855F7")));
        h3.skins.add(new Skin("Legendary","Galaxy Phoenix",Color.parseColor("#C2410C"),Color.parseColor("#FDE047"),Color.parseColor("#FB7185")));

        Hero h4 = new Hero(4,"Orion","Starlight Ranger","Marksman",920,136,260,330,"Piercing Arrow","Tactical Roll","Frost Trap","Supernova Volley");
        h4.skins.add(new Skin("Basic","Forest Scout",Color.parseColor("#16A34A"),Color.parseColor("#BBF7D0"),Color.parseColor("#4ADE80")));
        h4.skins.add(new Skin("Elite","Golden Marksman",Color.parseColor("#CA8A04"),Color.parseColor("#FEF08A"),Color.parseColor("#FACC15")));
        h4.skins.add(new Skin("Special","Cyber Sniper",Color.parseColor("#0284C7"),Color.parseColor("#22D3EE"),Color.parseColor("#38BDF8")));
        h4.skins.add(new Skin("Epic","Inferno Hunter",Color.parseColor("#DC2626"),Color.parseColor("#FDBA74"),Color.parseColor("#F97316")));
        h4.skins.add(new Skin("Legendary","Mecha Overlord",Color.parseColor("#4F46E5"),Color.parseColor("#FDE047"),Color.parseColor("#22D3EE")));

        Hero h5 = new Hero(5,"Seraph","Dawnlight Oracle","Support",1180,82,255,250,"Light Pulse","Radiant Blessing","Holy Bind","Sanctuary Revival");
        h5.skins.add(new Skin("Basic","Temple Healer",Color.parseColor("#0D9488"),Color.parseColor("#99F6E4"),Color.parseColor("#2DD4BF")));
        h5.skins.add(new Skin("Elite","Moonlight Priestess",Color.parseColor("#6366F1"),Color.parseColor("#E0E7FF"),Color.parseColor("#A5B4FC")));
        h5.skins.add(new Skin("Special","Spring Blossom",Color.parseColor("#EC4899"),Color.parseColor("#FCE7F3"),Color.parseColor("#F9A8D4")));
        h5.skins.add(new Skin("Epic","Valkyrie Angel",Color.parseColor("#D97706"),Color.parseColor("#FEF3C7"),Color.parseColor("#FBBF24")));
        h5.skins.add(new Skin("Legendary","Eternal Seraphim",Color.parseColor("#7C3AED"),Color.parseColor("#FDE047"),Color.parseColor("#38BDF8")));

        HEROES.add(h0); HEROES.add(h1); HEROES.add(h2); HEROES.add(h3); HEROES.add(h4); HEROES.add(h5);
    }
    public static List<Hero> getHeroes() { return HEROES; }
    public static Hero getHero(int id) { return (id < 0 || id >= HEROES.size()) ? HEROES.get(1) : HEROES.get(id); }
}
EOF

cat > app/src/main/java/com/mlbbultimate/moba/HeroSelectActivity.java << 'EOF'
package com.mlbbultimate.moba;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

public class HeroSelectActivity extends Activity {
    private EconomyManager eco;
    private LinearLayout skinBox, spellRow;
    private TextView previewText;

    @Override protected void onCreate(Bundle b) {
        super.onCreate(b);
        eco = new EconomyManager(this);
        LinearLayout root = new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(Color.parseColor("#080E21")); root.setPadding(24, 16, 24, 16);
        TextView top = new TextView(this);
        top.setText("5v5 MATCHMAKING READY  |  CHOOSE HERO, SKIN & BATTLE SPELL");
        top.setTextColor(Color.parseColor("#FACC15")); top.setTextSize(17);
        top.setTypeface(Typeface.DEFAULT_BOLD); top.setPadding(0, 0, 0, 12);
        root.addView(top);

        LinearLayout mid = new LinearLayout(this); mid.setOrientation(LinearLayout.HORIZONTAL);
        mid.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f));
        ScrollView hs = new ScrollView(this);
        hs.setLayoutParams(new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f));
        LinearLayout hCol = new LinearLayout(this); hCol.setOrientation(LinearLayout.VERTICAL);
        for (HeroRegistry.Hero h : HeroRegistry.getHeroes()) {
            Button btn = new Button(this); btn.setText(h.name + " (" + h.role + ")");
            btn.setTextColor(Color.WHITE); btn.setAllCaps(false);
            btn.setBackground(boxBg(Color.parseColor("#172554"), Color.parseColor("#38BDF8")));
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            lp.bottomMargin = 8; btn.setLayoutParams(lp);
            btn.setOnClickListener(v -> { eco.setSelectedHeroId(h.id); refreshPreview(); });
            hCol.addView(btn);
        }
        hs.addView(hCol);

        LinearLayout right = new LinearLayout(this); right.setOrientation(LinearLayout.VERTICAL);
        right.setLayoutParams(new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1.5f)); right.setPadding(20, 0, 0, 0);
        previewText = new TextView(this); previewText.setTextColor(Color.WHITE); previewText.setTextSize(14); previewText.setPadding(0, 0, 0, 10);
        skinBox = new LinearLayout(this); skinBox.setOrientation(LinearLayout.VERTICAL);
        spellRow = new LinearLayout(this); spellRow.setOrientation(LinearLayout.HORIZONTAL); spellRow.setPadding(0, 10, 0, 10);
        Button start = new Button(this); start.setText("START 5v5 AI BATTLE"); start.setTextColor(Color.BLACK);
        start.setTypeface(Typeface.DEFAULT_BOLD); start.setTextSize(16);
        start.setBackground(boxBg(Color.parseColor("#F59E0B"), Color.parseColor("#FDE047")));
        start.setOnClickListener(v -> { startActivity(new Intent(this, BattleActivity.class)); finish(); });
        right.addView(previewText); right.addView(skinBox); right.addView(spellRow); right.addView(start);
        mid.addView(hs); mid.addView(right); root.addView(mid);
        setContentView(root); refreshPreview();
    }

    private GradientDrawable boxBg(int fill, int stroke) {
        GradientDrawable d = new GradientDrawable(); d.setColor(fill); d.setCornerRadius(14); d.setStroke(2, stroke); return d;
    }

    private void refreshPreview() {
        HeroRegistry.Hero h = HeroRegistry.getHero(eco.getSelectedHeroId());
        int eq = eco.getEquippedSkinTier(h.id);
        HeroRegistry.Skin sk = h.skins.get(eq);
        previewText.setText("Selected: " + h.name + " [" + h.role + "] | Skin: [" + sk.tier + "] " + sk.name
            + "\nSkills: " + h.s1 + " / " + h.s2 + " / " + h.s3 + " / ULT: " + h.ult);
        skinBox.removeAllViews();
        for (int i = 0; i < h.skins.size(); i++) {
            final int idx = i; HeroRegistry.Skin s = h.skins.get(i);
            Button b = new Button(this); b.setText((idx == eq ? "[EQUIPPED] " : "") + "[" + s.tier + "] " + s.name);
            b.setTextColor(Color.WHITE); b.setAllCaps(false);
            b.setBackground(boxBg(s.primaryColor, idx == eq ? Color.YELLOW : s.accentColor));
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 74);
            lp.bottomMargin = 6; b.setLayoutParams(lp);
            b.setOnClickListener(v -> { eco.setEquippedSkinTier(h.id, idx); refreshPreview(); });
            skinBox.addView(b);
        }
        spellRow.removeAllViews();
        for (String sp : new String[]{"Execute","Flicker","Healing","Inspire"}) {
            boolean active = eco.getSelectedSpell().equals(sp);
            Button b = new Button(this); b.setText(sp); b.setAllCaps(false);
            b.setTextColor(active ? Color.BLACK : Color.WHITE);
            b.setBackground(boxBg(active ? Color.parseColor("#38BDF8") : Color.parseColor("#1E293B"), Color.WHITE));
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f);
            lp.rightMargin = 6; b.setLayoutParams(lp);
            b.setOnClickListener(v -> { eco.setSelectedSpell(sp); refreshPreview(); });
            spellRow.addView(b);
        }
    }
}
EOF

cat > app/src/main/java/com/mlbbultimate/moba/BattleActivity.java << 'EOF'
package com.mlbbultimate.moba;
import android.app.Activity;
import android.os.Bundle;
public class BattleActivity extends Activity {
    private ArenaView arenaView;
    @Override protected void onCreate(Bundle b) { super.onCreate(b); arenaView = new ArenaView(this); setContentView(arenaView); }
    @Override protected void onResume() { super.onResume(); arenaView.resume(); }
    @Override protected void onPause() { super.onPause(); arenaView.pause(); }
}
EOF
echo "PART2_OK"
