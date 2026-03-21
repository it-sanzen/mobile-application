interface FlutterBridgeWindow extends Window {
  FlutterBridge?: {
    postMessage: (message: string) => void;
  };
}

declare const window: FlutterBridgeWindow;

export function sendToFlutter(type: string, data?: unknown): void {
  if (window.FlutterBridge) {
    const message = JSON.stringify({ type, data });
    window.FlutterBridge.postMessage(message);
  } else {
    console.log('[FlutterBridge] Not in WebView, message:', type, data);
  }
}

export function notifyDesignSaved(designId: string): void {
  sendToFlutter('design-saved', { designId });
}

export function notifyBackPressed(): void {
  sendToFlutter('back-pressed');
}

export function notifyWishlistCreated(designId: string): void {
  sendToFlutter('wishlist-created', { designId });
}
