mkdir -p app/src/main/assets

cat > app/src/main/java/com/mlbbultimate/moba/BattleActivity.java << 'EOF'
package com.mlbbultimate.moba;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import org.json.JSONObject;

public class BattleActivity extends Activity {
    private WebView webView;
    private EconomyManager eco;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        eco = new EconomyManager(this);
        webView = new WebView(this);
        webView.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        WebSettings ws = webView.getSettings();
        ws.setJavaScriptEnabled(true);
        ws.setDomStorageEnabled(true);
        ws.setAllowFileAccess(true);
        ws.setAllowFileAccessFromFileURLs(true);
        ws.setAllowUniversalAccessFromFileURLs(true);
        webView.setWebChromeClient(new WebChromeClient());
        webView.addJavascriptInterface(new Bridge(), "AndroidBridge");
        setContentView(webView);
        webView.loadUrl("file:///android_asset/arena3d.html");
    }

    public class Bridge {
        @JavascriptInterface
        public String getConfigJson() {
            try {
                HeroRegistry.Hero h = HeroRegistry.getHero(eco.getSelectedHeroId());
                HeroRegistry.Skin sk = h.skins.get(eco.getEquippedSkinTier(h.id));
                int lv = eco.getHeroLevel(h.id);
                JSONObject o = new JSONObject();
                o.put("heroId", h.id);
                o.put("heroName", h.name);
                o.put("role", h.role);
                o.put("maxHp", h.maxHp + lv * 50f);
                o.put("atk", h.atk + lv * 8f);
                o.put("speed", h.speed / 18f);
                o.put("range", h.range / 18f);
                o.put("primary", String.format("#%06X", 0xFFFFFF & sk.primaryColor));
                o.put("accent", String.format("#%06X", 0xFFFFFF & sk.accentColor));
                o.put("effect", String.format("#%06X", 0xFFFFFF & sk.effectColor));
                o.put("skinName", sk.name);
                o.put("spell", eco.getSelectedSpell());
                o.put("gfx", eco.getGraphicsQuality());
                o.put("s1", h.s1); o.put("s2", h.s2); o.put("s3", h.s3); o.put("ult", h.ult);
                return o.toString();
            } catch (Exception e) { return "{}"; }
        }

        @JavascriptInterface
        public void finishMatch(boolean victory, int k, int d, int a) {
            HeroRegistry.Hero h = HeroRegistry.getHero(eco.getSelectedHeroId());
            HeroRegistry.Skin sk = h.skins.get(eco.getEquippedSkinTier(h.id));
            eco.addMatchRecord(h.name, sk.name, victory, k, d, a);
            runOnUiThread(() -> finish());
        }

        @JavascriptInterface
        public void exitMatch() {
            runOnUiThread(() -> finish());
        }
    }

    @Override protected void onPause() { super.onPause(); if (webView != null) webView.onPause(); }
    @Override protected void onResume() { super.onResume(); if (webView != null) webView.onResume(); }
    @Override protected void onDestroy() { if (webView != null) webView.destroy(); super.onDestroy(); }
}
EOF

cat > app/src/main/assets/arena3d.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
*{box-sizing:border-box;user-select:none;-webkit-user-select:none;touch-action:none}
html,body{margin:0;padding:0;width:100%;height:100%;overflow:hidden;background:#07111e;font-family:sans-serif;color:#fff}
#gl{position:fixed;inset:0;width:100%;height:100%;display:block}
#labels{position:fixed;inset:0;pointer-events:none;overflow:hidden}
.lbl{position:absolute;transform:translate(-50%,-100%);text-align:center;font-size:10px;font-weight:700;text-shadow:0 1px 3px #000}
.hpbar{width:48px;height:5px;background:#111;border:1px solid #000;border-radius:3px;overflow:hidden;margin:2px auto 0}
.hpfill{height:100%;background:#22c55e}
#mm{position:fixed;top:10px;left:10px;width:118px;height:118px;background:rgba(8,15,32,.82);border:2px solid #38bdf8;border-radius:8px}
#tophud{position:fixed;top:10px;left:50%;transform:translateX(-50%);background:rgba(8,15,32,.85);border:1px solid #f59e0b;border-radius:14px;padding:5px 16px;font-size:13px;font-weight:700;white-space:nowrap}
#exitBtn{position:fixed;top:10px;right:12px;background:#334155;border:2px solid #94a3b8;color:#fff;border-radius:10px;padding:7px 14px;font-weight:700;font-size:12px}
#joyBase{position:fixed;bottom:22px;left:24px;width:116px;height:116px;border-radius:50%;background:rgba(255,255,255,.12);border:2px solid rgba(56,189,248,.6)}
#joyKnob{position:absolute;left:35px;top:35px;width:46px;height:46px;border-radius:50%;background:rgba(56,189,248,.85);border:2px solid #fff}
.cbtn{position:fixed;border-radius:50%;border:2px solid #fff;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:11px;text-align:center;box-shadow:0 3px 10px rgba(0,0,0,.6)}
.midrow{position:fixed;bottom:14px;left:50%;transform:translateX(-50%);display:flex;gap:10px}
.sbtn{width:54px;height:42px;border-radius:12px;border:2px solid #fff;display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:800;background:#1e293b}
#endModal{position:fixed;inset:0;background:rgba(4,9,22,.85);display:none;flex-direction:column;align-items:center;justify-content:center;z-index:99}
#endTitle{font-size:44px;font-weight:900;margin-bottom:10px}
#endSub{font-size:15px;color:#cbd5e1;margin-bottom:20px}
#endBtn{background:#f59e0b;color:#000;border:none;border-radius:12px;padding:12px 28px;font-weight:900;font-size:16px}
</style>
</head>
<body>
<canvas id="gl"></canvas>
<div id="labels"></div>
<canvas id="mm" width="118" height="118"></canvas>
<div id="tophud">BLUE 0 | 00:00 | RED 0 | KDA 0/0/0</div>
<div id="exitBtn">EXIT</div>
<div id="joyBase"><div id="joyKnob"></div></div>
<div class="midrow">
  <div class="sbtn" id="bRecall" style="background:#475569">RECALL</div>
  <div class="sbtn" id="bRegen" style="background:#16a34a">REGEN</div>
  <div class="sbtn" id="bSpell" style="background:#7c3aed">SPELL</div>
</div>
<div class="cbtn" id="bAtk" style="right:18px;bottom:18px;width:74px;height:74px;background:#dc2626;font-size:14px">ATK</div>
<div class="cbtn" id="bS1" style="right:104px;bottom:16px;width:54px;height:54px;background:#0284c7">S1</div>
<div class="cbtn" id="bS2" style="right:94px;bottom:82px;width:54px;height:54px;background:#0284c7">S2</div>
<div class="cbtn" id="bS3" style="right:28px;bottom:104px;width:54px;height:54px;background:#0284c7">S3</div>
<div class="cbtn" id="bUlt" style="right:164px;bottom:34px;width:60px;height:60px;background:#d97706">ULT</div>
<div id="endModal"><div id="endTitle">VICTORY</div><div id="endSub"></div><button id="endBtn">RETURN TO LOBBY</button></div>
<script src="three.min.js"></script>
<script>
EOF
echo "PART5_OK"
