cat > app/src/main/java/com/mlbbultimate/moba/MainLobbyActivity.java << 'EOF'
package com.mlbbultimate.moba;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;
import java.util.List;

public class MainLobbyActivity extends Activity {
    private EconomyManager eco;
    private TextView topCurrencies;
    private LinearLayout contentPanel;
    private String activeTab = "LOBBY";

    @Override protected void onCreate(Bundle b) { super.onCreate(b); eco = new EconomyManager(this); buildRootUi(); }
    @Override protected void onResume() { super.onResume(); refreshHeader(); renderTab(activeTab); }

    private GradientDrawable cardBg(int fill, int stroke) {
        GradientDrawable d = new GradientDrawable(); d.setColor(fill); d.setCornerRadius(18); d.setStroke(2, stroke); return d;
    }
    private Button makeBtn(String text, int bg, int stroke, int txtColor) {
        Button b = new Button(this); b.setText(text); b.setTextColor(txtColor); b.setAllCaps(false);
        b.setTypeface(Typeface.DEFAULT_BOLD); b.setBackground(cardBg(bg, stroke)); b.setPadding(22, 12, 22, 12);
        return b;
    }

    private void buildRootUi() {
        LinearLayout root = new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL);
        root.setBackground(new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM,
            new int[]{Color.parseColor("#070D1F"), Color.parseColor("#111C3A")}));
        LinearLayout topBar = new LinearLayout(this); topBar.setOrientation(LinearLayout.HORIZONTAL);
        topBar.setGravity(Gravity.CENTER_VERTICAL); topBar.setBackgroundColor(Color.parseColor("#0D152C")); topBar.setPadding(24, 14, 24, 14);
        topCurrencies = new TextView(this); topCurrencies.setTextColor(Color.WHITE); topCurrencies.setTextSize(13);
        topCurrencies.setTypeface(Typeface.DEFAULT_BOLD);
        topCurrencies.setLayoutParams(new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f));
        Button settingsBtn = makeBtn("Settings", Color.parseColor("#1E293B"), Color.parseColor("#38BDF8"), Color.WHITE);
        settingsBtn.setOnClickListener(v -> showSettingsDialog());
        topBar.addView(topCurrencies); topBar.addView(settingsBtn);

        LinearLayout body = new LinearLayout(this); body.setOrientation(LinearLayout.HORIZONTAL);
        body.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f));
        ScrollView navScroll = new ScrollView(this);
        navScroll.setLayoutParams(new LinearLayout.LayoutParams(250, LinearLayout.LayoutParams.MATCH_PARENT));
        navScroll.setBackgroundColor(Color.parseColor("#0A1226"));
        LinearLayout navCol = new LinearLayout(this); navCol.setOrientation(LinearLayout.VERTICAL); navCol.setPadding(14, 14, 14, 14);
        for (String t : new String[]{"LOBBY","HEROES","SKINS","SHOP","INVENTORY","EVENTS","HISTORY","PROFILE"}) {
            Button b = makeBtn(t, Color.parseColor("#162244"), Color.parseColor("#334155"), Color.parseColor("#E2E8F0"));
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            lp.bottomMargin = 10; b.setLayoutParams(lp);
            b.setOnClickListener(v -> { activeTab = t; renderTab(t); });
            navCol.addView(b);
        }
        navScroll.addView(navCol);
        ScrollView contentScroll = new ScrollView(this);
        contentScroll.setLayoutParams(new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f));
        contentPanel = new LinearLayout(this); contentPanel.setOrientation(LinearLayout.VERTICAL); contentPanel.setPadding(24, 20, 24, 20);
        contentScroll.addView(contentPanel);
        body.addView(navScroll); body.addView(contentScroll);
        root.addView(topBar); root.addView(body);
        setContentView(root); refreshHeader(); renderTab("LOBBY");
    }

    private void refreshHeader() {
        topCurrencies.setText(eco.getPlayerName() + " | Diamonds: " + eco.getDiamonds()
            + " | Coins: " + eco.getCoins() + " | Tickets: " + eco.getTickets() + " | SkinPts: " + eco.getSkinPoints());
    }

    private void renderTab(String tab) {
        contentPanel.removeAllViews();
        HeroRegistry.Hero curHero = HeroRegistry.getHero(eco.getSelectedHeroId());
        HeroRegistry.Skin curSkin = curHero.skins.get(eco.getEquippedSkinTier(curHero.id));

        if (tab.equals("LOBBY")) {
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
            info.setText("\nOffline Mode Active: All 6 Heroes & 30 Skins Unlocked.\nRecord: " + eco.getWins() + " Wins / " + eco.getTotalMatches() + " Matches.");
            info.setTextColor(Color.parseColor("#94A3B8")); contentPanel.addView(info);
        } else if (tab.equals("HEROES")) {
            for (HeroRegistry.Hero h : HeroRegistry.getHeroes()) {
                LinearLayout row = new LinearLayout(this); row.setOrientation(LinearLayout.VERTICAL);
                row.setBackground(cardBg(Color.parseColor("#131F3F"), Color.parseColor("#38BDF8"))); row.setPadding(20, 16, 20, 16);
                LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
                lp.bottomMargin = 12; row.setLayoutParams(lp);
                int lv = eco.getHeroLevel(h.id);
                TextView t = new TextView(this); t.setText(h.name + " - " + h.title + " [" + h.role + "] (Lv." + lv + ")");
                t.setTextColor(Color.parseColor("#FDE047")); t.setTextSize(16); t.setTypeface(Typeface.DEFAULT_BOLD);
                TextView st = new TextView(this); st.setText("HP: " + (int)(h.maxHp + lv * 50) + " | ATK: " + (int)(h.atk + lv * 8));
                st.setTextColor(Color.parseColor("#CBD5E1")); st.setPadding(0, 6, 0, 10);
                LinearLayout btns = new LinearLayout(this);
                Button sel = makeBtn(eco.getSelectedHeroId() == h.id ? "Selected" : "Select Hero", Color.parseColor("#0284C7"), Color.WHITE, Color.WHITE);
                sel.setOnClickListener(v -> { eco.setSelectedHeroId(h.id); renderTab("HEROES"); });
                Button upg = makeBtn("Free Upgrade (0 Coins)", Color.parseColor("#16A34A"), Color.WHITE, Color.WHITE);
                LinearLayout.LayoutParams upgLp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
                upgLp.leftMargin = 14; upg.setLayoutParams(upgLp);
                upg.setOnClickListener(v -> { eco.upgradeHero(h.id); renderTab("HEROES"); });
                btns.addView(sel); btns.addView(upg); row.addView(t); row.addView(st); row.addView(btns);
                contentPanel.addView(row);
            }
        } else if (tab.equals("SKINS")) {
            for (int i = 0; i < curHero.skins.size(); i++) {
                final int tierIdx = i; HeroRegistry.Skin sk = curHero.skins.get(i);
                LinearLayout card = new LinearLayout(this); card.setOrientation(LinearLayout.HORIZONTAL); card.setGravity(Gravity.CENTER_VERTICAL);
                card.setBackground(cardBg(sk.primaryColor, sk.accentColor)); card.setPadding(20, 14, 20, 14);
                LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
                lp.bottomMargin = 10; card.setLayoutParams(lp);
                TextView tv = new TextView(this); tv.setText("[" + sk.tier + "] " + sk.name + " (Unlocked)");
                tv.setTextColor(Color.WHITE); tv.setTypeface(Typeface.DEFAULT_BOLD);
                tv.setLayoutParams(new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f));
                Button eqBtn = makeBtn(eco.getEquippedSkinTier(curHero.id) == tierIdx ? "EQUIPPED" : "EQUIP", Color.parseColor("#0F172A"), Color.WHITE, Color.WHITE);
                eqBtn.setOnClickListener(v -> { eco.setEquippedSkinTier(curHero.id, tierIdx); renderTab("SKINS"); });
                card.addView(tv); card.addView(eqBtn); contentPanel.addView(card);
            }
        } else if (tab.equals("SHOP")) {
            Button refill = makeBtn("Refill 999,999,999 All Currencies", Color.parseColor("#D97706"), Color.WHITE, Color.BLACK);
            refill.setOnClickListener(v -> { eco.refillUnlimited(); refreshHeader(); Toast.makeText(this, "Currencies maxed!", Toast.LENGTH_SHORT).show(); });
            contentPanel.addView(refill);
            for (HeroRegistry.Hero h : HeroRegistry.getHeroes()) {
                Button claim = makeBtn("Equip " + h.name + " Legendary Bundle (0 Diamonds)", Color.parseColor("#1E293B"), Color.parseColor("#38BDF8"), Color.WHITE);
                LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
                lp.topMargin = 10; claim.setLayoutParams(lp);
                claim.setOnClickListener(v -> { eco.setSelectedHeroId(h.id); eco.setEquippedSkinTier(h.id, 4); Toast.makeText(this, h.name + " equipped!", Toast.LENGTH_SHORT).show(); });
                contentPanel.addView(claim);
            }
        } else if (tab.equals("INVENTORY")) {
            for (String r : new String[]{"Royal Gold Recall","Cyber Pulse Recall","Starlight Lotus Recall","Abyssal Dragon Recall"}) {
                Button b = makeBtn((eco.getRecallEffect().equals(r) ? "[ACTIVE] " : "") + r, Color.parseColor("#1E293B"), Color.parseColor("#F59E0B"), Color.WHITE);
                LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
                lp.bottomMargin = 10; b.setLayoutParams(lp);
                b.setOnClickListener(v -> { eco.setRecallEffect(r); renderTab("INVENTORY"); });
                contentPanel.addView(b);
            }
        } else if (tab.equals("EVENTS")) {
            String[][] evts = {{"evt1","All Heroes & Legendary Skins Unlocked"},{"evt2","999,999,999 Unlimited Currencies"},{"evt3","AI Arena Mastery Pack"}};
            for (String[] e : evts) {
                boolean c = eco.isEventClaimed(e[0]);
                Button b = makeBtn((c ? "[CLAIMED] " : "[CLAIM FREE] ") + e[1], c ? Color.parseColor("#14532D") : Color.parseColor("#1D4ED8"), Color.WHITE, Color.WHITE);
                LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
                lp.bottomMargin = 12; b.setLayoutParams(lp);
                b.setOnClickListener(v -> { eco.claimEvent(e[0]); eco.refillUnlimited(); refreshHeader(); renderTab("EVENTS"); });
                contentPanel.addView(b);
            }
        } else if (tab.equals("HISTORY")) {
            List<String> lines = eco.getMatchHistoryLines();
            TextView tv = new TextView(this);
            if (lines.isEmpty()) tv.setText("No matches played yet. Tap LOBBY -> ENTER 5v5 BATTLE ARENA!");
            else {
                StringBuilder sb = new StringBuilder("RECENT 5v5 AI MATCHES:\n\n");
                for (String l : lines) sb.append(l).append("\n\n");
                tv.setText(sb.toString());
            }
            tv.setTextColor(Color.WHITE); contentPanel.addView(tv);
        } else if (tab.equals("PROFILE")) {
            TextView tv = new TextView(this);
            tv.setText("PLAYER PROFILE\nName: " + eco.getPlayerName() + "\nWins: " + eco.getWins()
                + " / Total Matches: " + eco.getTotalMatches() + "\nMain Hero: " + curHero.name);
            tv.setTextColor(Color.WHITE); tv.setTextSize(16); tv.setPadding(0, 0, 0, 16);
            contentPanel.addView(tv);
            Button rename = makeBtn("Change Player Name", Color.parseColor("#0284C7"), Color.WHITE, Color.WHITE);
            rename.setOnClickListener(v -> {
                EditText et = new EditText(this); et.setText(eco.getPlayerName());
                new AlertDialog.Builder(this).setTitle("Enter Player Name").setView(et)
                    .setPositiveButton("Save", (d, w) -> {
                        String n = et.getText().toString().trim();
                        if (!n.isEmpty()) eco.setPlayerName(n);
                        refreshHeader(); renderTab("PROFILE");
                    }).setNegativeButton("Cancel", null).show();
            });
            contentPanel.addView(rename);
        }
    }

    private void showSettingsDialog() {
        String[] opts = {"Graphics: Low (Best FPS)", "Graphics: Medium", "Graphics: High (Full Effects)"};
        new AlertDialog.Builder(this).setTitle("Arena Graphics Settings")
            .setSingleChoiceItems(opts, eco.getGraphicsQuality(), (d, w) -> {
                eco.setGraphicsQuality(w);
                Toast.makeText(this, "Saved: " + opts[w], Toast.LENGTH_SHORT).show();
                d.dismiss();
            }).setNegativeButton("Close", null).show();
    }
}
EOF
echo "PART3_OK"
