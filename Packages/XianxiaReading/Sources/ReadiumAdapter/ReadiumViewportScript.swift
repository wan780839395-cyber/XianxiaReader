/// Adjust Readium's existing media safeguard to the actual WKWebView viewport.
/// EPUB meta viewport device-height can make CSS vh larger than innerHeight
/// after native safe-area/content insets. This never rewrites the publication.
enum ReadiumViewportScript {
    static let mediaBounds = """
    (() => {
      const root = document.documentElement;
      function updateMediaBounds() {
        // Vertical writing uses Readium's width-based media limit.
        if (getComputedStyle(root).writingMode.startsWith('vertical')) return;
        // Keep ReadiumCSS's 95% allowance for captions, using the rendered
        // height instead of CSS vh. Do not change author width/aspect/fit.
        if (!Number.isFinite(innerHeight) || innerHeight <= 0) return;
        const height = Math.floor(innerHeight * 0.95) + 'px';
        if (root.style.getPropertyValue('--RS__maxMediaHeight') !== height) {
          root.style.setProperty('--RS__maxMediaHeight', height);
        }
      }
      addEventListener('resize', updateMediaBounds);
      window.visualViewport?.addEventListener('resize', updateMediaBounds);
      updateMediaBounds();
    })();
    """
}
