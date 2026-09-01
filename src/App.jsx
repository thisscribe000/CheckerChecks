import React from 'react';
import { KitlistProvider, useKitlist } from './context/KitlistContext';
import { Navigation } from './components/Navigation';
import { Home } from './pages/Home';
import { NewGig } from './pages/NewGig';
import { Checklist } from './pages/Checklist';
import { Inventory } from './pages/Inventory';

const AppContent = () => {
  const { activeTab } = useKitlist();

  return (
    <div className="min-h-screen bg-surface text-on-surface flex flex-col font-body-md selection:bg-primary selection:text-on-primary">
      <Navigation />

      {activeTab === 'home' && <Home />}
      {activeTab === 'new-gig' && <NewGig />}
      {activeTab === 'checklist' && <Checklist />}
      {activeTab === 'inventory' && <Inventory />}
      {activeTab === 'settings' && (
        <main className="max-w-[800px] mx-auto px-margin-mobile md:px-margin-desktop pt-[104px] pb-[100px] flex flex-col gap-lg">
          <h1 className="font-display text-display text-primary">Settings & Profile</h1>
          <div className="bg-surface-container-lowest border border-outline-variant rounded p-lg flex flex-col gap-md">
            <div className="flex items-center gap-md pb-md border-b border-outline-variant">
              <div className="w-16 h-16 rounded-full u-border bg-surface-variant flex items-center justify-center font-headline-lg text-headline-lg font-bold text-primary">
                PR
              </div>
              <div>
                <h3 className="font-headline-md text-headline-md font-bold text-primary">Alex Mercer</h3>
                <p className="font-body-md text-body-md text-on-surface-variant">alex.mercer@creative.studio</p>
                <span className="font-mono-sm text-mono-sm text-primary font-semibold">Pro Creative Account</span>
              </div>
            </div>

            <div className="flex flex-col gap-sm">
              <h4 className="font-label-caps text-label-caps text-on-surface-variant">DESIGN SYSTEM PREFERENCES</h4>
              <div className="flex items-center justify-between p-sm bg-surface-container-low rounded border border-outline-variant">
                <span className="font-body-md text-body-md text-primary">Minimalist High-Contrast Palette</span>
                <span className="font-mono-sm text-mono-sm text-emerald-700 font-bold">ACTIVE</span>
              </div>
              <div className="flex items-center justify-between p-sm bg-surface-container-low rounded border border-outline-variant">
                <span className="font-body-md text-body-md text-primary">Stitch AI Integration</span>
                <span className="font-mono-sm text-mono-sm text-emerald-700 font-bold">CONNECTED</span>
              </div>
            </div>
          </div>
        </main>
      )}
    </div>
  );
};

export function App() {
  return (
    <KitlistProvider>
      <AppContent />
    </KitlistProvider>
  );
}

export default App;
