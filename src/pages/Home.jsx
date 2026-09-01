import React from 'react';
import { useKitlist } from '../context/KitlistContext';

export const Home = () => {
  const { gigs, setActiveTab, setActiveGigId } = useKitlist();

  const getGigStats = (gig) => {
    let total = 0;
    let packed = 0;
    let missingAlerts = 0;

    Object.values(gig.items || {}).forEach(catItems => {
      catItems.forEach(item => {
        total += 1;
        if (item.packed) packed += 1;
        if (item.missingAlert) missingAlerts += 1;
      });
    });

    const percentage = total > 0 ? Math.round((packed / total) * 100) : 0;
    return { total, packed, percentage, missingAlerts };
  };

  const handleGigClick = (gigId) => {
    setActiveGigId(gigId);
    setActiveTab('checklist');
  };

  return (
    <main className="max-w-[1280px] mx-auto px-margin-mobile md:px-margin-desktop py-lg pb-[100px]">
      {/* Header Section */}
      <div className="flex flex-col md:flex-row md:justify-between md:items-end gap-md mb-xl">
        <div>
          <h1 className="font-display text-display text-primary mb-xs">Good morning, Alex.</h1>
          <p className="font-body-lg text-body-lg text-on-surface-variant">Here is your schedule and prep status.</p>
        </div>

        <button 
          onClick={() => setActiveTab('new-gig')}
          className="bg-primary text-on-primary font-body-md text-body-md px-lg py-md rounded hover:bg-inverse-surface transition-colors flex items-center justify-center gap-xs cursor-pointer shadow-xs"
        >
          <span className="material-symbols-outlined text-[20px]">add</span>
          New Gig
        </button>
      </div>

      {/* Upcoming Gigs Section */}
      <section>
        <div className="flex items-center justify-between mb-md">
          <h2 className="font-headline-md text-headline-md text-primary">Upcoming Gigs</h2>
          <span className="font-mono-sm text-mono-sm text-on-surface-variant">{gigs.length} scheduled</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-md">
          {gigs.map(gig => {
            const { total, packed, percentage, missingAlerts } = getGigStats(gig);
            return (
              <div 
                key={gig.id}
                onClick={() => handleGigClick(gig.id)}
                className="bg-surface-container-lowest u-border rounded p-md hover:border-primary transition-all duration-150 cursor-pointer flex flex-col justify-between min-h-[180px] group shadow-xs hover:shadow-md"
              >
                <div>
                  <div className="flex justify-between items-start mb-sm">
                    <h3 className="font-headline-md text-headline-md text-primary group-hover:underline">
                      {gig.name}
                    </h3>

                    <div className="flex items-center gap-1.5 bg-surface-container-low px-sm py-xs rounded">
                      <span className={`w-1.5 h-1.5 rounded-full ${
                        percentage === 100 ? 'bg-emerald-600' : 'bg-primary'
                      }`}></span>
                      <span className="font-label-caps text-label-caps text-primary uppercase">
                        {percentage === 100 ? 'READY' : gig.status}
                      </span>
                    </div>
                  </div>

                  <p className="font-body-md text-body-md text-on-surface-variant flex items-center gap-xs">
                    <span className="material-symbols-outlined text-[16px]">calendar_month</span>
                    {gig.date} · {gig.location}
                  </p>

                  {missingAlerts > 0 && (
                    <div className="mt-xs inline-flex items-center gap-1 text-error text-[11px] font-mono-sm font-semibold">
                      <span className="material-symbols-outlined text-[14px]">warning</span>
                      {missingAlerts} item{missingAlerts > 1 ? 's' : ''} missing from kit
                    </div>
                  )}
                </div>

                <div className="mt-lg">
                  <div className="flex justify-between font-mono-sm text-mono-sm text-on-surface-variant mb-xs">
                    <span>Progress</span>
                    <span className="font-bold text-primary">{packed} / {total} packed</span>
                  </div>

                  <div className="w-full h-1.5 bg-surface-variant rounded-full overflow-hidden">
                    <div 
                      className={`h-full transition-all duration-300 ${percentage === 100 ? 'bg-emerald-600' : 'bg-primary'}`} 
                      style={{ width: `${percentage}%` }}
                    ></div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </section>

      {/* Quick Access Utility Section */}
      <section className="mt-xl pt-lg border-t border-outline-variant grid grid-cols-1 md:grid-cols-2 gap-md">
        <div className="p-md bg-surface-container-lowest u-border rounded flex items-center justify-between">
          <div>
            <h4 className="font-headline-md text-headline-md text-primary mb-xs">Gear Library</h4>
            <p className="font-body-md text-body-md text-on-surface-variant">View and edit your camera & audio inventory.</p>
          </div>
          <button 
            onClick={() => setActiveTab('inventory')}
            className="px-md py-sm bg-surface-container-low border border-outline-variant rounded font-label-caps text-label-caps hover:bg-primary hover:text-on-primary transition-colors cursor-pointer"
          >
            VIEW INVENTORY
          </button>
        </div>

        <div className="p-md bg-surface-container-lowest u-border rounded flex items-center justify-between">
          <div>
            <h4 className="font-headline-md text-headline-md text-primary mb-xs">AI Manifest Assistant</h4>
            <p className="font-body-md text-body-md text-on-surface-variant">Auto-generate equipment lists for unique shoots.</p>
          </div>
          <button 
            onClick={() => setActiveTab('new-gig')}
            className="px-md py-sm bg-surface-container-low border border-outline-variant rounded font-label-caps text-label-caps hover:bg-primary hover:text-on-primary transition-colors cursor-pointer flex items-center gap-1"
          >
            <span className="material-symbols-outlined text-[16px]">auto_awesome</span>
            START AI
          </button>
        </div>
      </section>
    </main>
  );
};
