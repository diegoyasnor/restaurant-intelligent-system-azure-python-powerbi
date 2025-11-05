import os, json, base64
import datetime as dt
from zoneinfo import ZoneInfo

import azure.functions as func
import pyodbc

app = func.FunctionApp()
TZ = ZoneInfo("America/New_York")

# ---------- Conexión SQL ----------
def _conn():
    drivers = [d.strip() for d in pyodbc.drivers()]
    driver = None
    for cand in ["ODBC Driver 18 for SQL Server", "ODBC Driver 17 for SQL Server"]:
        if cand in drivers:
            driver = cand
            break
    if not driver:
        # Mensaje claro si no hay driver
        raise RuntimeError(f"No se encontró un driver ODBC de SQL Server. Drivers disponibles: {drivers}")

    return pyodbc.connect(
        f"Driver={{{driver}}};"
        f"Server={os.getenv('SQL_SERVER')};"
        f"Database={os.getenv('SQL_DB')};"
        f"Uid={os.getenv('SQL_USER')};"
        f"Pwd={os.getenv('SQL_PWD')};"
        "Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
    )


# ---------- Fechas: lunes-domingo de la semana anterior ----------
def monday_sunday_of_last_week(ref_date: dt.date):
    weekday = ref_date.weekday()  # Mon=0..Sun=6
    this_monday = ref_date - dt.timedelta(days=weekday)
    last_monday = this_monday - dt.timedelta(days=7)
    last_sunday = last_monday + dt.timedelta(days=6)
    return last_monday, last_sunday

# ---------- Helpers de salida ----------
def fmt_currency(v):
    try:
        return f"${float(v):,.2f}"
    except Exception:
        return str(v)

def gen_html(rows, week_start, week_end):
    month_start = dt.date(week_end.year, week_end.month, 1)
    header = f"""
    <h2>Weekly Revenue Report</h2>
    <p><b>Semana:</b> {week_start} – {week_end} (ET)<br/>
       <b>Acumulado mensual desde:</b> {month_start}</p>
    <table border="1" cellpadding="6" cellspacing="0">
      <tr>
        <th>#</th><th>Restaurante</th><th>Revenue semana</th><th>Revenue MTD</th>
      </tr>
    """
    body = []
    for i, r in enumerate(rows, start=1):
        body.append(
            f"<tr>"
            f"<td>{i}</td>"
            f"<td>{r.get('restaurant_name','')}</td>"
            f"<td>{fmt_currency(r.get('week_revenue',0))}</td>"
            f"<td>{fmt_currency(r.get('mtd_revenue',0))}</td>"
            f"</tr>"
        )
    footer = "</table><p style='font-size:12px;color:#666'>Generado automáticamente (America/New_York)</p>"
    return header + "".join(body) + footer

def gen_csv_b64(rows):
    lines = ["restaurant_id,restaurant_name,week_revenue,mtd_revenue"]
    for r in rows:
        rid = r.get("restaurant_id","")
        name = (r.get("restaurant_name","") or "").replace('"','""')
        wr = r.get("week_revenue",0)
        mtd = r.get("mtd_revenue",0)
        lines.append(f'{rid},"{name}",{wr},{mtd}')
    csv = "\n".join(lines)
    return base64.b64encode(csv.encode("utf-8")).decode("ascii")

# ---------- Ejecuta la SP ----------
def query_sp(week_start: dt.date, week_end: dt.date):
    rows = []
    with _conn() as cn:
        cur = cn.cursor()
        cur.execute(
            "EXEC rpt_weekly_and_mtd_revenue @WeekStart=?, @WeekEnd=?",
            week_start, week_end
        )
        cols = [c[0] for c in cur.description]
        for rec in cur.fetchall():
            rows.append(dict(zip(cols, rec)))
    return rows

# ---------- Endpoint HTTP ----------
@app.route(route="weekly_revenue", auth_level=func.AuthLevel.FUNCTION)
def weekly_revenue(req: func.HttpRequest) -> func.HttpResponse:
    # Modo test: ?as_of=YYYY-MM-DD
    as_of = req.params.get("as_of")
    if as_of:
        ref_date = dt.date.fromisoformat(as_of)
    else:
        ref_date = dt.datetime.now(TZ).date()

    week_start, week_end = monday_sunday_of_last_week(ref_date)
    data = query_sp(week_start, week_end)

    html = gen_html(data, week_start, week_end)
    csv_b64 = gen_csv_b64(data)
    subject = f"Weekly Revenue | {week_start}–{week_end}"

    payload = {
        "subject": subject,
        "html": html,
        "csv_base64": csv_b64,
        "window": {
            "week_start": str(week_start),
            "week_end": str(week_end),
            "month_start": str(dt.date(week_end.year, week_end.month, 1))
        }
    }
    return func.HttpResponse(json.dumps(payload), status_code=200, mimetype="application/json")
