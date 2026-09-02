# 🍃 EcoSynapse Website

This directory contains the official web application for the EcoSynapse Intelligent Community Waste Management Platform, built using **Next.js 14**, **TypeScript**, **Tailwind CSS**, **Supabase**, and **Google Gemini AI**.

## 📁 Monorepo Location
This website lives inside /website in the EcoSynapse monorepo.

## 🚀 Key Features
- **Resident User Portal**: View EcoPoints wallet, EcoScore tiers, leaderboards, scan bin QR codes, and redeem rewards.
- **Collector App**: Automated priority route ordering based on fill urgency (>=80%), audio voice alerts, and bin emptying controls.
- **Admin Fleet Dashboard**: Hardware telemetry simulator, ESP32-CAM AI image classifier preview, and real-time audit log feed.
- **EcoBot AI Assistant**: Interactive AI assistant powered by Google Gemini API.

## 🛠️ Setup & Local Development

### 1. Install Dependencies
From inside the website/ directory:
`ash
cd website
npm install
`

### 2. Configure Environment Variables
Copy .env.example to .env.local:
`ash
cp .env.example .env.local
`
Fill in your Supabase credentials and Gemini API Key.

### 3. Run Development Server
`ash
npm run dev
`
Open [http://localhost:3000](http://localhost:3000) in your browser.

### 4. Build Production Bundle
`ash
npm run build
`
