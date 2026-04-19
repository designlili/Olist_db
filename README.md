![Olist E-Commerce Banner](https://via.placeholder.com/1200x300.png?text=Olist+E-Commerce+Data+Analysis)

🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️

🛒 Olist E-Commerce Data Analysis

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue)
![SQL](https://img.shields.io/badge/SQL-Analysis-orange)
![Data Cleaning](https://img.shields.io/badge/Data-Cleaning-green)
![Analytics](https://img.shields.io/badge/Business-Analytics-purple)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

In diesem Projekt habe ich ein reales E-Commerce-Dataset in PostgreSQL verarbeitet und analysiert.

Ich habe die Datenbank strukturiert aufgebaut, Daten bereinigt, Beziehungen modelliert und eine saubere Grundlage 
für Analysen geschaffen. Der Fokus lag dabei auf Datenqualität, klarer Modellierung und praxisnahen Auswertungen.

Auf dieser Basis habe ich verschiedene Business-Analysen umgesetzt, darunter Umsatzentwicklungen, Kundenverhalten und Lieferzeiten.

Das Projekt zeigt meine Fähigkeiten in SQL, Datenaufbereitung und analytischem Denken anhand eines realistischen 
E-Commerce Use Cases und bildet eine solide Grundlage für Reporting und Dashboarding.

🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️

🎯 Projektziele

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ Aufbau einer relationalen Datenbank

🧹 Datenbereinigung und Standardisierung

🔗 Verknüpfung der Tabellen mit Fremdschlüsseln

📊 Erstellung von Analyse-Views

📈 Entwicklung von Business-KPIs

🌍 Verbesserung der Lesbarkeit durch deutsche Kategorien

🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️🛍️

🧱 Datenmodell

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Die Datenbank umfasst folgende Kernbereiche:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 Customers – Kundendaten

📦 Orders – Bestellungen

🛍️ Order Items – einzelne Produkte pro Bestellung

💳 Payments – Zahlungsinformationen

⭐ Reviews – Kundenbewertungen

🏪 Sellers – Verkäufer

📦 Products – Produktdaten

🌐 Category Translation – Übersetzungen (EN + DE)

👉 Die geolocation-Tabelle wurde bewusst entfernt, um das Modell schlank und fokussiert zu halten.

⚙️ Technologien

🐘 PostgreSQL

💻 SQL

📂 CSV-Import (COPY)

📊 Views & Window Functions

🚀 Performance-Optimierung (Indizes)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

olist-postgresql-project/
│
├── README.md
│
├── sql/
│   ├── 01_schema.sql
│   ├── 02_tables.sql
│   ├── 03_import.sql
│   ├── 04_data_cleaning.sql
│   ├── 05_data_quality_checks.sql
│   ├── 06_constraints_indexes.sql
│   ├── 07_views.sql
│   ├── 08_analysis.sql

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


🧹 Datenbereinigung
━━━━━━━━━━━━━━━━━━━━

Folgende Schritte wurden durchgeführt:

✔ Entfernen von Duplikaten

✔ Standardisierung von Textfeldern

✔ Bereinigung von Kategorienamen

✔ Prüfung auf fehlende Verknüpfungen

✔ Plausibilitätsprüfung von Zeitdaten

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


📊 Beispielanalysen
━━━━━━━━━━━━━━━━━━━━


Das Projekt enthält verschiedene praxisnahe SQL-Analysen:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


📍 Top-Städte nach Bestellungen

💰 Gesamtumsatz

📅 Bestellungen pro Monat

⭐ Durchschnittliche Bewertungen

🚚 Lieferzeiten

🛒 Warenkorbwert

💳 Umsatz nach Zahlungsart

🏆 Top-Seller

🔁 Wiederkäufer-Analyse

💎 Customer Lifetime Value (CLV)

🔥 Highlight-Insights

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Umsatzentwicklung über Zeit analysierbar
Kundenverhalten klar segmentiert
Schwache Produktkategorien identifiziert
Verkäuferleistung vergleichbar gemacht

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Besonderheiten

🌍 Deutsche Übersetzungen für bessere Lesbarkeit

🧠 Zentrale Analyse-View (v_bestellungen)

⚡ Optimierte Performance durch Indizes

📊 Struktur bereit für BI-Tools (Power BI / Tableau)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


🚀 Einsatzmöglichkeiten
━━━━━━━━━━━━━━━━━━━━━━━━

Dieses Projekt eignet sich für:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Data Analytics Portfolio
SQL Showcase
Business Intelligence Use Cases
Vorbereitung auf Data Analyst Jobs

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📎 Datenquelle
━━━━━━━━━━━━━━━

Olist Brazilian E-Commerce Dataset (öffentlich verfügbar)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ Fazit
━━━━━━━━━━━

Dieses Projekt zeigt, wie aus unstrukturierten Rohdaten eine saubere, analysierbare Datenbank entsteht.
Durch strukturierte Modellierung, Datenbereinigung und gezielte Analysen lassen sich wertvolle Business-Insights gewinnen.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👩‍💻 Autorin
━━━━━━━━━━━

Lili Kárándi

⭐ Wenn dir das Projekt gefällt

Gerne ein ⭐ auf GitHub dalassen 😊






















