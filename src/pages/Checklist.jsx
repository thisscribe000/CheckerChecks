import React, { useState } from 'react';
import { useKitlist } from '../context/KitlistContext';

export const Checklist = () => {
  const { activeGig, toggleItemPacked, setActiveTab } = useKitlist();
  const [completedToast, setCompletedToast] = useState(false);

  if (!activeGig) {
    return (
      <main className="max-w-[1280px] mx-auto px-margin-mobile md:px-margin-desktop py-lg pb-[100px] text-center">
        <h2 className="font-display text-display text-primary mb-md">No Gig Selected</h2>
        <button 
          onClick={() => setActiveTab('home')}
          className="px-lg py-md bg-primary text-on-primary rounded font-body-md"
        >
          Return to Dashboard
        </button>
      </main>
    );
  }

  let totalItems = 0;
  let packedItems = 0;
  let missingItemsCount = 0;

  Object.values(activeGig.items || {}).forEach(catItems => {
    catItems.forEach(item => {
      totalItems += 1;
      if (item.packed) packedItems += 1;
      if (!item.packed || item.missingAlert) missingItemsCount += 1;
    });
  });

  const percentage = totalItems > 0 ? Math.round((packedItems / totalItems) * 100) : 0;
  const isFullyPacked = totalItems > 0 && packedItems === totalItems;

  const handleReadyClick = () => {
    if (isFullyPacked) {
      setCompletedToast(true);
      setTimeout(() => {
        setCompletedToast(false);
        setActiveTab('home');
      }, 1500);
    }
  };

  return (
    <main className="flex-1 w-full max-w-[1280px] mx-auto px-margin-mobile md:px-margin-desktop py-lg pb-[120px]">
      {/* Toast Notification */}
      {completedToast && (
        <div className="fixed top-20 right-6 z-50 bg-black text-white px-lg py-md rounded-lg shadow-2xl flex items-center gap-md border border-outline animate-bounce">
          <span className="material-symbols-outlined text-emerald-400">check_circle</span>
          <span className="font-headline-md text-headline-md">Gig Manifest 100% Packed & Ready!</span>
        </div>
      )}

      {/* Gig Header */}
      <section className="mb-lg">
        <div className="flex flex-col md:flex-row md:items-start justify-between gap-md mb-sm">
          <div>
            <div className="flex items-center gap-2 mb-xs">
              <button 
                onClick={() => setActiveTab('home')}
                className="text-on-surface-variant hover:text-primary transition-colors flex items-center"
              >
                <span className="material-symbols-outlined text-[20px]">arrow_back</span>
              </button>
              <h1 className="font-display text-display text-primary">{activeGig.name}</h1>
            </div>
            <p className="font-body-lg text-body-lg text-on-surface-variant">
              {activeGig.date} · {activeGig.time} · {activeGig.location}
            </p>
          </div>

          <div className="flex items-center gap-2">
            <span className={`px-3 py-1 rounded-full font-label-caps text-label-caps ${
              isFullyPacked 
                ? 'bg-emerald-100 text-emerald-800 border border-emerald-300 font-bold' 
                : 'bg-surface-container-highest text-on-surface'
            }`}>
              {isFullyPacked ? 'READY FOR GIG' : activeGig.status}
            </span>
          </div>
        </div>

        {/* Progress Summary Card */}
        <div className="bg-surface-container-lowest border border-outline-variant p-md rounded flex flex-col md:flex-row items-start md:items-center justify-between gap-md shadow-xs">
          <div>
            <span className="font-headline-md text-headline-md text-primary block">
              {packedItems} / {totalItems} packed
            </span>
            <span className={`font-body-md text-body-md flex items-center mt-xs ${
              isFullyPacked ? 'text-emerald-700 font-medium' : 'text-error'
            }`}>
              <span className="material-symbols-outlined text-[16px] mr-1">
                {isFullyPacked ? 'check_circle' : 'warning'}
              </span>
              {isFullyPacked ? 'All gear verified and loaded' : `${totalItems - packedItems} items remaining to pack`}
            </span>
          </div>

          <div className="w-full md:w-1/2 max-w-[280px]">
            <div className="w-full bg-surface-variant rounded-full h-2.5 overflow-hidden">
              <div 
                className={`h-2.5 rounded-full transition-all duration-300 ${
                  isFullyPacked ? 'bg-emerald-600' : 'bg-primary'
                }`}
                style={{ width: `${percentage}%` }}
              ></div>
            </div>
            <span className="font-mono-sm text-mono-sm text-on-surface-variant mt-1 block text-right">
              {percentage}% Complete
            </span>
          </div>
        </div>
      </section>

      {/* Checklist Grid grouped by category */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-lg">
        {Object.entries(activeGig.items || {}).map(([category, items]) => (
          <div key={category} className="flex flex-col">
            <h2 className="font-label-caps text-label-caps text-on-surface-variant mb-md border-b border-outline-variant pb-xs uppercase tracking-wider font-bold">
              {category}
            </h2>

            <div className="flex flex-col gap-sm">
              {items.map(item => {
                const isChecked = item.packed;
                const isMissingAlert = !isChecked && item.missingAlert;

                return (
                  <label 
                    key={item.id}
                    onClick={() => toggleItemPacked(activeGig.id, category, item.id)}
                    className={`flex items-center p-md border rounded cursor-pointer transition-all duration-150 relative ${
                      isMissingAlert 
                        ? 'bg-error-container border-error hover:bg-[#ffd0cb]' 
                        : isChecked
                        ? 'bg-surface-container-lowest border-outline-variant hover:bg-surface-container-low'
                        : 'bg-surface-container-lowest border-outline hover:border-primary'
                    }`}
                  >
                    {isMissingAlert && (
                      <div className="absolute right-md top-1/2 -translate-y-1/2">
                        <span className="material-symbols-outlined text-error">error</span>
                      </div>
                    )}

                    {/* Custom Checkbox */}
                    <div className="relative w-5 h-5 mr-md shrink-0">
                      <input 
                        type="checkbox"
                        checked={isChecked}
                        onChange={() => {}} // handled by label click
                        className={`appearance-none w-5 h-5 border-2 rounded-[2px] cursor-pointer transition-colors ${
                          isChecked 
                            ? 'bg-primary border-primary' 
                            : isMissingAlert 
                            ? 'border-error bg-white' 
                            : 'border-outline bg-white'
                        }`}
                      />
                      {isChecked && (
                        <span className="material-symbols-outlined text-[14px] text-white absolute inset-0 flex items-center justify-center font-bold">
                          check
                        </span>
                      )}
                    </div>

                    {/* Item Details */}
                    <div className="flex-1 flex items-center pr-4">
                      <div className={`w-10 h-10 rounded mr-md flex items-center justify-center shrink-0 ${
                        isMissingAlert 
                          ? 'bg-surface-container-lowest border border-error/30' 
                          : 'bg-surface-variant'
                      }`}>
                        <span className={`material-symbols-outlined ${isMissingAlert ? 'text-error' : 'text-on-surface-variant'}`}>
                          {item.icon || 'inventory_2'}
                        </span>
                      </div>

                      <div>
                        <span className={`font-body-md text-body-md font-bold block ${
                          isMissingAlert ? 'text-error' : isChecked ? 'text-primary line-through opacity-70' : 'text-primary'
                        }`}>
                          {item.name}
                        </span>
                        <span className={`font-mono-sm text-mono-sm block ${
                          isMissingAlert ? 'text-error/80' : 'text-on-surface-variant'
                        }`}>
                          {isMissingAlert ? '⚠ Missing from kit' : item.detail}
                        </span>
                      </div>
                    </div>
                  </label>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      {/* Fixed Bottom Action Bar */}
      <div className="fixed bottom-0 left-0 w-full bg-surface-container-lowest border-t border-outline-variant p-md z-40 shadow-lg">
        <div className="max-w-[1280px] mx-auto flex justify-between items-center">
          <span className="font-body-md text-body-md text-on-surface-variant hidden md:block">
            {isFullyPacked ? 'All gear packed and verified!' : 'Please check off all items before proceeding.'}
          </span>

          <button
            onClick={handleReadyClick}
            disabled={!isFullyPacked}
            className={`w-full md:w-auto font-label-caps text-label-caps px-xl py-3 rounded transition-all duration-200 flex items-center justify-center cursor-pointer ${
              isFullyPacked 
                ? 'bg-emerald-600 hover:bg-emerald-700 text-white shadow-md' 
                : 'bg-surface-dim text-on-surface-variant opacity-50 cursor-not-allowed'
            }`}
          >
            {isFullyPacked ? "I'm Ready — Complete Prep" : 'Packing In Progress'}
            <span className="material-symbols-outlined ml-2 text-[18px]">
              {isFullyPacked ? 'check_circle' : 'arrow_forward'}
            </span>
          </button>
        </div>
      </div>
    </main>
  );
};
