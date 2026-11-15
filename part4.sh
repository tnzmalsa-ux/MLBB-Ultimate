cat > app/src/main/java/com/mlbbultimate/moba/ArenaView.java << 'EOF'
package com.mlbbultimate.moba;
import android.app.Activity;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ConcurrentLinkedQueue;

public class ArenaView extends SurfaceView implements Runnable {
    private Thread thread;
    private volatile boolean running;
    private final SurfaceHolder holder;
    private final EconomyManager eco;
    private final Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
    private static final float WORLD = 3200f;
    private float viewW = 1280, viewH = 720, camX = 300, camY = 2600;

    private static class Unit {
        String name; int team, kind, lane; boolean isPlayer;
        float x, y, hp, maxHp, atk, speed, range, radius, atkCd, respawn, stunTimer, speedBoostTimer;
        int color, accent, effectColor, kills, deaths, assists;
    }
    private static class Proj { float x, y, vx, vy, dmg, life, radius; int team, color; boolean stun; }
    private static class Fx { float x, y, r, maxR, life, maxLife; int color; }

    private final List<Unit> units = new ArrayList<>();
    private final List<Proj> projs = new ArrayList<>();
    private final List<Fx> fxs = new ArrayList<>();
    private final ConcurrentLinkedQueue<String> actionQueue = new ConcurrentLinkedQueue<>();

    private Unit player, blueBase, redBase;
    private float matchTime = 0, waveTimer = 2f;
    private int blueKills = 0, redKills = 0;
    private boolean matchOver = false, blueWon = false, savedRecord = false;
    private float cdAtk=0, cdS1=0, cdS2=0, cdS3=0, cdUlt=0, cdRegen=0, cdSpell=0, recallTimer=-1f, regenTimer=0f;
    private int joyPid = -1;
    private float joyCx=190, joyCy=530, joyKx=190, joyKy=530, joyDx=0, joyDy=0;
    private final RectF btnAtk=new RectF(), btnS1=new RectF(), btnS2=new RectF(), btnS3=new RectF(),
        btnUlt=new RectF(), btnRecall=new RectF(), btnRegen=new RectF(), btnSpell=new RectF(), btnExit=new RectF();

    public ArenaView(Context ctx) {
        super(ctx); holder = getHolder(); eco = new EconomyManager(ctx); initMatch();
    }

    private void initMatch() {
        units.clear(); projs.clear(); fxs.clear();
        HeroRegistry.Hero ph = HeroRegistry.getHero(eco.getSelectedHeroId());
        HeroRegistry.Skin psk = ph.skins.get(eco.getEquippedSkinTier(ph.id));
        int lv = eco.getHeroLevel(ph.id);
        player = makeHero(ph, psk, 0, 1, true, 360, 2840);
        player.maxHp += lv * 50; player.hp = player.maxHp; player.atk += lv * 8;
        units.add(player);

        int[] lanes = {0,0,2,2,0,1,1,2,2};
        for (int i = 0; i < 4; i++) {
            HeroRegistry.Hero h = HeroRegistry.getHero((ph.id + i + 1) % 6);
            units.add(makeHero(h, h.skins.get((i + 1) % 5), 0, lanes[i], false, 320 + i * 50, 2860 - i * 40));
        }
        for (int i = 0; i < 5; i++) {
            HeroRegistry.Hero h = HeroRegistry.getHero((i + 2) % 6);
            units.add(makeHero(h, h.skins.get((i + 2) % 5), 1, lanes[i + 4], false, 2860 - i * 40, 340 + i * 40));
        }
        blueBase = makeBuilding("Blue Base", 0, 3, 260, 2940, 6000, 140, 65, Color.parseColor("#2563EB"));
        redBase = makeBuilding("Red Base", 1, 3, 2940, 260, 6000, 140, 65, Color.parseColor("#DC2626"));
        units.add(blueBase); units.add(redBase);

        float[][] bt = {{260,2100},{260,1200},{850,2350},{1300,1900},{1100,2940},{2000,2940}};
        float[][] rt = {{1200,260},{2100,260},{1900,1300},{2350,850},{2940,2000},{2940,1100}};
        for (float[] t : bt) units.add(makeBuilding("Blue Tower", 0, 2, t[0], t[1], 2400, 110, 42, Color.parseColor("#38BDF8")));
        for (float[] t : rt) units.add(makeBuilding("Red Tower", 1, 2, t[0], t[1], 2400, 110, 42, Color.parseColor("#F87171")));

        float[][] jg = {{950,2050},{1250,2550},{2250,1150},{1950,650},{1150,1150},{2050,2050}};
        for (float[] j : jg) {
            Unit m = new Unit(); m.name="Jungle Creep"; m.team=2; m.kind=4; m.x=j[0]; m.y=j[1];
            m.maxHp=950; m.hp=950; m.atk=35; m.range=120; m.radius=34; m.speed=110;
            m.color=Color.parseColor("#A855F7"); m.accent=Color.parseColor("#FDE047"); units.add(m);
        }
    }

    private Unit makeHero(HeroRegistry.Hero h, HeroRegistry.Skin sk, int team, int lane, boolean isP, float x, float y) {
        Unit u = new Unit(); u.name=h.name; u.team=team; u.kind=0; u.lane=lane; u.isPlayer=isP;
        u.x=x; u.y=y; u.maxHp=h.maxHp; u.hp=h.maxHp; u.atk=h.atk; u.speed=h.speed; u.range=h.range; u.radius=28;
        u.color=sk.primaryColor; u.accent=sk.accentColor; u.effectColor=sk.effectColor; return u;
    }
    private Unit makeBuilding(String n, int team, int kind, float x, float y, float hp, float atk, float rad, int col) {
        Unit u = new Unit(); u.name=n; u.team=team; u.kind=kind; u.x=x; u.y=y;
        u.maxHp=hp; u.hp=hp; u.atk=atk; u.range=340; u.radius=rad; u.color=col; u.accent=Color.WHITE; return u;
    }
    public void resume() { running = true; thread = new Thread(this); thread.start(); }
    public void pause() { running = false; try { if (thread != null) thread.join(); } catch (InterruptedException ignored) {} }

    @Override public void run() {
        long prev = System.nanoTime();
        while (running) {
            long now = System.nanoTime();
            float dt = Math.min(0.05f, (now - prev) / 1e9f); prev = now;
            if (holder.getSurface().isValid()) {
                update(dt);
                Canvas c = holder.lockCanvas();
                if (c != null) { drawFrame(c); holder.unlockCanvasAndPost(c); }
            }
            try { Thread.sleep(14); } catch (InterruptedException ignored) {}
        }
    }

    private void update(float dt) {
        if (matchOver) return;
        matchTime += dt;
        cdAtk=Math.max(0,cdAtk-dt); cdS1=Math.max(0,cdS1-dt); cdS2=Math.max(0,cdS2-dt);
        cdS3=Math.max(0,cdS3-dt); cdUlt=Math.max(0,cdUlt-dt); cdRegen=Math.max(0,cdRegen-dt); cdSpell=Math.max(0,cdSpell-dt);

        if (regenTimer > 0 && player.hp > 0) { regenTimer -= dt; player.hp = Math.min(player.maxHp, player.hp + player.maxHp*0.09f*dt); }
        if (recallTimer > 0) {
            recallTimer -= dt;
            if (recallTimer <= 0) { player.x=260; player.y=2860; player.hp=player.maxHp; spawnFx(player.x,player.y,120,Color.YELLOW); }
        }

        waveTimer -= dt;
        if (waveTimer <= 0) {
            waveTimer = 14f;
            for (int lane = 0; lane < 3; lane++) {
                for (int m = 0; m < 2; m++) {
                    Unit bm = new Unit(); bm.name="Minion"; bm.team=0; bm.kind=1; bm.lane=lane;
                    bm.x=340+m*35; bm.y=2860-m*35; bm.maxHp=260; bm.hp=260; bm.atk=26; bm.speed=165; bm.range=100; bm.radius=16;
                    bm.color=Color.parseColor("#60A5FA"); bm.accent=Color.WHITE; units.add(bm);
                    Unit rm = new Unit(); rm.name="Minion"; rm.team=1; rm.kind=1; rm.lane=lane;
                    rm.x=2860-m*35; rm.y=340+m*35; rm.maxHp=260; rm.hp=260; rm.atk=26; rm.speed=165; rm.range=100; rm.radius=16;
                    rm.color=Color.parseColor("#F87171"); rm.accent=Color.WHITE; units.add(rm);
                }
            }
        }
        while (!actionQueue.isEmpty()) handlePlayerAction(actionQueue.poll());
        if (player.hp > 0 && player.stunTimer <= 0 && (Math.abs(joyDx) > 0.08f || Math.abs(joyDy) > 0.08f)) {
            recallTimer = -1f;
            float spd = player.speed * (player.speedBoostTimer > 0 ? 1.4f : 1f);
            player.x = clamp(player.x + joyDx * spd * dt, 40, WORLD - 40);
            player.y = clamp(player.y + joyDy * spd * dt, 40, WORLD - 40);
        }
        for (int i = 0; i < units.size(); i++) {
            Unit u = units.get(i);
            if (u.hp <= 0) {
                if (u.kind == 0 || u.kind == 4) {
                    u.respawn -= dt;
                    if (u.respawn <= 0) {
                        u.hp = u.maxHp;
                        if (u.kind == 0) { u.x = u.team==0 ? 320 : 2880; u.y = u.team==0 ? 2880 : 320; }
                    }
                }
                continue;
            }
            u.atkCd=Math.max(0,u.atkCd-dt); u.stunTimer=Math.max(0,u.stunTimer-dt); u.speedBoostTimer=Math.max(0,u.speedBoostTimer-dt);
            if (u.stunTimer > 0 || u.isPlayer) continue;
            Unit target = findNearestEnemy(u, u.kind >= 2 ? u.range : 380);
            if (target != null) {
                if (dist(u.x,u.y,target.x,target.y) <= u.range) {
                    if (u.atkCd <= 0) { u.atkCd = u.kind==2 ? 1.1f : 0.75f; fireProj(u, target, u.atk, false); }
                } else if (u.kind <= 1) moveToward(u, target.x, target.y, dt);
            } else if (u.kind <= 1) {
                float[] wp = getLaneTarget(u); moveToward(u, wp[0], wp[1], dt);
            }
        }
        Iterator<Unit> uit = units.iterator();
        while (uit.hasNext()) { Unit u = uit.next(); if (u.kind == 1 && u.hp <= 0) uit.remove(); }
        Iterator<Proj> pit = projs.iterator();
        while (pit.hasNext()) {
            Proj pr = pit.next(); pr.x += pr.vx*dt; pr.y += pr.vy*dt; pr.life -= dt; boolean hit = false;
            for (Unit u : units) {
                if (u.hp > 0 && u.team != pr.team && dist(pr.x,pr.y,u.x,u.y) <= u.radius + pr.radius) {
                    damageUnit(u, pr.dmg, pr.team); if (pr.stun) u.stunTimer = 1.1f; hit = true; break;
                }
            }
            if (hit || pr.life <= 0) pit.remove();
        }
        Iterator<Fx> fit = fxs.iterator();
        while (fit.hasNext()) { Fx f = fit.next(); f.life -= dt; f.r = f.maxR*(1f-f.life/f.maxLife); if (f.life<=0) fit.remove(); }

        camX = clamp(player.x - viewW/2f, 0, Math.max(0, WORLD - viewW));
        camY = clamp(player.y - viewH/2f, 0, Math.max(0, WORLD - viewH));
        if (blueBase.hp <= 0 || redBase.hp <= 0) {
            matchOver = true; blueWon = redBase.hp <= 0;
            if (!savedRecord) {
                savedRecord = true;
                HeroRegistry.Hero ph = HeroRegistry.getHero(eco.getSelectedHeroId());
                eco.addMatchRecord(ph.name, ph.skins.get(eco.getEquippedSkinTier(ph.id)).name, blueWon, player.kills, player.deaths, player.assists);
            }
        }
    }

    private void handlePlayerAction(String act) {
        if (player.hp <= 0) return;
        if (act.equals("RECALL")) { recallTimer = 3f; return; }
        if (act.equals("REGEN") && cdRegen <= 0) { cdRegen = 18f; regenTimer = 4f; return; }
        if (act.equals("SPELL") && cdSpell <= 0) {
            cdSpell = 25f; String sp = eco.getSelectedSpell();
            if (sp.equals("Flicker")) {
                float dx = Math.abs(joyDx)>0.1f ? joyDx : 0.7f, dy = Math.abs(joyDy)>0.1f ? joyDy : -0.7f;
                player.x = clamp(player.x + dx*260, 40, WORLD-40); player.y = clamp(player.y + dy*260, 40, WORLD-40);
                spawnFx(player.x, player.y, 90, Color.YELLOW);
            } else if (sp.equals("Healing")) { player.hp = Math.min(player.maxHp, player.hp + player.maxHp*0.3f); spawnFx(player.x, player.y, 130, Color.GREEN); }
            else if (sp.equals("Inspire")) { player.speedBoostTimer = 5f; spawnFx(player.x, player.y, 110, Color.RED); }
            else { Unit t = findNearestEnemy(player, 350); if (t != null) damageUnit(t, 380, 0); spawnFx(player.x, player.y, 140, Color.CYAN); }
            return;
        }
        Unit target = findNearestEnemy(player, Math.max(player.range + 120, 360));
        if (act.equals("ATK") && cdAtk <= 0) {
            cdAtk = 0.5f;
            if (target != null) fireProj(player, target, player.atk, false);
            else spawnFx(player.x, player.y, 70, player.effectColor);
        } else if (act.equals("S1") && cdS1 <= 0) {
            cdS1 = 4f; if (target != null) fireProj(player, target, player.atk*1.9f, false);
            spawnFx(player.x, player.y, 110, player.effectColor);
        } else if (act.equals("S2") && cdS2 <= 0) {
            cdS2 = 6f;
            float dx = Math.abs(joyDx)>0.1f ? joyDx : 0.7f, dy = Math.abs(joyDy)>0.1f ? joyDy : -0.7f;
            player.x = clamp(player.x + dx*180, 40, WORLD-40); player.y = clamp(player.y + dy*180, 40, WORLD-40);
            aoeDamage(player.x, player.y, 200, player.atk*1.4f, false); spawnFx(player.x, player.y, 180, player.accent);
        } else if (act.equals("S3") && cdS3 <= 0) {
            cdS3 = 7f; aoeDamage(player.x, player.y, 220, player.atk*1.5f, true); spawnFx(player.x, player.y, 210, player.effectColor);
        } else if (act.equals("ULT") && cdUlt <= 0) {
            cdUlt = 13f; float tx = target!=null ? target.x : player.x, ty = target!=null ? target.y : player.y;
            aoeDamage(tx, ty, 270, player.atk*3.1f, true); spawnFx(tx, ty, 270, player.effectColor);
        }
    }

    private void aoeDamage(float x, float y, float rad, float dmg, boolean stun) {
        for (Unit u : units) if (u.hp > 0 && u.team != 0 && dist(x,y,u.x,u.y) <= rad + u.radius) {
            damageUnit(u, dmg, 0); if (stun) u.stunTimer = 1.2f;
        }
    }
    private void damageUnit(Unit u, float dmg, int attackerTeam) {
        u.hp -= dmg;
        if (u.hp <= 0) {
            u.hp = 0;
            if (u.kind == 0) {
                u.deaths++; u.respawn = 6f;
                if (attackerTeam == 0) { blueKills++; if (dist(player.x,player.y,u.x,u.y) < 600) player.kills++; }
                else redKills++;
            } else if (u.kind == 4) { u.respawn = 18f; if (attackerTeam == 0) player.hp = Math.min(player.maxHp, player.hp + 250); }
            spawnFx(u.x, u.y, 95, Color.WHITE);
        }
    }
    private void fireProj(Unit src, Unit dst, float dmg, boolean stun) {
        Proj pr = new Proj(); pr.x=src.x; pr.y=src.y; pr.dmg=dmg; pr.team=src.team; pr.stun=stun;
        pr.color = src.kind==0 ? src.effectColor : src.color; pr.radius = src.kind==0 ? 12 : 8; pr.life = 1.3f;
        float d = Math.max(1f, dist(src.x,src.y,dst.x,dst.y));
        pr.vx = ((dst.x-src.x)/d)*640f; pr.vy = ((dst.y-src.y)/d)*640f; projs.add(pr);
    }
    private void spawnFx(float x, float y, float maxR, int col) {
        if (eco.getGraphicsQuality() == 0 && fxs.size() > 6) return;
        Fx f = new Fx(); f.x=x; f.y=y; f.maxR=maxR; f.life=0.45f; f.maxLife=0.45f; f.color=col; fxs.add(f);
    }
    private Unit findNearestEnemy(Unit self, float maxD) {
        Unit best = null; float bestD = maxD;
        for (Unit u : units) if (u.hp > 0 && u.team != self.team && !(self.team==2 && u.team==2)) {
            float d = dist(self.x,self.y,u.x,u.y) - u.radius; if (d < bestD) { bestD=d; best=u; }
        }
        return best;
    }
    private float[] getLaneTarget(Unit u) {
        if (u.team == 0) {
            if (u.lane == 0 && u.y > 400) return new float[]{260, 260};
            if (u.lane == 2 && u.x < 2800) return new float[]{2940, 2940};
            return new float[]{2940, 260};
        } else {
            if (u.lane == 0 && u.x > 400) return new float[]{260, 260};
            if (u.lane == 2 && u.y < 2800) return new float[]{2940, 2940};
            return new float[]{260, 2940};
        }
    }
    private void moveToward(Unit u, float tx, float ty, float dt) {
        float d = dist(u.x, u.y, tx, ty); if (d < 8) return;
        u.x = clamp(u.x + ((tx-u.x)/d)*u.speed*dt, 40, WORLD-40);
        u.y = clamp(u.y + ((ty-u.y)/d)*u.speed*dt, 40, WORLD-40);
    }

    private void drawFrame(Canvas c) {
        viewW = getWidth(); viewH = getHeight(); updateHudRects();
        c.drawColor(Color.parseColor("#0F291E")); c.save(); c.translate(-camX, -camY);
        p.setStyle(Paint.Style.STROKE); p.setStrokeWidth(180); p.setColor(Color.parseColor("#334155"));
        c.drawLine(260,2940,260,260,p); c.drawLine(260,260,2940,260,p);
        c.drawLine(260,2940,2940,260,p); c.drawLine(260,2940,2940,2940,p); c.drawLine(2940,2940,2940,260,p);
        p.setStrokeWidth(140); p.setColor(Color.parseColor("#0E4D6E")); c.drawLine(0,0,WORLD,WORLD,p);

        p.setStyle(Paint.Style.STROKE); p.setStrokeWidth(6);
        for (Fx f : fxs) { p.setColor(f.color); c.drawCircle(f.x, f.y, f.r, p); }
        p.setStyle(Paint.Style.FILL);
        for (Unit u : units) {
            if (u.hp <= 0) continue;
            if (eco.getGraphicsQuality() >= 1 && u.kind == 0) {
                p.setColor(u.accent); p.setAlpha(90); c.drawCircle(u.x, u.y, u.radius + 9, p); p.setAlpha(255);
            }
            p.setColor(u.color); c.drawCircle(u.x, u.y, u.radius, p);
            if (u.isPlayer) { p.setStyle(Paint.Style.STROKE); p.setStrokeWidth(4); p.setColor(Color.YELLOW); c.drawCircle(u.x,u.y,u.radius+4,p); p.setStyle(Paint.Style.FILL); }
            float bw = u.radius * 2.2f;
            p.setColor(Color.BLACK); c.drawRect(u.x-bw/2, u.y-u.radius-18, u.x+bw/2, u.y-u.radius-10, p);
            p.setColor(u.team==0 ? Color.parseColor("#22C55E") : (u.team==1 ? Color.parseColor("#EF4444") : Color.YELLOW));
            c.drawRect(u.x-bw/2, u.y-u.radius-18, u.x-bw/2 + bw*(u.hp/u.maxHp), u.y-u.radius-10, p);
            if (u.kind == 0) { p.setColor(Color.WHITE); p.setTextSize(22); p.setTextAlign(Paint.Align.CENTER); c.drawText(u.name, u.x, u.y-u.radius-24, p); }
        }
        for (Proj pr : projs) { p.setColor(pr.color); c.drawCircle(pr.x, pr.y, pr.radius, p); }
        if (recallTimer > 0) { p.setStyle(Paint.Style.STROKE); p.setStrokeWidth(5); p.setColor(Color.YELLOW); c.drawCircle(player.x,player.y,48,p); p.setStyle(Paint.Style.FILL); }
        c.restore(); drawHud(c);
    }

    private void drawHud(Canvas c) {
        float mm = 190f; p.setColor(Color.argb(180,10,18,38)); c.drawRect(18,18,18+mm,18+mm,p);
        for (Unit u : units) if (u.hp > 0) {
            p.setColor(u.isPlayer ? Color.YELLOW : (u.team==0 ? Color.CYAN : (u.team==1 ? Color.RED : Color.MAGENTA)));
            c.drawCircle(18+(u.x/WORLD)*mm, 18+(u.y/WORLD)*mm, (u.kind==0||u.kind>=2)?4.5f:2f, p);
        }
        p.setColor(Color.argb(180,10,18,38)); c.drawRoundRect(viewW/2f-190,12,viewW/2f+190,68,16,16,p);
        p.setColor(Color.WHITE); p.setTextSize(28); p.setTextAlign(Paint.Align.CENTER);
        c.drawText("BLUE "+blueKills+"  |  "+String.format("%02d:%02d",(int)(matchTime/60),(int)(matchTime%60))+"  |  RED "+redKills, viewW/2f, 50, p);
        drawButton(c, btnExit, "EXIT", Color.parseColor("#334155"), 0);
        joyCx=175; joyCy=viewH-165; p.setColor(Color.argb(90,255,255,255)); c.drawCircle(joyCx,joyCy,95,p);
        p.setColor(Color.argb(200,56,189,248)); c.drawCircle(joyPid==-1?joyCx:joyKx, joyPid==-1?joyCy:joyKy, 42, p);
        drawButton(c,btnAtk,"ATK",Color.parseColor("#DC2626"),cdAtk);
        drawButton(c,btnS1,"S1",Color.parseColor("#0284C7"),cdS1);
        drawButton(c,btnS2,"S2",Color.parseColor("#0284C7"),cdS2);
        drawButton(c,btnS3,"S3",Color.parseColor("#0284C7"),cdS3);
        drawButton(c,btnUlt,"ULT",Color.parseColor("#D97706"),cdUlt);
        drawButton(c,btnRecall,"RECALL",Color.parseColor("#475569"),0);
        drawButton(c,btnRegen,"REGEN",Color.parseColor("#16A34A"),cdRegen);
        drawButton(c,btnSpell,eco.getSelectedSpell().toUpperCase(),Color.parseColor("#7C3AED"),cdSpell);
        if (player.hp <= 0) { p.setColor(Color.RED); p.setTextSize(42); c.drawText("RESPAWNING IN "+(int)Math.ceil(player.respawn)+"s...", viewW/2f, viewH/2f, p); }
        if (matchOver) {
            p.setColor(Color.argb(200,5,10,25)); c.drawRect(0,0,viewW,viewH,p);
            p.setColor(blueWon ? Color.parseColor("#FACC15") : Color.parseColor("#EF4444")); p.setTextSize(64);
            c.drawText(blueWon ? "VICTORY!" : "DEFEAT", viewW/2f, viewH/2f-40, p);p.setColor(Color.WHITE); p.setTextSize(28); c.drawText("Tap anywhere to return to Lobby", viewW/2f, viewH/2f+40, p);
        }
    }

    private void drawButton(Canvas c, RectF r, String label, int col, float cd) {
        p.setColor(cd>0 ? Color.parseColor("#1E293B") : col); c.drawOval(r,p);
        p.setStyle(Paint.Style.STROKE); p.setStrokeWidth(3); p.setColor(Color.WHITE); c.drawOval(r,p); p.setStyle(Paint.Style.FILL);
        p.setColor(Color.WHITE); p.setTextSize(label.length()>4 ? 17 : 22); p.setTextAlign(Paint.Align.CENTER);
        c.drawText(cd>0 ? String.valueOf((int)Math.ceil(cd)) : label, r.centerX(), r.centerY()+8, p);
    }

    private void updateHudRects() {
        btnExit.set(viewW-130,18,viewW-22,74); btnAtk.set(viewW-150,viewH-155,viewW-30,viewH-35);
        btnS1.set(viewW-285,viewH-125,viewW-185,viewH-25); btnS2.set(viewW-265,viewH-245,viewW-165,viewH-145);
        btnS3.set(viewW-155,viewH-285,viewW-55,viewH-185); btnUlt.set(viewW-395,viewH-160,viewW-295,viewH-60);
        btnRecall.set(viewW/2f-170,viewH-95,viewW/2f-70,viewH-15); btnRegen.set(viewW/2f-50,viewH-95,viewW/2f+50,viewH-15);
        btnSpell.set(viewW/2f+70,viewH-95,viewW/2f+170,viewH-15);
    }

    @Override public boolean onTouchEvent(MotionEvent e) {
        if (matchOver && e.getActionMasked() == MotionEvent.ACTION_DOWN) { ((Activity)getContext()).finish(); return true; }
        int idx = e.getActionIndex(), pid = e.getPointerId(idx);
        float x = e.getX(idx), y = e.getY(idx);
        switch (e.getActionMasked()) {
            case MotionEvent.ACTION_DOWN: case MotionEvent.ACTION_POINTER_DOWN:
                if (btnExit.contains(x,y)) { ((Activity)getContext()).finish(); return true; }
                if (btnAtk.contains(x,y)) actionQueue.add("ATK");
                else if (btnS1.contains(x,y)) actionQueue.add("S1");
                else if (btnS2.contains(x,y)) actionQueue.add("S2");
                else if (btnS3.contains(x,y)) actionQueue.add("S3");
                else if (btnUlt.contains(x,y)) actionQueue.add("ULT");
                else if (btnRecall.contains(x,y)) actionQueue.add("RECALL");
                else if (btnRegen.contains(x,y)) actionQueue.add("REGEN");
                else if (btnSpell.contains(x,y)) actionQueue.add("SPELL");
                else if (x < viewW*0.45f && joyPid == -1) { joyPid = pid; updateJoy(x,y); }
                break;
            case MotionEvent.ACTION_MOVE:
                for (int i=0; i<e.getPointerCount(); i++) if (e.getPointerId(i)==joyPid) updateJoy(e.getX(i), e.getY(i));
                break;
            case MotionEvent.ACTION_UP: case MotionEvent.ACTION_POINTER_UP: case MotionEvent.ACTION_CANCEL:
                if (pid == joyPid) { joyPid = -1; joyDx = 0; joyDy = 0; }
                break;
        }
        return true;
    }

    private void updateJoy(float x, float y) {
        float dx = x-joyCx, dy = y-joyCy, d = Math.max(1f, (float)Math.hypot(dx,dy)), max = 85f;
        joyKx = d>max ? joyCx+(dx/d)*max : x; joyKy = d>max ? joyCy+(dy/d)*max : y;
        joyDx = (joyKx-joyCx)/max; joyDy = (joyKy-joyCy)/max;
    }
    private float dist(float x1, float y1, float x2, float y2) { return (float)Math.hypot(x2-x1, y2-y1); }
    private float clamp(float v, float mn, float mx) { return Math.max(mn, Math.min(mx, v)); }
}
EOF
echo "PART4_OK"
