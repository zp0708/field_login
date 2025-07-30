import 'package:field_login/widgets/shape_tab_widget/shape_tab_widget.dart';
import 'package:flutter/material.dart';
import 'widgets/login_tab_widget.dart';
import 'widgets/background_widget.dart';
import 'widgets/phone_input_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobee 摩笔',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Custom Painter Example')),
        body: Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          color: Colors.green,
          child: SizedBox(
            height: 44,
            child: ShapeTabWidget(
              titles: ['验证码登录', '密码登录', '快捷登录'],
              onSelectItem: (p0, p1) => print(p0),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isVerificationCodeLogin = true;
  bool isAgreementChecked = true;
  String phoneNumber = "139 1234 5678";
  String verificationCode = "123 456";
  int countdown = 32;
  bool phoneHasError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 品牌标题
                const Text(
                  'Mobee 摩笔',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 30),

                // 登录选项卡

                ClipSegmentWidget(titles: ['验证码登录', '密码登录'], height: 44, width: 168),
                const SizedBox(height: 30),

                // 手机号码输入框
                PhoneInputWidget(
                  initialValue: phoneNumber,
                  hasError: phoneHasError,
                  onChanged: (value) {
                    setState(() {
                      phoneNumber = value;
                      // 清除错误状态
                      phoneHasError = false;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 验证码输入框
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          verificationCode,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            '重新获取 ($countdown)',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 演示按钮
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            phoneHasError = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('正常状态'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            phoneHasError = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('错误状态'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 登录按钮
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // 登录逻辑
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '登录',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 协议复选框
                Row(
                  children: [
                    Checkbox(
                      value: isAgreementChecked,
                      onChanged: (value) {
                        setState(() {
                          isAgreementChecked = value ?? false;
                        });
                      },
                      activeColor: Colors.green[600],
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: '我已阅读并同意 '),
                            TextSpan(
                              text: '服务协议',
                              style: TextStyle(
                                color: Colors.green[600],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' 和 '),
                            TextSpan(
                              text: '隐私政策',
                              style: TextStyle(
                                color: Colors.green[600],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
