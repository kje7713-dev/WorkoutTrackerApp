
#!/usr/bin/env python3

# Kevin's Yahoo Fantasy Football Lineup Evaluator
#
# Preconfigured for:
#   - League ID: 387432
#   - Team name: Kevin’s wonderful team
#
# Usage (examples):
#   python kevin_ffb_lineup.py --week 1
#   python kevin_ffb_lineup.py --week 2
#   python kevin_ffb_lineup.py            # will prompt for week if not provided
#
# First run will open a browser to authorize Yahoo (OAuth2).
#
# Env vars expected (set once):
#   YAHOO_CONSUMER_KEY, YAHOO_CONSUMER_SECRET

import argparse
import os
import sys
from datetime import datetime

try:
    from yahoo_oauth import OAuth2
    import yahoo_fantasy_api as yfa
except Exception as e:
    print("Missing dependencies. Run: pip install -r requirements.txt")
    print(e)
    sys.exit(1)

LEAGUE_ID = "387432"
TARGET_TEAM_NAME = "Kevin’s wonderful team"  # exact match preferred; we also try a case-insensitive match

def get_oauth():
    ck = os.environ.get("YAHOO_CONSUMER_KEY")
    cs = os.environ.get("YAHOO_CONSUMER_SECRET")
    if not (ck and cs):
        print("Set YAHOO_CONSUMER_KEY and YAHOO_CONSUMER_SECRET environment variables.")
    oauth = OAuth2(None, None, from_file="oauth2.json")
    if not oauth.token_is_valid():
        oauth.refresh_access_token()
    return oauth

def find_team_key_by_name(league, name):
    teams = league.teams() or {}
    # teams is {team_key: team_name}
    # exact first
    for tk, tn in teams.items():
        if tn == name:
            return tk, tn
    # case-insensitive fallback
    lname = name.lower()
    for tk, tn in teams.items():
        if tn.lower() == lname:
            return tk, tn
    # partial contains fallback
    for tk, tn in teams.items():
        if lname in tn.lower():
            return tk, tn
    return None, None

def fetch_roster_and_positions(team, week=None):
    roster = team.roster(week) if week else team.roster()
    cleaned = []
    for p in roster:
        cleaned.append({
            "name": p.get("name"),
            "player_id": p.get("player_id"),
            "position_type": p.get("position_type"),
            "eligible_positions": p.get("eligible_positions"),
            "selected_position": p.get("selected_position",{}).get("position", p.get("selected_position")),
            "status": p.get("status"),
            "bye_weeks": p.get("bye_weeks"),
            "editorial_team_abbr": p.get("editorial_team_abbr"),
        })
    return cleaned

def split_starters_bench(roster):
    starters, bench = [], []
    for p in roster:
        slot = (p.get("selected_position") or "").upper()
        if slot in ("BN", "IR", "IR+", "NA"):
            bench.append(p)
        else:
            starters.append(p)
    return starters, bench

def flag_warnings(players):
    warnings = []
    for p in players:
        name = p.get("name") or "Unknown"
        slot = (p.get("selected_position") or "BN")
        status = (p.get("status") or "").upper()
        byes = p.get("bye_weeks")
        bye_txt = ""
        if isinstance(byes, dict) and "week" in byes:
            bye_txt = f" (bye wk {byes['week']})"
        elif isinstance(byes, list) and byes:
            bye_txt = f" (bye wk {byes[0]})"
        if status in ("O", "IR", "PUP", "SUSP"):
            warnings.append(f"{slot}: {name} is {status}{bye_txt}")
        elif status in ("Q", "D"):
            warnings.append(f"{slot}: {name} is {status}{bye_txt}")
        elif "bye" in bye_txt.lower():
            warnings.append(f"{slot}: {name}{bye_txt}")
    return warnings

def print_table(title, rows, cols):
    print(f"\n=== {title} ===")
    if not rows:
        print("(none)")
        return
    widths = [max(len(str(r.get(c,\"\"))) for r in rows + [{c:c}]) for c in cols]
    print(\" | \".join(c.ljust(w) for c, w in zip(cols, widths)))
    print(\"-+-\".join(\"-\"*w for w in widths))
    for r in rows:
        print(\" | \".join(str(r.get(c,\"\"))[:80].ljust(w) for c, w in zip(cols, widths)))

def main():
    ap = argparse.ArgumentParser(description=\"Kevin's FFB lineup pull + evaluation (Yahoo API)\")
    ap.add_argument(\"--week\", type=int, help=\"NFL week number (1-18). If omitted, you'll be prompted.\")
    args = ap.parse_args()

    oauth = get_oauth()
    game = yfa.Game(oauth, 'nfl')
    league_key = f\"nfl.l.{LEAGUE_ID}\"
    league = game.to_league(league_key)

    team_key, resolved_name = find_team_key_by_name(league, TARGET_TEAM_NAME)
    if not team_key:
        print(\"Couldn't auto-find your team. Here are the teams in the league:\\n\")
        teams = league.teams() or {}
        for tk, tn in sorted(teams.items(), key=lambda kv: kv[1].lower()):
            print(f\"- {tn:40s} ({tk})\")
        print(\"\\nPlease update TARGET_TEAM_NAME in the script to match exactly, or run the generic script.\")
        sys.exit(2)

    team = league.to_team(team_key)
    print(f\"Using team: {resolved_name} ({team_key}) in league {LEAGUE_ID}\")

    # Get week or prompt
    week = args.week
    if not week:
        try:
            week = int(input(\"Enter NFL scoring week (1-18): \").strip())
        except Exception:
            week = None

    roster = fetch_roster_and_positions(team, week)
    starters, bench = split_starters_bench(roster)

    # Try to get simple projections (best-effort)
    projections = {}
    try:
        if week:
            pids = [p.get(\"player_id\") for p in roster if p.get(\"player_id\")]
            chunk = 25
            for i in range(0, len(pids), chunk):
                ids = pids[i:i+chunk]
                stats = league.player_stats(ids, \"week\", week=week)
                for pid, s in stats.items():
                    st = s.get(\"stats\", {})
                    proj = st.get(\"proj_points\")
                    pts = st.get(\"points\")
                    projections[pid] = proj if proj is not None else pts
    except Exception:
        pass

    # Build tables
    s_rows = []
    for p in starters:
        s_rows.append({
            \"Slot\": (p.get(\"selected_position\") or \"\"),
            \"Player\": (p.get(\"name\") or \"\"),
            \"Team\": p.get(\"editorial_team_abbr\",\"\"),
            \"Status\": (p.get(\"status\") or \"\"),
            \"Bye\": (p.get(\"bye_weeks\",{}).get(\"week\") if isinstance(p.get(\"bye_weeks\"), dict) else (p.get(\"bye_weeks\",[None])[0] if isinstance(p.get(\"bye_weeks\"), list) else \"\")),
            \"Proj\": (projections.get(p.get(\"player_id\")) if projections else \"\"),
        })
    b_rows = []
    for p in bench:
        b_rows.append({
            \"Slot\": (p.get(\"selected_position\") or \"\"),
            \"Player\": (p.get(\"name\") or \"\"),
            \"Team\": p.get(\"editorial_team_abbr\",\"\"),
            \"Status\": (p.get(\"status\") or \"\"),
            \"Bye\": (p.get(\"bye_weeks\",{}).get(\"week\") if isinstance(p.get(\"bye_weeks\"), dict) else (p.get(\"bye_weeks\",[None])[0] if isinstance(p.get(\"bye_weeks\"), list) else \"\")),
            \"Proj\": (projections.get(p.get(\"player_id\")) if projections else \"\"),
        })

    print_table(\"Starters\", s_rows, [\"Slot\",\"Player\",\"Team\",\"Status\",\"Bye\",\"Proj\"])
    print_table(\"Bench\", b_rows, [\"Slot\",\"Player\",\"Team\",\"Status\",\"Bye\",\"Proj\"])

    issues = flag_warnings(starters + bench)
    if issues:
        print(\"\\n=== Flags & Warnings ===\")
        for w in issues:
            print(\"-\", w)

    if projections:
        print(\"\\n=== Suggestions (based on available projections) ===\")
        bench_by_pos = {}
        for p in bench:
            for ep in (p.get(\"eligible_positions\") or []):
                bench_by_pos.setdefault(ep, []).append(p)

        for s in starters:
            slot = (s.get(\"selected_position\") or \"BN\").upper()
            if slot in (\"BN\",\"IR\",\"IR+\",\"NA\"):
                continue
            s_pid = s.get(\"player_id\")
            s_proj = projections.get(s_pid)
            if s_proj is None:
                continue
            candidates = bench_by_pos.get(slot, [])
            if not candidates:
                continue
            best = None; best_proj = None
            for b in candidates:
                bp = projections.get(b.get(\"player_id\"))
                if bp is None:
                    continue
                if (best is None) or (bp > best_proj):
                    best = b; best_proj = bp
            if best and best_proj > s_proj:
                print(f\"Consider {best.get('name')} ({best_proj:.2f}) over {s.get('name')} in {slot} ({s_proj:.2f}).\")
    else:
        print(\"\\n(No projections available via API; printed roster and flags only.)\")

    print(\"\\nDone.\")

if __name__ == \"__main__\":
    main()
