import React, { useState } from 'react';
import { useKitlist } from '../context/KitlistContext';

export const Navigation = () => {
  const { activeTab, setActiveTab } = useKitlist();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <>
      {/* TopAppBar */}
      <header className="fixed top-0 left-0 w-full z-50 flex justify-between items-center px-margin-mobile md:px-margin-desktop h-16 bg-surface border-b border-outline-variant transition-colors">
        <div className="flex items-center gap-md">
          <button 
            aria-label="Menu" 
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="hover:opacity-80 transition-opacity flex items-center justify-center p-2 rounded-full text-primary"
          >
            <span className="material-symbols-outlined">menu</span>
          </button>
          
          <button 
            onClick={() => setActiveTab('home')}
            className="font-headline-lg text-headline-lg font-bold tracking-tighter text-primary cursor-pointer"
          >
            KITLIST
          </button>
        </div>

        {/* Desktop Navigation Links */}
        <div className="hidden md:flex items-center gap-lg h-full">
          <button
            onClick={() => setActiveTab('home')}
            className={`font-label-caps text-label-caps h-full flex items-center px-2 border-b-2 transition-colors ${
              activeTab === 'home' || activeTab === 'checklist'
                ? 'border-primary text-primary font-bold' 
                : 'border-transparent text-on-surface-variant hover:text-primary'
            }`}
          >
            GIGS
          </button>

          <button
            onClick={() => setActiveTab('inventory')}
            className={`font-label-caps text-label-caps h-full flex items-center px-2 border-b-2 transition-colors ${
              activeTab === 'inventory' 
                ? 'border-primary text-primary font-bold' 
                : 'border-transparent text-on-surface-variant hover:text-primary'
            }`}
          >
            INVENTORY
          </button>

          <button
            onClick={() => setActiveTab('new-gig')}
            className={`font-label-caps text-label-caps h-full flex items-center px-2 border-b-2 transition-colors ${
              activeTab === 'new-gig' 
                ? 'border-primary text-primary font-bold' 
                : 'border-transparent text-on-surface-variant hover:text-primary'
            }`}
          >
            + NEW GIG
          </button>
        </div>

        {/* Profile Avatar Badge */}
        <div className="flex items-center gap-sm">
          <button 
            onClick={() => setActiveTab('settings')}
            className="w-8 h-8 rounded-full overflow-hidden u-border bg-surface-variant flex items-center justify-center hover:opacity-80 transition-opacity"
            title="Profile & Settings"
          >
            <span className="font-label-caps text-label-caps text-primary font-bold">PR</span>
          </button>
        </div>
      </header>

      {/* Mobile Drawer Menu Overlay */}
      {mobileMenuOpen && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex md:hidden" onClick={() => setMobileMenuOpen(false)}>
          <div className="w-64 bg-surface h-full p-6 flex flex-col justify-between shadow-2xl border-r border-outline-variant" onClick={e => e.stopPropagation()}>
            <div className="flex flex-col gap-6">
              <div className="flex items-center justify-between pb-4 border-b border-outline-variant">
                <span className="font-headline-lg text-headline-lg font-bold tracking-tighter text-primary">KITLIST</span>
                <button onClick={() => setMobileMenuOpen(false)} className="text-primary">
                  <span className="material-symbols-outlined">close</span>
                </button>
              </div>

              <div className="flex flex-col gap-2">
                <button 
                  onClick={() => { setActiveTab('home'); setMobileMenuOpen(false); }}
                  className={`flex items-center gap-3 px-3 py-2.5 rounded font-headline-md text-headline-md text-left ${activeTab === 'home' ? 'bg-primary text-on-primary font-semibold' : 'text-primary hover:bg-surface-container-low'}`}
                >
                  <span className="material-symbols-outlined">event_note</span>
                  Upcoming Gigs
                </button>

                <button 
                  onClick={() => { setActiveTab('inventory'); setMobileMenuOpen(false); }}
                  className={`flex items-center gap-3 px-3 py-2.5 rounded font-headline-md text-headline-md text-left ${activeTab === 'inventory' ? 'bg-primary text-on-primary font-semibold' : 'text-primary hover:bg-surface-container-low'}`}
                >
                  <span className="material-symbols-outlined">inventory_2</span>
                  Gear Inventory
                </button>

                <button 
                  onClick={() => { setActiveTab('new-gig'); setMobileMenuOpen(false); }}
                  className={`flex items-center gap-3 px-3 py-2.5 rounded font-headline-md text-headline-md text-left ${activeTab === 'new-gig' ? 'bg-primary text-on-primary font-semibold' : 'text-primary hover:bg-surface-container-low'}`}
                >
                  <span className="material-symbols-outlined">add_circle</span>
                  Create New Gig
                </button>
              </div>
            </div>

            <div className="pt-4 border-t border-outline-variant font-mono-sm text-mono-sm text-on-surface-variant flex flex-col gap-1">
              <span>Stitch Minimalist v1.0</span>
              <span className="text-[10px]">Stark Monochrome UI</span>
            </div>
          </div>
        </div>
      )}

      {/* Mobile Bottom Navigation Bar */}
      <nav className="fixed bottom-0 left-0 w-full z-40 flex justify-around items-center px-4 pb-safe bg-surface border-t border-outline-variant md:hidden">
        {/* Tab: Gigs */}
        <button
          onClick={() => setActiveTab('home')}
          className={`flex flex-col items-center justify-center pt-2 pb-2 w-full max-w-[80px] transition-colors ${
            activeTab === 'home' || activeTab === 'checklist'
              ? 'text-primary border-t-2 border-primary font-semibold'
              : 'text-on-surface-variant hover:text-primary'
          }`}
        >
          <span className="material-symbols-outlined mb-1 fill-1">event_note</span>
          <span className="font-label-caps text-label-caps">Gigs</span>
        </button>

        {/* Tab: Inventory */}
        <button
          onClick={() => setActiveTab('inventory')}
          className={`flex flex-col items-center justify-center pt-2 pb-2 w-full max-w-[80px] transition-colors ${
            activeTab === 'inventory'
              ? 'text-primary border-t-2 border-primary font-semibold'
              : 'text-on-surface-variant hover:text-primary'
          }`}
        >
          <span className="material-symbols-outlined mb-1">inventory_2</span>
          <span className="font-label-caps text-label-caps">Inventory</span>
        </button>

        {/* Tab: New Gig */}
        <button
          onClick={() => setActiveTab('new-gig')}
          className={`flex flex-col items-center justify-center pt-2 pb-2 w-full max-w-[80px] transition-colors ${
            activeTab === 'new-gig'
              ? 'text-primary border-t-2 border-primary font-semibold'
              : 'text-on-surface-variant hover:text-primary'
          }`}
        >
          <span className="material-symbols-outlined mb-1">add_circle</span>
          <span className="font-label-caps text-label-caps">New Gig</span>
        </button>
      </nav>
    </>
  );
};
