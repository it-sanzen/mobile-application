import { useState } from 'react';
import { PanelLeftClose, PanelLeft, ChevronUp, ChevronDown } from 'lucide-react';
import TopBar from './TopBar';
import CatalogPanel from './CatalogPanel';
import ActionToolbar from './ActionToolbar';
import RoomScene from '../scene/RoomScene';

export default function DesignerLayout() {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [mobileDrawerOpen, setMobileDrawerOpen] = useState(false);

  return (
    <div className="flex flex-col h-screen w-screen overflow-hidden bg-gray-100">
      {/* Top bar */}
      <TopBar />

      {/* Main area */}
      <div className="flex flex-1 min-h-0">
        {/* Left sidebar - catalog panel (desktop) */}
        <div
          className={`shrink-0 transition-all duration-300 ease-in-out overflow-hidden border-r border-gray-200 ${
            sidebarOpen ? 'w-[380px]' : 'w-0'
          } hidden md:block`}
        >
          <div className="w-[380px] h-full overflow-y-auto">
            <CatalogPanel />
          </div>
        </div>

        {/* Sidebar toggle button (desktop) */}
        <button
          onClick={() => setSidebarOpen(!sidebarOpen)}
          className="hidden md:flex absolute left-0 top-1/2 -translate-y-1/2 z-30 items-center justify-center w-6 h-12 bg-white border border-gray-200 border-l-0 rounded-r-lg shadow-sm hover:bg-gray-50 transition-colors"
          style={{ left: sidebarOpen ? '380px' : '0px' }}
        >
          {sidebarOpen ? (
            <PanelLeftClose size={14} className="text-gray-500" />
          ) : (
            <PanelLeft size={14} className="text-gray-500" />
          )}
        </button>

        {/* Center 3D viewport */}
        <div className="flex-1 relative">
          <RoomScene />

          {/* Floating action toolbar - inside the 3D viewport container */}
          <ActionToolbar />

          {/* Mobile catalog drawer */}
          <div className="md:hidden absolute bottom-0 left-0 right-0 z-10">
            {/* Toggle handle */}
            <button
              onClick={() => setMobileDrawerOpen(!mobileDrawerOpen)}
              className="w-full flex items-center justify-center gap-1 py-1.5 bg-white border-t border-gray-200 text-gray-500 text-xs font-medium"
            >
              {mobileDrawerOpen ? (
                <>
                  <ChevronDown size={14} />
                  Hide Catalog
                </>
              ) : (
                <>
                  <ChevronUp size={14} />
                  Browse Furniture
                </>
              )}
            </button>
            {/* Drawer content */}
            <div
              className={`bg-white border-t border-gray-200 overflow-hidden transition-all duration-300 ${
                mobileDrawerOpen ? 'h-64' : 'h-0'
              }`}
            >
              <div className="h-64 overflow-y-auto">
                <CatalogPanel />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
