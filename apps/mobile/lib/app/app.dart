import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/customers/data/customer_repository.dart';

class DakkanaApp extends StatelessWidget {
  const DakkanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0F766E);
    return MaterialApp(
      title: 'دَكانة',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      ),
      home: const SplashGate(),
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  final auth = AuthRepository();
  Session? session;
  StoreInfo? store;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final restoredSession = await auth.restoreSession();
    final restoredStore = await auth.loadStore();
    if (!mounted) return;
    setState(() {
      session = restoredSession;
      store = restoredStore;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (session == null) return AuthScreen(auth: auth, onDone: _restore);
    if (store == null) return StoreSetupScreen(auth: auth, onDone: _restore);
    return HomeScreen(session: session!, store: store!);
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.auth, required this.onDone});
  final AuthRepository auth;
  final VoidCallback onDone;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool register = false;
  bool busy = false;
  String? error;

  Future<void> submit() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final name = nameController.text.trim();
    if (phone.length < 7 || password.length < 6 || (register && name.length < 2)) {
      setState(() => error = 'تأكد من البيانات المدخلة');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (register) {
        await widget.auth.register(name, phone, password);
      } else {
        await widget.auth.login(phone, password);
      }
      widget.onDone();
    } catch (e) {
      if (mounted) setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.storefront_rounded, size: 68),
                  const SizedBox(height: 16),
                  Text('دَكانة', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('كل حساب دَكانتك بإيدك', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 36),
                  if (register) ...[
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسمك', prefixIcon: Icon(Icons.person_outline))),
                    const SizedBox(height: 12),
                  ],
                  TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الجوال', prefixIcon: Icon(Icons.phone_outlined))),
                  const SizedBox(height: 12),
                  TextField(controller: passwordController, obscureText: true, onSubmitted: (_) => submit(), decoration: const InputDecoration(labelText: 'كلمة المرور أو PIN', prefixIcon: Icon(Icons.lock_outline))),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: busy ? null : submit,
                    icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login_rounded),
                    label: Text(register ? 'إنشاء الحساب' : 'دخول'),
                  ),
                  TextButton(
                    onPressed: busy ? null : () => setState(() { register = !register; error = null; }),
                    child: Text(register ? 'عندي حساب، بدي أدخل' : 'إنشاء حساب جديد'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StoreSetupScreen extends StatefulWidget {
  const StoreSetupScreen({super.key, required this.auth, required this.onDone});
  final AuthRepository auth;
  final VoidCallback onDone;

  @override
  State<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends State<StoreSetupScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  bool busy = false;
  String? error;

  Future<void> save() async {
    if (nameController.text.trim().length < 2) {
      setState(() => error = 'اكتب اسم الدكان');
      return;
    }
    setState(() { busy = true; error = null; });
    try {
      await widget.auth.createStore(nameController.text.trim(), phone: phoneController.text.trim(), address: addressController.text.trim());
      widget.onDone();
    } catch (e) {
      if (mounted) setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خلّينا نجهّز دَكانتك')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 24),
          Text('اسم الدكان', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('اكتب الاسم اللي بدك يظهر على التطبيق والكشوفات.'),
          const SizedBox(height: 24),
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'مثال: دكان أبو محمد', prefixIcon: Icon(Icons.storefront_outlined))),
          const SizedBox(height: 12),
          TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الدكان (اختياري)', prefixIcon: Icon(Icons.phone_outlined))),
          const SizedBox(height: 12),
          TextField(controller: addressController, decoration: const InputDecoration(labelText: 'المنطقة / العنوان (اختياري)', prefixIcon: Icon(Icons.location_on_outlined))),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(onPressed: busy ? null : save, child: Text(busy ? 'بحفظ...' : 'ابدأ دَكانتك')),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.session, required this.store});
  final Session session;
  final StoreInfo store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final customerRepository = CustomerRepository();
  final searchController = TextEditingController();
  List<Customer> customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final result = await customerRepository.list(widget.store.id, search: searchController.text);
    if (mounted) setState(() => customers = result);
  }

  Future<void> _addCustomer() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final balance = TextEditingController(text: '0');
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('زِيد زبون', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'اسم الزبون')),
            const SizedBox(height: 10),
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الجوال (اختياري)')),
            const SizedBox(height: 10),
            TextField(controller: balance, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'رصيد افتتاحي')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty) return;
                await customerRepository.add(storeId: widget.store.id, name: name.text, phone: phone.text, openingBalance: double.tryParse(balance.text) ?? 0);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop(true);
              },
              child: const Text('احفظ الزبون'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.store.name, style: const TextStyle(fontWeight: FontWeight.w800)),
          const Text('كل حساب دَكانتك بإيدك', style: TextStyle(fontSize: 12)),
        ]),
        actions: [IconButton(onPressed: _loadCustomers, icon: const Icon(Icons.sync_rounded), tooltip: 'تحديث')],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCustomers,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _WelcomeCard(name: widget.session.name),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _ActionCard(icon: Icons.point_of_sale_rounded, label: 'بيعة جديدة')),
              const SizedBox(width: 10),
              Expanded(child: _ActionCard(icon: Icons.payments_outlined, label: 'تسديد')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _ActionCard(icon: Icons.receipt_long_outlined, label: 'مصروف')),
              const SizedBox(width: 10),
              Expanded(child: _ActionCard(icon: Icons.inventory_2_outlined, label: 'شراء بضاعة')),
            ]),
            const SizedBox(height: 22),
            Text('الزباين', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: searchController, onChanged: (_) => _loadCustomers(), decoration: const InputDecoration(hintText: 'دوّر عَ زبون', prefixIcon: Icon(Icons.search_rounded))),
            const SizedBox(height: 12),
            if (customers.isEmpty) const _EmptyCustomers() else ...customers.map((customer) => _CustomerTile(customer: customer)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addCustomer, icon: const Icon(Icons.person_add_alt_1_rounded), label: const Text('زِيد زبون')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'البيوعات'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'الزباين'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'الأصناف'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'المزيد'),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(24)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('أهلين، $name', style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('ابدأ حركة دَكانتك من هون', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
          ])),
          const Icon(Icons.storefront_rounded, color: Colors.white, size: 48),
        ]),
      );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
            ]),
          ),
        ),
      );
}

class _EmptyCustomers extends StatelessWidget {
  const _EmptyCustomers();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Column(children: [
          Icon(Icons.people_outline_rounded, size: 42),
          SizedBox(height: 8),
          Text('لسّا ما في زباين', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('زِيد أول زبون وخلّي الحساب مرتب من البداية.'),
        ]),
      );
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final hasBalance = customer.balance > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(customer.name.characters.first)),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(customer.phone?.isNotEmpty == true ? customer.phone! : 'بدون رقم'),
        trailing: Text(
          hasBalance ? 'عليه ₪${customer.balance.toStringAsFixed(2)}' : 'مسدّد',
          style: TextStyle(fontWeight: FontWeight.bold, color: hasBalance ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
