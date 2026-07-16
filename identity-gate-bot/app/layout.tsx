import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = { title: 'SKYGRID Identity Gate Bot', description: 'Consent-based pre-contact verification for MVP.' };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="en"><body>{children}</body></html>;
}
