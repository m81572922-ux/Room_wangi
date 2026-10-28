import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const RWGacorApp());

const bg = Color(0xFF0D0A18);
const panel = Color(0xFF211633);
const purple = Color(0xFFB76CFF);
const pink = Color(0xFFFF4FCB);
const cyan = Color(0xFF4DE6FF);

class RWGacorApp extends StatelessWidget {
  const RWGacorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RW Gacor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _shizuku = MethodChannel('rw_gacor/shizuku');
  bool shizukuRunning = false;
  bool shizukuPermission = false;
  bool shizukuChecking = true;
  String shizukuMessage = 'Memeriksa status Shizuku...';

  @override
  void initState() {
    super.initState();
    _checkShizuku();
  }

  Future<void> _openMlbb() async {
    final game = Uri.parse(
      'intent://launch#Intent;package=com.mobile.legends;end',
    );
    try {
      final opened = await launchUrl(
        game,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        setStatus('MLBB tidak terbuka. Pastikan game sudah terpasang.');
      } else if (mounted) {
        setStatus('Permintaan membuka MLBB dikirim.');
      }
    } catch (_) {
      if (mounted) {
        setStatus('MLBB tidak terbuka. Pastikan game sudah terpasang.');
      }
    }
  }

  Future<void> _checkShizuku() async {
    try {
      final running = await _shizuku.invokeMethod<bool>('isServiceRunning') ?? false;
      final permission = running
          ? (await _shizuku.invokeMethod<bool>('hasPermission') ?? false)
          : false;
      if (!mounted) return;
      setState(() {
        shizukuRunning = running;
        shizukuPermission = permission;
        shizukuChecking = false;
        shizukuMessage = !running
            ? 'Shizuku belum aktif. Jalankan Shizuku terlebih dahulu.'
            : (!permission
                ? 'Shizuku aktif, tetapi izin RW GACOR belum diberikan.'
                : 'Shizuku aktif dan izin sudah diberikan.');
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        shizukuChecking = false;
        shizukuMessage = 'Pemeriksaan Shizuku gagal: ${e.message ?? e.code}';
      });
    } on MissingPluginException {
      if (!mounted) return;
      setState(() {
        shizukuChecking = false;
        shizukuMessage = 'Dukungan Shizuku belum tersedia pada build ini.';
      });
    }
  }

  Future<void> _requestShizukuPermission() async {
    try {
      final granted = await _shizuku.invokeMethod<bool>('requestPermission') ?? false;
      await _checkShizuku();
      if (!mounted) return;
      setStatus(granted
          ? 'SHIZUKU • Izin diberikan'
          : 'SHIZUKU • Izin belum diberikan');
    } on PlatformException catch (e) {
      if (!mounted) return;
      setStatus('SHIZUKU ERROR • ${e.message ?? e.code}');
    }
  }

  int selected = 0;
  bool floatingMenuOpen = true;
  bool compactMode = false;
  bool notifications = true;
  String status = 'SIAP • Pilih menu untuk mulai';

  final pages = const [
    'Dashboard',
    'Skin Gallery',
    'Ranked Notes',
    'Bot Practice',
    'Network Check',
    'Settings',
  ];

  void setStatus(String value) => setState(() => status = value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _header(),
                _statusBar(),
                Expanded(
                  child: shizukuPermission
                      ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _pageBody(key: ValueKey(selected)),
                        )
                      : _shizukuGate(),
                ),
                if (shizukuPermission) _bottomNav(),
              ],
            ),
            if (floatingMenuOpen)
              Positioned(
                right: 12,
                top: 126,
                child: _floatingPanel(),
              )
            else
              Positioned(
                right: 14,
                top: 138,
                child: FloatingActionButton.small(
                  heroTag: 'open-float',
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  onPressed: () => setState(() => floatingMenuOpen = true),
                  child: const Icon(Icons.bolt),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _shizukuGate() => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: purple.withOpacity(.45)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security_rounded, size: 58, color: purple),
                const SizedBox(height: 14),
                const Text(
                  'SHIZUKU REQUIRED',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(shizukuChecking ? 'Memeriksa status Shizuku...' : shizukuMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, height: 1.4)),
                const SizedBox(height: 18),
                if (!shizukuRunning && !shizukuChecking)
                  const Text(
                    'Buka aplikasi Shizuku dan mulai layanan melalui Wireless debugging atau root. Setelah aktif, kembali ke RW GACOR.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: cyan, height: 1.4),
                  ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: shizukuChecking ? null : _checkShizuku,
                    icon: const Icon(Icons.refresh),
                    label: const Text('CEK ULANG SHIZUKU'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: shizukuChecking || !shizukuRunning
                        ? null
                        : _requestShizukuPermission,
                    icon: const Icon(Icons.verified_user_outlined),
                    label: const Text('MINTA IZIN SHIZUKU'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Shizuku hanya menjadi pemeriksaan izin untuk fitur lokal aplikasi. Ini tidak membuka skin MLBB atau mengubah matchmaking.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.white54, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [purple, pink]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: purple.withOpacity(.28),
                    blurRadius: 18,
                  )
                ],
              ),
              child: const Icon(Icons.bolt_rounded, size: 34, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RW GACOR',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      )),
                  SizedBox(height: 2),
                  Text('FLUTTER COMPANION • STARTER',
                      style: TextStyle(
                          fontSize: 10,
                          color: cyan,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Buka MLBB',
              onPressed: _openMlbb,
              icon: const Icon(Icons.sports_esports, color: cyan),
            ),
            IconButton(
              tooltip: 'Buka/tutup menu melayang',
              onPressed: () =>
                  setState(() => floatingMenuOpen = !floatingMenuOpen),
              icon: Icon(
                floatingMenuOpen ? Icons.layers_clear : Icons.layers,
                color: purple,
              ),
            )
          ],
        ),
      );

  Widget _statusBar() => Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: purple.withOpacity(.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 9, color: cyan),
            const SizedBox(width: 8),
            Expanded(
              child: Text(status,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ),
          ],
        ),
      );

  Widget _pageBody({Key? key}) => SingleChildScrollView(
        key: key,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        child: switch (selected) {
          0 => _dashboard(),
          1 => _skinGallery(),
          2 => _rankedNotes(),
          3 => _networkCheck(),
          _ => _settings(),
        },
      );

  Widget _dashboard() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heroCard(),
          const SizedBox(height: 16),
          const Text('QUICK MENU',
              style: TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              _quickTile(Icons.checkroom, 'Skin Gallery', 'Katalog & favorit',
                  () => setState(() => selected = 1)),
              _quickTile(Icons.emoji_events, 'Ranked Notes', 'Draft & strategi',
                  () => setState(() => selected = 2)),
              _quickTile(Icons.network_check, 'Network Check', 'Tes konektivitas',
                  () => setState(() => selected = 3)),
              _quickTile(Icons.tune, 'Settings', 'Tema & menu',
                  () => setState(() => selected = 4)),
            ],
          ),
          const SizedBox(height: 12),
          _infoCard(
            Icons.shield_outlined,
            'Companion mode',
            'Aplikasi ini tidak mengubah file MLBB atau matchmaking. Hasil koneksi bukan ping server game.',
          ),
        ],
      );

  Widget _heroCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF49246C), Color(0xFF1D1735), Color(0xFF10111E)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: purple.withOpacity(.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MAIN SMART. PLAY FAIR.',
                style: TextStyle(
                    color: cyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4)),
            const SizedBox(height: 10),
            const Text('Your gaming\\ncompanion.',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text(
              'Kumpulan tools pendamping untuk katalog skin, catatan Ranked, dan pemeriksaan konektivitas.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
              ),
              onPressed: () => setState(() {
                selected = 1;
                status = 'Skin Gallery dibuka';
              }),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Buka Skin Gallery'),
            )
          ],
        ),
      );

  Widget _quickTile(IconData icon, String title, String subtitle, VoidCallback tap) =>
      InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: tap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: purple.withOpacity(.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: purple, size: 25),
              const SizedBox(height: 9),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(fontSize: 10, color: Colors.white60)),
            ],
          ),
        ),
      );

  Widget _skinGallery() {
    final heroes = [
      ('Miya', 'Marksman', Icons.brightness_5),
      ('Tigreal', 'Tank', Icons.shield),
      ('Eudora', 'Mage', Icons.bolt),
      ('Alucard', 'Fighter', Icons.flash_on),
      ('Layla', 'Marksman', Icons.gps_fixed),
      ('Nana', 'Support', Icons.auto_awesome),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('SKIN GALLERY', 'Katalog contoh — data skin belum disertakan'),
        const SizedBox(height: 12),
        ...heroes.map((hero) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: purple.withOpacity(.2)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF44265E),
                  child: Icon(hero.$3, color: cyan),
                ),
                title: Text(hero.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${hero.$2} • Preview placeholder'),
                trailing: IconButton(
                  tooltip: 'Favorit',
                  onPressed: () => setStatus('${hero.$1} ditandai untuk favorit'),
                  icon: const Icon(Icons.favorite_border, color: pink),
                ),
              ),
            )),
        _infoCard(Icons.info_outline, 'Catatan',
            'Galeri ini adalah contoh UI. Tambahkan gambar/data yang boleh digunakan; ini tidak membuka skin di dalam MLBB.'),
      ],
    );
  }

  Widget _rankedNotes() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('RANKED NOTES', 'Catatan strategi pertandingan'),
          const SizedBox(height: 12),
          _infoCard(Icons.groups, 'Draft tim',
              'Catat role yang dibutuhkan dan hero pilihan sebelum pertandingan.'),
          _infoCard(Icons.map_outlined, 'Rotasi',
              'Catat objektif, turtle/lord, dan waktu rotasi untuk evaluasi setelah match.'),
          _infoCard(Icons.trending_up, 'Review',
              'Gunakan catatan untuk menemukan pola kesalahan dan memperbaiki keputusan.'),
          _infoCard(Icons.smart_toy, 'Bot Practice (demo)',
              'Mode latihan bot yang berjalan di aplikasi pendamping, bukan bot yang masuk ke pertandingan Ranked MLBB.'),
          FilledButton.icon(
            onPressed: () => setStatus('Bot Practice demo: mode latihan terpisah belum terhubung ke MLBB'),
            icon: const Icon(Icons.smart_toy),
            label: const Text('Mulai Bot Practice (demo)'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => setStatus('Catatan baru: fitur penyimpanan lokal bisa ditambahkan berikutnya'),
            icon: const Icon(Icons.add),
            label: const Text('Tambah catatan (demo)'),
          ),
        ],
      );

  Widget _networkCheck() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('NETWORK CHECK', 'Pemeriksaan dasar koneksi internet'),
          const SizedBox(height: 12),
          _infoCard(Icons.speed, 'Ping 2 ms tidak bisa dijamin',
              'Latensi pertandingan ditentukan server, jarak, routing, dan jaringan. Aplikasi ini belum membaca ping MLBB.'),
          _infoCard(Icons.wifi, 'Tips koneksi',
              'Coba sinyal stabil, hindari unduhan besar, dekatkan diri ke router, dan bandingkan Wi-Fi dengan data seluler.'),
          FilledButton.icon(
            onPressed: () => setStatus('Tips: periksa ikon jaringan dan indikator ping di dalam MLBB'),
            icon: const Icon(Icons.network_check),
            label: const Text('Tampilkan tips koneksi'),
          ),
        ],
      );

  Widget _settings() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('SETTINGS', 'Pengaturan UI aplikasi'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: floatingMenuOpen,
            activeColor: purple,
            title: const Text('Panel melayang di dalam aplikasi'),
            subtitle: const Text('Menampilkan panel cepat pada layar aplikasi'),
            onChanged: (v) => setState(() => floatingMenuOpen = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: compactMode,
            activeColor: purple,
            title: const Text('Mode ringkas'),
            subtitle: const Text('Contoh preferensi UI'),
            onChanged: (v) => setState(() => compactMode = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: notifications,
            activeColor: purple,
            title: const Text('Notifikasi'),
            subtitle: const Text('Contoh preferensi notifikasi'),
            onChanged: (v) => setState(() => notifications = v),
          ),
          _infoCard(Icons.build_circle_outlined, 'Build info',
              'Flutter starter. Bangun APK Android dengan Flutter SDK; build iOS memerlukan macOS dan Xcode.'),
        ],
      );

  Widget _sectionTitle(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: purple,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      );

  Widget _infoCard(IconData icon, String title, String message) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: purple.withOpacity(.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: cyan),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text(message,
                      style: const TextStyle(
                          color: Colors.white70, height: 1.35, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _floatingPanel() => Container(
        width: 154,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xF21B122B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: purple.withOpacity(.85)),
          boxShadow: [
            BoxShadow(color: purple.withOpacity(.25), blurRadius: 20)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, size: 18, color: cyan),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text('RW QUICK',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                ),
                InkWell(
                  onTap: () => setState(() => floatingMenuOpen = false),
                  child: const Icon(Icons.close, size: 16, color: Colors.white60),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            _floatAction(Icons.checkroom, 'Skin Gallery', 1),
            _floatAction(Icons.emoji_events, 'Ranked Notes', 2),
            _floatAction(Icons.network_check, 'Network', 3),
            _floatAction(Icons.tune, 'Settings', 4),
          ],
        ),
      );

  Widget _floatAction(IconData icon, String label, int page) => InkWell(
        onTap: () => setState(() {
          selected = page;
          status = '$label dibuka';
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Icon(icon, size: 17, color: purple),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),
            ],
          ),
        ),
      );

  Widget _bottomNav() => NavigationBar(
        selectedIndex: selected > 3 ? 0 : selected,
        backgroundColor: const Color(0xFF171122),
        indicatorColor: purple.withOpacity(.25),
        onDestinationSelected: (i) => setState(() {
          selected = i == 4 ? 4 : i;
          status = '${pages[selected]} dibuka';
        }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checkroom), label: 'Skins'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), label: 'Ranked'),
          NavigationDestination(icon: Icon(Icons.network_check), label: 'Network'),
        ],
      );
}
