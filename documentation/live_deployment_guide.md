# Deeba Match House - Live Cloud Deployment & Production Guide

This guide details how to transition from local PC development to 24x7 Live Cloud Production for **Deeba Match House** (Sivakasi Safety Matches).

---

## Architecture Overview

```
                               ┌────────────────────────────────┐
                               │   MongoDB Atlas Cloud Database │
                               │   (Free 512MB M0 Cluster)      │
                               └───────────────▲────────────────┘
                                               │
                                               │ mongodb+srv://...
                                               │
                     ┌─────────────────────────┴────────────────────────┐
                     │   Spring Boot REST API (Port 8080)               │
                     │   Hosted on Render.com / Railway / Cloud VPS     │
                     └────────▲────────────────────────────────▲────────┘
                              │                                │
                HTTP / JSON   │                                │ HTTP / JSON
                              │                                │
┌─────────────────────────────┴──────┐          ┌──────────────┴─────────────────────────┐
│  Deeba Mobile App (.apk)           │          │  Deeba Customer Website & Admin Portal │
│  Installed on Staff/Owner Phones   │          │  Hosted on Firebase / Vercel (Free)    │
└────────────────────────────────────┘          └────────────────────────────────────────┘
```

---

## 1. Cloud Database Setup (MongoDB Atlas - 100% Free)

1. Open [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) and sign in.
2. Click **"Build a Database"** -> Choose the **M0 Free Cluster** -> Region: **AWS / Mumbai (ap-south-1)** or **Singapore**.
3. **Database Access**:
   - Create a user: `deeba_admin`
   - Set a secure password: e.g. `DeebaMatch2026!`
4. **Network Access**:
   - Add IP Access: `0.0.0.0/0` (Allow access from anywhere).
5. **Get Connection String**:
   - Click **Connect** -> **Drivers** -> Copy the URI:
     ```
     mongodb+srv://deeba_admin:DeebaMatch2026!@cluster0.abcde.mongodb.net/deeba_match_house?retryWrites=true&w=majority
     ```
6. **Connect Local PC or Cloud Backend**:
   - In `backend/spring_boot_api/src/main/resources/application.yml`, set the `MONGODB_URI` environment variable, or paste it directly into the URI field.

---

## 2. Spring Boot Backend Deployment (Render.com / Railway)

### Deploying on Render (Free Web Service)
1. Push this repository to GitHub or connect via Render dashboard.
2. Click **New +** -> **Web Service**.
3. Choose the repository and select:
   - **Environment**: Docker
   - **Docker Context**: `backend/spring_boot_api`
   - **Dockerfile Path**: `backend/spring_boot_api/Dockerfile`
   - **Instance Type**: Free
4. In **Environment Variables**, add:
   - `PORT`: `8080`
   - `MONGODB_URI`: `<Your MongoDB Atlas Connection String>`
5. Click **Create Web Service**. In ~3 minutes, your live backend URL is ready:
   `https://deeba-match-api.onrender.com`

---

## 3. Customer Website & Admin Portal Web Hosting (Firebase / Vercel - Free)

The web bundle is compiled to `build/web/`.

### Deploying on Firebase Hosting (100% Free with Google SSL)
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
# Select existing project or create new
# Public directory: build/web
# Single-page app: Yes
firebase deploy --only hosting
```
Your website is live at `https://deeba-match-house.web.app`!

### Deploying on Vercel
```bash
npm install -g vercel
vercel deploy --prod
```

---

## 4. Staff Mobile Phone Setup

1. Copy [app-release.apk](file:///c:/Users/Admin/Desktop/deepamatchbox/build/app/outputs/flutter-apk/app-release.apk) to the phone via USB or WhatsApp.
2. Tap to install the app.
3. Open the app -> On the Login Screen or Top Bar, tap **Server Settings (`⚙️`)**.
4. Enter your Live Cloud API domain (e.g. `https://deeba-match-api.onrender.com`) or Factory Wi-Fi IP (`http://192.168.1.170:8080`).
5. Tap **Test & Save**.
6. Login with Staff credentials (`staff` / custom staff login) or Admin credentials (`admin` / `admin123`).

