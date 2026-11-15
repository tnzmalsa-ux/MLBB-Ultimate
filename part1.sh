mkdir -p app/src/main/java/com/mlbbultimate/moba app/src/main/res/drawable app/src/main/res/values

cat > settings.gradle << 'EOF'
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories { google(); mavenCentral() }
}
rootProject.name = "MLBB_Ultimate"
include ':app'
EOF

cat > build.gradle << 'EOF'
plugins { id 'com.android.application' version '8.4.0' apply false }
EOF

cat > gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
EOF

cat > app/build.gradle << 'EOF'
plugins { id 'com.android.application' }
android {
    namespace 'com.mlbbultimate.moba'
    compileSdk 34
    defaultConfig {
        applicationId "com.mlbbultimate.moba"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
    buildTypes { release { minifyEnabled false } }
    compileOptions { sourceCompatibility JavaVersion.VERSION_17; targetCompatibility JavaVersion.VERSION_17 }
}
dependencies {}
EOF

cat > app/src/main/res/values/strings.xml << 'EOF'
<resources><string name="app_name">MLBB Ultimate</string></resources>
EOF

cat > app/src/main/res/drawable/ic_launcher.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#0B132B" android:pathData="M0,0h108v108h-108z"/>
    <path android:fillColor="#F59E0B" android:pathData="M54,14 L88,28 L88,57 C88,75 72,88 54,94 C36,88 20,75 20,57 L20,28 Z"/>
    <path android:fillColor="#0B132B" android:pathData="M54,22 L80,34 L80,56 C80,70 67,80 54,85 C41,80 28,70 28,56 L28,34 Z"/>
    <path android:fillColor="#38BDF8" android:pathData="M38,34 L72,68 L67,73 L33,39 Z"/>
    <path android:fillColor="#FDE047" android:pathData="M70,34 L36,68 L41,73 L75,39 Z"/>
</vector>
EOF

cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:allowBackup="true" android:icon="@drawable/ic_launcher"
        android:label="@string/app_name" android:theme="@android:style/Theme.NoTitleBar.Fullscreen">
        <activity android:name=".SplashActivity" android:exported="true" android:screenOrientation="sensorLandscape">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <activity android:name=".MainLobbyActivity" android:screenOrientation="sensorLandscape" />
        <activity android:name=".HeroSelectActivity" android:screenOrientation="sensorLandscape" />
        <activity android:name=".BattleActivity" android:screenOrientation="sensorLandscape" />
    </application>
</manifest>
EOF

cat > app/src/main/java/com/mlbbultimate/moba/EconomyManager.java << 'EOF'
package com.mlbbultimate.moba;
import android.content.Context;
import android.content.SharedPreferences;
import org.json.JSONArray;
import org.json.JSONObject;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class EconomyManager {
    private final SharedPreferences prefs;
    public EconomyManager(Context ctx) {
        prefs = ctx.getSharedPreferences("mlbb_ultimate_offline_db", Context.MODE_PRIVATE);
        if (!prefs.getBoolean("initialized", false)) {
            prefs.edit().putBoolean("initialized", true).putLong("diamonds", 999999999L)
                .putLong("coins", 999999999L).putLong("tickets", 999999999L)
                .putLong("skin_points", 999999999L).putString("player_name", "Commander")
                .putInt("selected_hero", 1).putString("selected_spell", "Execute")
                .putString("recall_effect", "Royal Gold Recall").putInt("gfx_quality", 2).apply();
        }
    }
    public long getDiamonds() { return prefs.getLong("diamonds", 999999999L); }
    public long getCoins() { return prefs.getLong("coins", 999999999L); }
    public long getTickets() { return prefs.getLong("tickets", 999999999L); }
    public long getSkinPoints() { return prefs.getLong("skin_points", 999999999L); }
    public void refillUnlimited() {
        prefs.edit().putLong("diamonds", 999999999L).putLong("coins", 999999999L)
            .putLong("tickets", 999999999L).putLong("skin_points", 999999999L).apply();
    }
    public String getPlayerName() { return prefs.getString("player_name", "Commander"); }
    public void setPlayerName(String name) { prefs.edit().putString("player_name", name).apply(); }
    public int getSelectedHeroId() { return prefs.getInt("selected_hero", 1); }
    public void setSelectedHeroId(int id) { prefs.edit().putInt("selected_hero", id).apply(); }
    public int getEquippedSkinTier(int heroId) { return prefs.getInt("skin_tier_" + heroId, 4); }
    public void setEquippedSkinTier(int heroId, int tier) { prefs.edit().putInt("skin_tier_" + heroId, tier).apply(); }
    public int getHeroLevel(int heroId) { return prefs.getInt("hero_lv_" + heroId, 1); }
    public void upgradeHero(int heroId) { prefs.edit().putInt("hero_lv_" + heroId, Math.min(15, getHeroLevel(heroId) + 1)).apply(); }
    public String getSelectedSpell() { return prefs.getString("selected_spell", "Execute"); }
    public void setSelectedSpell(String spell) { prefs.edit().putString("selected_spell", spell).apply(); }
    public String getRecallEffect() { return prefs.getString("recall_effect", "Royal Gold Recall"); }
    public void setRecallEffect(String effect) { prefs.edit().putString("recall_effect", effect).apply(); }
    public int getGraphicsQuality() { return prefs.getInt("gfx_quality", 2); }
    public void setGraphicsQuality(int q) { prefs.edit().putInt("gfx_quality", q).apply(); }
    public boolean isEventClaimed(String id) { return prefs.getBoolean("evt_" + id, false); }
    public void claimEvent(String id) { prefs.edit().putBoolean("evt_" + id, true).apply(); }
    public int getWins() { return prefs.getInt("wins", 0); }
    public int getTotalMatches() { return prefs.getInt("matches", 0); }
    public void addMatchRecord(String hero, String skin, boolean victory, int k, int d, int a) {
        try {
            JSONArray arr = new JSONArray(prefs.getString("history_json", "[]"));
            JSONObject obj = new JSONObject();
            obj.put("hero", hero); obj.put("skin", skin); obj.put("victory", victory);
            obj.put("k", k); obj.put("d", d); obj.put("a", a);
            obj.put("time", new SimpleDateFormat("MMM dd HH:mm", Locale.US).format(new Date()));
            JSONArray next = new JSONArray(); next.put(obj);
            for (int i = 0; i < Math.min(arr.length(), 19); i++) next.put(arr.get(i));
            prefs.edit().putString("history_json", next.toString())
                .putInt("matches", getTotalMatches() + 1).putInt("wins", getWins() + (victory ? 1 : 0)).apply();
        } catch (Exception ignored) {}
    }
    public List<String> getMatchHistoryLines() {
        List<String> list = new ArrayList<>();
        try {
            JSONArray arr = new JSONArray(prefs.getString("history_json", "[]"));
            for (int i = 0; i < arr.length(); i++) {
                JSONObject o = arr.getJSONObject(i);
                list.add((o.getBoolean("victory") ? "VICTORY" : "DEFEAT") + " | " + o.getString("hero")
                    + " (" + o.getString("skin") + ") | KDA: " + o.getInt("k") + "/" + o.getInt("d")
                    + "/" + o.getInt("a") + " | " + o.getString("time"));
            }
        } catch (Exception ignored) {}
        return list;
    }
}
EOF

cat > app/src/main/java/com/mlbbultimate/moba/SplashActivity.java << 'EOF'
package com.mlbbultimate.moba;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

public class SplashActivity extends Activity {
    private int progress = 0;
    @Override protected void onCreate(Bundle b) {
        super.onCreate(b);
        new EconomyManager(this);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL); root.setGravity(Gravity.CENTER);
        root.setBackground(new GradientDrawable(GradientDrawable.Orientation.TL_BR,
            new int[]{Color.parseColor("#060B19"), Color.parseColor("#111D3B"), Color.parseColor("#0A1024")}));
        TextView title = new TextView(this); title.setText("MLBB ULTIMATE");
        title.setTextColor(Color.parseColor("#FACC15")); title.setTextSize(38);
        title.setTypeface(Typeface.DEFAULT_BOLD); title.setGravity(Gravity.CENTER);
        TextView sub = new TextView(this);
        sub.setText("OFFLINE 5v5 MOBA ARENA  |  ALL HEROES & SKINS UNLOCKED");
        sub.setTextColor(Color.parseColor("#38BDF8")); sub.setTextSize(14);
        sub.setTypeface(Typeface.DEFAULT_BOLD); sub.setPadding(0, 8, 0, 36);
        final TextView status = new TextView(this);
        status.setText("Initializing Offline Economy Database...");
        status.setTextColor(Color.parseColor("#CBD5E1")); status.setPadding(0, 0, 0, 12);
        final ProgressBar bar = new ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal);
        bar.setMax(100); bar.setLayoutParams(new LinearLayout.LayoutParams(620, 26));
        root.addView(title); root.addView(sub); root.addView(status); root.addView(bar);
        setContentView(root);
        Handler h = new Handler(Looper.getMainLooper());
        Runnable tick = new Runnable() {
            @Override public void run() {
                progress += 10; bar.setProgress(progress);
                if (progress == 30) status.setText("Unlocking All 6 Roles & 30 Skins...");
                if (progress == 70) status.setText("Loading 3-Lane Battlefield Engine...");
                if (progress >= 100) { startActivity(new Intent(SplashActivity.this, MainLobbyActivity.class)); finish(); }
                else h.postDelayed(this, 100);
            }
        };
        h.postDelayed(tick, 100);
    }
}
EOF
echo "PART1_OK"
