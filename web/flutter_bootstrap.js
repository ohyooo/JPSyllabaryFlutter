{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const loading = document.getElementById('app-loading');

    try {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
      loading?.remove();
    } catch (error) {
      console.error('Unable to start JpSyllabary:', error);
      if (loading) {
        loading.textContent =
          'Unable to start JpSyllabary. Check the browser console for details.';
      }
    }
  },
});
