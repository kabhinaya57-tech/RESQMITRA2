import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

const navy = Color(0xFF102A43);
const red = Color(0xFFE53935);
const pale = Color(0xFFF4F7FB);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ResqMitraApp());
}

class ResqMitraApp extends StatelessWidget {
  const ResqMitraApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'RESQ MITRA', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: pale,
      colorScheme: ColorScheme.fromSeed(seedColor: navy), appBarTheme: const AppBarTheme(backgroundColor: pale, foregroundColor: navy, elevation: 0)),
    home: const SplashScreen(),
  );
}

class RescueDb {
  RescueDb._();
  static final RescueDb instance = RescueDb._();
  Database? _db;
  Future<Database> get db async {
    if (_db != null) return _db!;
    final base = await getDatabasesPath();
    _db = await openDatabase(p.join(base, 'resq_mitra.db'), version: 1,
      onCreate: (d, v) async => d.execute('''CREATE TABLE sos_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, created_at TEXT NOT NULL,
        latitude REAL, longitude REAL, status TEXT NOT NULL)'''));
    return _db!;
  }
  Future<void> addSos(String type, Position? pos) async => (await db).insert('sos_history', {
    'type': type, 'created_at': DateTime.now().toIso8601String(),
    'latitude': pos?.latitude, 'longitude': pos?.longitude, 'status': 'Recorded locally'
  });
  Future<List<Map<String, Object?>>> history() async => (await db).query('sos_history', orderBy: 'id DESC');
}

class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  @override void initState() { super.initState(); _route(); }
  Future<void> _route() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => prefs.getBool('loggedIn') == true ? const RoleScreen() : const AuthScreen()));
  }
  @override void dispose() { _ticker.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(body: Container(width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter,end: Alignment.bottomCenter,colors:[Colors.white,Color(0xFFEAF1F8)])), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 150,height: 150,decoration: BoxDecoration(color: navy,borderRadius: BorderRadius.circular(38),boxShadow:[BoxShadow(color: navy.withOpacity(.2),blurRadius:24,offset:const Offset(0,10))]),child: const Icon(Icons.health_and_safety_rounded,color:Colors.white,size:94)),
    const SizedBox(height: 24), const Text('RESQ MITRA',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900,letterSpacing:2,color:navy)),
    const SizedBox(height: 12), AnimatedBuilder(animation:_ticker,builder:(_,__) { final words=['HELP','PROTECT','SUPPORT','TOGETHER']; return Text(words[(_ticker.value*words.length).floor().clamp(0,3)]+'  |  HELP  |  PROTECT  |  SUPPORT  |  TOGETHER',textAlign:TextAlign.center,style:const TextStyle(fontSize:12,fontWeight:FontWeight.bold,letterSpacing:1,color:red)); }),
    const SizedBox(height: 54), const SizedBox(width:30,height:30,child:CircularProgressIndicator(strokeWidth:3,color:red)), const SizedBox(height:12), const Text('Getting things ready…',style:TextStyle(color:Colors.blueGrey))
  ])));
}

class AuthScreen extends StatefulWidget { const AuthScreen({super.key}); @override State<AuthScreen> createState()=>_AuthScreenState(); }
class _AuthScreenState extends State<AuthScreen> {
  bool create = true, obscure = true; final form = GlobalKey<FormState>();
  final name = TextEditingController(), phone = TextEditingController(), email = TextEditingController(), password = TextEditingController();
  @override void dispose(){name.dispose();phone.dispose();email.dispose();password.dispose();super.dispose();}
  Future<void> continueApp() async {
    if (!(form.currentState?.validate() ?? false)) return;
    final prefs=await SharedPreferences.getInstance(); await prefs.setBool('loggedIn',true); await prefs.setString('email',email.text.trim());
    if (!mounted) return; Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const RoleScreen()));
  }
  InputDecoration decoration(String label, IconData icon)=>InputDecoration(labelText:label,prefixIcon:Icon(icon),filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none));
  @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Form(key:form,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    const Icon(Icons.health_and_safety_rounded,size:68,color:navy),const SizedBox(height:10),Text(create?'Create your account':'Welcome back',textAlign:TextAlign.center,style:const TextStyle(fontSize:28,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:8),const Text('One community. Ready to help.',textAlign:TextAlign.center,style:TextStyle(color:Colors.blueGrey)),const SizedBox(height:28),
    if(create) ...[TextFormField(controller:name,decoration:decoration('Full name',Icons.person_outline),validator:(v)=>v==null||v.trim().isEmpty?'Enter your name':null),const SizedBox(height:12),TextFormField(controller:phone,keyboardType:TextInputType.phone,decoration:decoration('Phone number',Icons.phone_outlined),validator:(v)=>v==null||v.trim().length<7?'Enter a valid phone number':null),const SizedBox(height:12)],
    TextFormField(controller:email,keyboardType:TextInputType.emailAddress,decoration:decoration('Email address',Icons.email_outlined),validator:(v)=>v==null||!v.contains('@')?'Enter a valid email':null),const SizedBox(height:12),
    TextFormField(controller:password,obscureText:obscure,decoration:decoration('Password',Icons.lock_outline).copyWith(suffixIcon:IconButton(icon:Icon(obscure?Icons.visibility:Icons.visibility_off),onPressed:()=>setState(()=>obscure=!obscure))),validator:(v)=>v==null||v.length<6?'Use at least 6 characters':null),const SizedBox(height:22),
    FilledButton(onPressed:continueApp,style:FilledButton.styleFrom(backgroundColor:red,padding:const EdgeInsets.symmetric(vertical:16),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14))),child:Text(create?'CREATE ACCOUNT':'LOGIN',style:const TextStyle(fontWeight:FontWeight.bold))),
    TextButton(onPressed:()=>setState(()=>create=!create),child:Text(create?'Already have an account? Login':'New to RESQ MITRA? Create account')),
    const Text('Starter demo: authentication is stored on this device only. Connect a secure auth provider before production use.',textAlign:TextAlign.center,style:TextStyle(fontSize:11,color:Colors.blueGrey))
  ]))))));
}

class RoleScreen extends StatefulWidget { const RoleScreen({super.key}); @override State<RoleScreen> createState()=>_RoleScreenState(); }
class _RoleScreenState extends State<RoleScreen>{String selected='seeker';
  @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Padding(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[const SizedBox(height:18),const Text('How would you like to use RESQ MITRA?',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:8),const Text('Choose a role. You can change this later.',style:TextStyle(color:Colors.blueGrey)),const SizedBox(height:28),
    _role('seeker','HELP SEEKER','I need help or emergency support',Icons.volunteer_activism),const SizedBox(height:14),_role('volunteer','VOLUNTEER AS RESCUE RESPONDER','I want to help others in need',Icons.health_and_safety),const Spacer(),FilledButton(onPressed:() async {final prefs=await SharedPreferences.getInstance();await prefs.setString('role',selected);if(!mounted)return;Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const HomeScreen()));},style:FilledButton.styleFrom(backgroundColor:red,padding:const EdgeInsets.symmetric(vertical:17),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14))),child:const Text('GET STARTED',style:TextStyle(fontWeight:FontWeight.bold,letterSpacing:1)))]))));
  Widget _role(String id,String title,String subtitle,IconData icon){final active=selected==id;return InkWell(onTap:()=>setState(()=>selected=id),borderRadius:BorderRadius.circular(18),child:Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:active?const Color(0xFFFFF0F0):Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:active?red:const Color(0xFFE0E6ED),width:active?2:1)),child:Row(children:[Icon(icon,size:36,color:active?red:navy),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:5),Text(subtitle,style:const TextStyle(color:Colors.blueGrey,fontSize:13))])),Icon(active?Icons.radio_button_checked:Icons.radio_button_off,color:active?red:Colors.grey)])));}
}

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState()=>_HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int tab=0; late final AnimationController pulse=AnimationController(vsync:this,duration:const Duration(milliseconds:800),lowerBound:.94,upperBound:1.05)..repeat(reverse:true);
  @override void dispose(){pulse.dispose();super.dispose();}
  Future<Position?> _position() async { try { if(!await Geolocator.isLocationServiceEnabled()) return null; var permission=await Geolocator.checkPermission();if(permission==LocationPermission.denied)permission=await Geolocator.requestPermission();if(permission==LocationPermission.denied||permission==LocationPermission.deniedForever)return null;return await Geolocator.getCurrentPosition(); } catch(_){return null;} }
  Future<void> _sos(String type) async { Navigator.pop(context); showDialog(context:context,barrierDismissible:false,builder:(_)=>const AlertDialog(content:Row(children:[CircularProgressIndicator(),SizedBox(width:18),Expanded(child:Text('Recording SOS and getting location…'))])));final pos=await _position();await RescueDb.instance.addSos(type,pos);if(!mounted)return;Navigator.pop(context);showDialog(context:context,builder:(ctx)=>AlertDialog(title:const Text('SOS recorded'),content:Text(pos==null?'Your $type SOS has been saved to local history. Location was unavailable.\n\nThis starter does not yet send an alert to emergency services or contacts.':'Your $type SOS has been saved to local history.\nLocation: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}\n\nThis starter does not yet send an alert to emergency services or contacts.'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('OK'))])); }
  void _openSos(){showModalBottomSheet(context:context,showDragHandle:true,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(26))),builder:(ctx)=>Padding(padding:const EdgeInsets.fromLTRB(20,8,20,28),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[const Text('Choose SOS type',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:14),_sosOption('GENERAL SOS','Emergency, accident or urgent help',const Color(0xFF1976D2),Icons.sos),const SizedBox(height:10),_sosOption('WOMEN SOS','Safety support for women',const Color(0xFFE94E9B),Icons.female),const SizedBox(height:10),_sosOption('CHILD SOS','Safety support for children',const Color(0xFFF5C542),Icons.child_care)])));}
  Widget _sosOption(String title,String subtitle,Color color,IconData icon)=>InkWell(onTap:()=>_sos(title),borderRadius:BorderRadius.circular(16),child:Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:color.withOpacity(.12),borderRadius:BorderRadius.circular(16),border:Border.all(color:color.withOpacity(.5))),child:Row(children:[CircleAvatar(backgroundColor:color,child:Icon(icon,color:title=='CHILD SOS'?navy:Colors.white)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(fontWeight:FontWeight.bold,color:title=='CHILD SOS'?navy:color)),Text(subtitle,style:const TextStyle(fontSize:12,color:Colors.blueGrey))])),const Icon(Icons.chevron_right)])));
  @override Widget build(BuildContext context){final pages=[_home(),const MapPage(),const HistoryPage(),const SimplePage(title:'BADGES',icon:Icons.workspace_premium,message:'Your achievement badges will appear here.'),const ProfilePage()];return Scaffold(appBar:AppBar(title:const Text('RESQ MITRA',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:1)),actions:[IconButton(onPressed:()=>setState(()=>tab=4),icon:const Icon(Icons.account_circle_outlined))]),body:pages[tab],bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),backgroundColor:Colors.white,indicatorColor:const Color(0xFFFFE1E1),destinations:const [NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'HOME'),NavigationDestination(icon:Icon(Icons.map_outlined),selectedIcon:Icon(Icons.map),label:'MAP'),NavigationDestination(icon:Icon(Icons.history),label:'HISTORY'),NavigationDestination(icon:Icon(Icons.workspace_premium_outlined),label:'BADGES'),NavigationDestination(icon:Icon(Icons.person_outline),selectedIcon:Icon(Icons.person),label:'PROFILE')]);}
  Widget _home()=>Padding(padding:const EdgeInsets.all(24),child:Column(children:[const SizedBox(height:14),const Text('We are stronger together.',style:TextStyle(fontSize:20,fontWeight:FontWeight.w700,color:navy)),const SizedBox(height:8),const Text('Tap SOS to choose the support you need.',textAlign:TextAlign.center,style:TextStyle(color:Colors.blueGrey)),const Spacer(),AnimatedBuilder(animation:pulse,builder:(_,__)=>Transform.scale(scale:pulse.value,child:GestureDetector(onTap:_openSos,child:Container(width:230,height:230,decoration:BoxDecoration(shape:BoxShape.circle,color:red,boxShadow:[BoxShadow(color:red.withOpacity(.28),blurRadius:30,spreadRadius:8)]),child:const Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.sos,color:Colors.white,size:76),Text('SOS',style:TextStyle(color:Colors.white,fontSize:40,fontWeight:FontWeight.w900,letterSpacing:3)),Text('TAP FOR HELP',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,letterSpacing:1))])))),const Spacer(),Container(width:double.infinity,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18)),child:const Row(children:[Icon(Icons.location_on_outlined,color:red,size:30),SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Location support',style:TextStyle(fontWeight:FontWeight.bold,color:navy)),Text('Your location is requested only when you record an SOS.',style:TextStyle(fontSize:12,color:Colors.blueGrey))]))])),const SizedBox(height:12)]));
}

class MapPage extends StatefulWidget { const MapPage({super.key}); @override State<MapPage> createState()=>_MapPageState(); }
class _MapPageState extends State<MapPage>{String result='Tap below to check your current coordinates.';Future<void> locate()async{try{if(!await Geolocator.isLocationServiceEnabled()){setState(()=>result='Location services are turned off.');return;}var perm=await Geolocator.checkPermission();if(perm==LocationPermission.denied)perm=await Geolocator.requestPermission();if(perm==LocationPermission.denied||perm==LocationPermission.deniedForever){setState(()=>result='Location permission was not granted.');return;}final p=await Geolocator.getCurrentPosition();setState(()=>result='Latitude: ${p.latitude}\nLongitude: ${p.longitude}');}catch(e){setState(()=>result='Unable to get location right now.');}}@override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Icon(Icons.location_on,size:76,color:red),const Text('YOUR MAP',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:12),Text(result,textAlign:TextAlign.center),const SizedBox(height:20),FilledButton.icon(onPressed:locate,icon:const Icon(Icons.my_location),label:const Text('GET MY LOCATION'))])));}

class HistoryPage extends StatefulWidget { const HistoryPage({super.key}); @override State<HistoryPage> createState()=>_HistoryPageState(); }
class _HistoryPageState extends State<HistoryPage>{late Future<List<Map<String,Object?>>> rows;@override void initState(){super.initState();rows=RescueDb.instance.history();}@override Widget build(BuildContext context)=>FutureBuilder<List<Map<String,Object?>>>(future:rows,builder:(context,s){if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());final data=s.data??[];if(data.isEmpty)return const SimplePage(title:'HISTORY',icon:Icons.history,message:'Your SOS history will appear here.');return ListView.builder(padding:const EdgeInsets.all(16),itemCount:data.length,itemBuilder:(context,i){final item=data[i];return Card(color:Colors.white,child:ListTile(leading:const CircleAvatar(backgroundColor:Color(0xFFFFE1E1),child:Icon(Icons.sos,color:red)),title:Text('${item['type']}'),subtitle:Text('${item['created_at']}\n${item['status']}'),isThreeLine:true));});});}
class SimplePage extends StatelessWidget {final String title,message;final IconData icon;const SimplePage({super.key,required this.title,required this.icon,required this.message});@override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,size:70,color:navy),const SizedBox(height:14),Text(title,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:8),Text(message,textAlign:TextAlign.center,style:const TextStyle(color:Colors.blueGrey))])));}
class ProfilePage extends StatelessWidget {const ProfilePage({super.key});@override Widget build(BuildContext context)=>FutureBuilder<SharedPreferences>(future:SharedPreferences.getInstance(),builder:(context,s){final prefs=s.data;return Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const CircleAvatar(radius:42,backgroundColor:Color(0xFFDDE8F2),child:Icon(Icons.person,size:48,color:navy)),const SizedBox(height:14),const Text('PROFILE',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:navy)),Text(prefs?.getString('email')??'Your account'),const SizedBox(height:20),OutlinedButton.icon(onPressed:()async{final p=await SharedPreferences.getInstance();await p.setBool('loggedIn',false);if(!context.mounted)return;Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const AuthScreen()),(_)=>false);},icon:const Icon(Icons.logout),label:const Text('LOG OUT'))])));}}
