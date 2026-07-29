import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'kana_data.dart';
import 'strings.dart';

const _seed = Color(0xff83a55d);

class JpSyllabaryApp extends StatelessWidget {
  const JpSyllabaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JpSyllabary',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _AppScrollBehavior(),
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'SourceHanSansSC',
      scaffoldBackgroundColor: scheme.surface,
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
  };
}

enum AppRoute { single, table, twister, source }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppRoute route = AppRoute.single;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(
      Localizations.localeOf(context).languageCode == 'zh',
    );
    return Scaffold(
      drawer: NavigationDrawer(
        selectedIndex: route.index,
        onDestinationSelected: (index) {
          setState(() => route = AppRoute.values[index]);
          Navigator.pop(context);
        },
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 12),
            child: Text(
              strings.appName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.home),
            label: Text(strings.single),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.list_alt),
            label: Text(strings.table),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.change_history),
            label: Text(strings.twister),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.data_object),
            label: Text(strings.source),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (route) {
          AppRoute.single => SingleScreen(strings: strings),
          AppRoute.table => KanaTableScreen(strings: strings),
          AppRoute.twister => TwisterScreen(strings: strings),
          AppRoute.source => SourceScreen(strings: strings),
        },
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: IconButton(
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      onPressed: () => Scaffold.of(context).openDrawer(),
      icon: const Icon(Icons.menu),
    ),
  );
}

class SingleScreen extends StatefulWidget {
  const SingleScreen({required this.strings, super.key});

  final AppStrings strings;

  @override
  State<SingleScreen> createState() => _SingleScreenState();
}

class _SingleScreenState extends State<SingleScreen> {
  final _random = Random();
  late KanaEntry entry;
  bool revealed = false;
  int? previousIndex;

  @override
  void initState() {
    super.initState();
    entry = allKana.first;
  }

  void _next() {
    var index = _random.nextInt(allKana.length);
    while (allKana.length > 1 && index == previousIndex) {
      index = _random.nextInt(allKana.length);
    }
    setState(() {
      previousIndex = index;
      entry = allKana[index];
      revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final divider = Divider(height: 1, color: Theme.of(context).dividerColor);
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(8), child: MenuButton()),
        Expanded(
          child: Center(
            child: Text(
              widget.strings.group(entry.group),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        divider,
        Expanded(
          flex: 2,
          child: Center(
            child: Text(entry.kana, style: const TextStyle(fontSize: 80)),
          ),
        ),
        divider,
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: () => setState(() => revealed = !revealed),
            child: Center(
              child: Text(
                revealed ? entry.romaji : widget.strings.revealHint,
                style: TextStyle(
                  fontSize: revealed ? 72 : 16,
                  color: revealed ? null : Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
        ),
        divider,
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: _next,
            child: Center(
              child: Image.asset(
                'assets/round.png',
                width: 92,
                height: 92,
                semanticLabel: widget.strings.next,
                errorBuilder: (_, _, _) => const Icon(Icons.refresh, size: 80),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class KanaTableScreen extends StatefulWidget {
  const KanaTableScreen({required this.strings, super.key});

  final AppStrings strings;

  @override
  State<KanaTableScreen> createState() => _KanaTableScreenState();
}

class _KanaTableScreenState extends State<KanaTableScreen>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  var normalOrder = List.generate(hiragana.length, (index) => index);
  var sonantOrder = List.generate(sonant.length, (index) => index);
  int romajiSource = 0;
  bool actionsOpen = false;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this)
      ..addListener(_tabChanged);
  }

  void _tabChanged() {
    if (controller.index == 1) romajiSource = 0;
    if (controller.index == 3) romajiSource = 1;
    if (!controller.indexIsChanging) setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Row(
              children: [
                const Padding(padding: EdgeInsets.all(4), child: MenuButton()),
                Expanded(
                  child: TabBar(
                    controller: controller,
                    tabs: [
                      Tab(text: widget.strings.hiragana),
                      Tab(text: widget.strings.katakana),
                      Tab(text: widget.strings.romaji),
                      Tab(text: widget.strings.sonant),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: controller,
                children: [
                  KanaGrid(chars: hiragana, hints: romaji, order: normalOrder),
                  KanaGrid(chars: katakana, hints: romaji, order: normalOrder),
                  KanaGrid(
                    chars: romajiSource == 0 ? romaji : sonantRomaji,
                    hints: romajiSource == 0 ? romaji : sonantRomaji,
                    order: romajiSource == 0 ? normalOrder : sonantOrder,
                  ),
                  KanaGrid(
                    chars: sonant,
                    hints: sonantRomaji,
                    order: sonantOrder,
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (actionsOpen) ...[
                _MiniAction(
                  label: widget.strings.shuffle,
                  icon: Icons.shuffle,
                  onPressed: () => setState(() {
                    normalOrder.shuffle();
                    sonantOrder.shuffle();
                    actionsOpen = false;
                  }),
                ),
                const SizedBox(height: 8),
                _MiniAction(
                  label: widget.strings.order,
                  icon: Icons.format_list_numbered,
                  onPressed: () => setState(() {
                    normalOrder = List.generate(
                      hiragana.length,
                      (index) => index,
                    );
                    sonantOrder = List.generate(
                      sonant.length,
                      (index) => index,
                    );
                    actionsOpen = false;
                  }),
                ),
                const SizedBox(height: 8),
              ],
              FloatingActionButton(
                onPressed: () => setState(() => actionsOpen = !actionsOpen),
                child: AnimatedRotation(
                  turns: actionsOpen ? .125 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Material(
        borderRadius: BorderRadius.circular(6),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(label),
        ),
      ),
      const SizedBox(width: 10),
      FloatingActionButton.small(onPressed: onPressed, child: Icon(icon)),
    ],
  );
}

class KanaGrid extends StatefulWidget {
  const KanaGrid({
    required this.chars,
    required this.hints,
    required this.order,
    super.key,
  });

  final List<String> chars;
  final List<String> hints;
  final List<int> order;

  @override
  State<KanaGrid> createState() => _KanaGridState();
}

class _KanaGridState extends State<KanaGrid> {
  int? revealed;

  void _reveal(int index) {
    setState(() => revealed = index);
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted && revealed == index) setState(() => revealed = null);
    });
  }

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.all(1),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 5,
    ),
    itemCount: widget.order.length,
    itemBuilder: (context, position) {
      final index = widget.order[position];
      return InkWell(
        onTap: () => _reveal(index),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: .4,
            ),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              revealed == index ? widget.hints[index] : widget.chars[index],
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
      );
    },
  );
}

class TwisterScreen extends StatefulWidget {
  const TwisterScreen({required this.strings, super.key});

  final AppStrings strings;

  @override
  State<TwisterScreen> createState() => _TwisterScreenState();
}

class _TwisterScreenState extends State<TwisterScreen> {
  late final controllers = List.generate(
    twisterRows.length,
    (_) => PageController(),
  );

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _reset() {
    for (final controller in controllers) {
      if (controller.hasClients) {
        controller.animateToPage(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Padding(padding: EdgeInsets.all(8), child: MenuButton()),
      const Divider(height: 1),
      for (var row = 0; row < twisterRows.length; row++) ...[
        Expanded(
          child: PageView.builder(
            controller: controllers[row],
            itemCount: 3,
            itemBuilder: (_, page) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    twisterRows[row][page].join(),
                    maxLines: 1,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
      Expanded(
        flex: 3,
        child: InkWell(
          onTap: _reset,
          child: Center(
            child: Image.asset(
              'assets/round.png',
              width: 88,
              semanticLabel: widget.strings.next,
            ),
          ),
        ),
      ),
    ],
  );
}

class SourceScreen extends StatelessWidget {
  const SourceScreen({required this.strings, super.key});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(padding: EdgeInsets.all(8), child: MenuButton()),
      const Divider(height: 1),
      ListTile(
        leading: const Icon(Icons.code),
        title: const Text('ohyooo/JPSyllabaryFlutter'),
        subtitle: Text(strings.openRepository),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => launchUrl(
          Uri.parse('https://github.com/ohyooo/JPSyllabaryFlutter'),
        ),
      ),
    ],
  );
}
