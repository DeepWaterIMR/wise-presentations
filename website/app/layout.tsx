import type { Metadata } from "next";
import "./globals.css";

const siteUrl = "https://deepwaterimr.github.io/wise-presentations/";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: "wise-presentations | Fiskwise",
  description: "Scientific presentation layouts and reproducible figure workflows from the Fiskwise toolkit.",
  icons: {
    icon: "fiskwise/favicon.svg",
  },
  openGraph: {
    type: "website",
    url: siteUrl,
    title: "wise-presentations",
    description: "Predefined Quarto layouts for scientific claims, figures, tables, and explanations.",
    images: [{ url: "og.png", width: 1200, height: 630, alt: "Abstract bathymetric illustration for the Fiskwise wise-presentations" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "wise-presentations",
    description: "Predefined Quarto layouts for scientific claims, figures, tables, and explanations.",
    images: ["og.png"],
  },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
