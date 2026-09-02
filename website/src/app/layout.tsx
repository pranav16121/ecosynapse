import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'EcoSynapse — Intelligent Waste Management Ecosystem',
  description: 'Next-Gen Smart Bin Telemetry, Waste Segregation & EcoPoints Platform',
  keywords: ['Smart Dustbin', 'IoT Waste Management', 'EcoPoints', 'Waste Segregation', 'ESP32 Telemetry'],
  openGraph: {
    title: 'EcoSynapse — Intelligent Waste Management Ecosystem',
    description: 'Next-Gen Smart Bin Telemetry, Waste Segregation & EcoPoints Platform',
    url: 'https://ecosynapse.io',
    siteName: 'EcoSynapse Platform',
    images: [
      {
        url: 'https://ecosynapse.io/og-preview.png',
        width: 1200,
        height: 630,
        alt: 'EcoSynapse Smart Bin Telemetry Platform Diagram',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'EcoSynapse — Intelligent Waste Management',
    description: 'Smart Bin Telemetry & EcoPoints Ecosystem for Cities and Apartments',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // Feature #14: SEO JSON-LD Structured Data Schema
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: 'EcoSynapse',
    applicationCategory: 'EnvironmentalApplication',
    operatingSystem: 'Web, Embedded IoT',
    offers: {
      '@type': 'Offer',
      price: '0',
      priceCurrency: 'USD',
    },
    description: 'Intelligent waste management ecosystem connecting smart bins, users, and collection operations.',
  };

  return (
    <html lang="en">
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body className="antialiased selection:bg-emerald-500 selection:text-white transition-colors duration-300">
        {children}
      </body>
    </html>
  );
}
